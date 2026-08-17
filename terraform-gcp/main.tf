# Minimal GCP Free Tier-friendly CPU environment.
resource "google_compute_network" "ai_vpc" {
  name                    = "ai-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  name                     = "ai-subnet"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  network                  = google_compute_network.ai_vpc.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.ai_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["cpu-node"]
}

resource "google_service_account" "cpu_node_sa" {
  account_id   = "cpu-node-sa"
  display_name = "CPU Lab Node Service Account"
}

resource "google_project_iam_member" "cpu_node_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cpu_node_sa.email}"
}

resource "google_project_iam_member" "cpu_node_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cpu_node_sa.email}"
}

resource "google_compute_instance" "cpu_node" {
  name         = "ai-cpu-node"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["cpu-node"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.ai_vpc.id
    subnetwork = google_compute_subnetwork.private.id
    access_config {}
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }

  service_account {
    email  = google_service_account.cpu_node_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = replace(file("${path.module}/user_data_cpu.sh"), "\r\n", "\n")
  metadata                = { enable-oslogin = "TRUE" }
}
