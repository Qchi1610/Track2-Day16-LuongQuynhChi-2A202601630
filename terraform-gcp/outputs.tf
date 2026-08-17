output "cpu_node_name" {
  value = google_compute_instance.cpu_node.name
}

output "cpu_node_zone" {
  value = google_compute_instance.cpu_node.zone
}

output "external_ip" {
  value = google_compute_instance.cpu_node.network_interface[0].access_config[0].nat_ip
}

output "iap_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.cpu_node.name} --zone=${google_compute_instance.cpu_node.zone} --tunnel-through-iap --project=${var.project_id}"
}
