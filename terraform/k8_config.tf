# Launch EC2 instance for Master node
resource "aws_instance" "k8_master" {
  ami                         = var.EC2_AMI
  instance_type               = var.INSTANCE_TYPE
  key_name                    = aws_key_pair.terrraformkey.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids = [
    aws_security_group.k8_allow_ssh_http.id
  ]

  tags = {
    Name = "K8 Master Node"
  }
}

# Launch EC2 instance for Worker node
resource "aws_instance" "k8_worker" {
  count         = var.WORKER_NODES
  ami           = var.EC2_AMI
  instance_type = var.INSTANCE_TYPE
  key_name      = aws_key_pair.terrraformkey.key_name

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids = [
    aws_security_group.k8_allow_ssh_http.id
  ]

  # user_data = templatefile("create_ansible_user.sh",{
  #     user_name = "ansible",
  #     pub_key = aws_key_pair.terrraformkey.public_key
  # })

  tags = {
    Name = "K8 Worker Node${count.index}"
  }
}
