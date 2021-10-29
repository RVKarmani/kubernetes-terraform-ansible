# Update Ansible inventory
resource "local_file" "ansible_host" {
    depends_on = [
      aws_instance.k8_master,
      aws_instance.k8_worker
    ]
    count       = var.WORKER_NODES
    content     = "[Master_Node]\n${aws_instance.k8_master.public_ip}\n\n[Worker_Node]\n${join("\n", aws_instance.k8_worker.*.public_ip)}"
    filename    = "../ansible/inventory"
  }

# Print K8s Master and Worker node IP
output "Master_Node_IP" {  value = aws_instance.k8_master.public_ip}
output "Worker_Node_IP" {  value = join(", ", aws_instance.k8_worker.*.public_ip) }