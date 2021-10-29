resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create local key
resource "local_file" "keyfile" {
  content         = tls_private_key.k8s_ssh.private_key_pem
  filename        = "../terraform_key.pem"
  file_permission = "0400"
}

# Provides EC2 keypair
resource "aws_key_pair" "terrraformkey" {
  key_name   = "terraform_key"
  public_key = tls_private_key.k8s_ssh.public_key_openssh
}

# Generate public key
resource "local_file" "pubkeyfile" {
  content         = tls_private_key.k8s_ssh.public_key_openssh
  filename        = "../terraform_pub_key.pub"
  file_permission = "0400"
}