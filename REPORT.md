# Báo cáo ngắn

Mô hình LightGBM được huấn luyện trên máy CPU GCP `e2-micro` với thời gian training khoảng **11,37 giây**.
Thời gian đọc và nạp dữ liệu là khoảng **4,80 giây**, phù hợp với một VM có tài nguyên hạn chế.
Kết quả đánh giá đạt **AUC-ROC = 0,878**, cho thấy mô hình có khả năng phân biệt giao dịch gian lận khá tốt.
Accuracy đạt **99,86%**, tuy nhiên chỉ số này cần được xem xét cùng F1-score do dữ liệu bị mất cân bằng.
F1-score đạt **0,638**, Precision **0,591** và Recall **0,694**, cho thấy mô hình phát hiện được phần lớn giao dịch gian lận nhưng vẫn còn false positive.
Inference một dòng có độ trễ khoảng **1,92 ms**, đáp ứng tốt các yêu cầu dự đoán gần thời gian thực.
Khi dự đoán 1.000 dòng, throughput đạt khoảng **63.347 dòng/giây** trên CPU.