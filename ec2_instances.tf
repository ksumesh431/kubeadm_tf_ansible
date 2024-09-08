
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical's AWS account ID
}

resource "aws_instance" "kubeadm_demo_control_plane" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.kubeadm_demo_key_pair.key_name
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.kubadm_demo_sg_common.name,
    aws_security_group.kubeadm_demo_sg_flannel.name,
    aws_security_group.kubeadm_demo_sg_control_plane.name,
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 14
  }

  tags = {
    Name = "Kubeadm Master"
    Role = "Control plane node"
  }

  #   provisioner "local-exec" {
  #     command = "echo 'master ${self.public_ip}' >> ./files/hosts"
  #   }

}

resource "null_resource" "add_master_ip_to_hosts" {
  provisioner "local-exec" {
    command = <<EOT
      set -e  # Exit immediately if a command fails
      sleep 15
      mkdir -p ./files
      touch ./files/hosts
      echo "" > ./files/hosts
      echo 'master ${aws_instance.kubeadm_demo_control_plane.public_ip}' >> ./files/hosts
      ssh-keyscan -H ${aws_instance.kubeadm_demo_control_plane.public_ip} >> ~/.ssh/known_hosts
    EOT

  }

  depends_on = [aws_instance.kubeadm_demo_control_plane]
}

resource "aws_instance" "kubeadm_demo_worker_nodes" {
  count                       = var.worker_nodes_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kubeadm_demo_key_pair.key_name
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.kubeadm_demo_sg_flannel.name,
    aws_security_group.kubadm_demo_sg_common.name,
    aws_security_group.kubeadm_demo_sg_worker_nodes.name,
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Name = "Kubeadm Worker ${count.index}"
    Role = "Worker node"
  }

  #   provisioner "local-exec" {
  #     command = "echo 'worker-${count.index} ${self.public_ip}' >> ./files/hosts"
  #   }

}

resource "null_resource" "add_worker_ip_to_hosts" {
  count = var.worker_nodes_count # Assuming you have a variable for the worker node count

  provisioner "local-exec" {
    command = <<EOT
      set -e  # Exit immediately if a command fails
      sleep 15 
      echo 'worker-${count.index} ${aws_instance.kubeadm_demo_worker_nodes[count.index].public_ip}' >> ./files/hosts
      ssh-keyscan -H ${aws_instance.kubeadm_demo_worker_nodes[count.index].public_ip} >> ~/.ssh/known_hosts
    EOT

  }

  depends_on = [aws_instance.kubeadm_demo_control_plane, null_resource.add_master_ip_to_hosts]
}
