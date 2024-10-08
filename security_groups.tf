
resource "aws_security_group" "kubeadm_demo_sg_flannel" {
  name = "flannel-overlay-backend"
  tags = {
    Name = "Flannel Overlay backend"
  }

  ingress {
    description = "flannel overlay backend"
    protocol    = "udp"
    from_port   = 8285
    to_port     = 8285
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "flannel vxlan backend"
    protocol    = "udp"
    from_port   = 8472
    to_port     = 8472
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "kubadm_demo_sg_common" {
  name = "common-ports"
  tags = {
    Name = "common ports"
  }

  ingress {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
resource "aws_security_group" "kubeadm_demo_sg_control_plane" {
  name = "kubeadm-control-plane security group"
  ingress {
    description = "API Server"
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    protocol    = "tcp"
    from_port   = 2379
    to_port     = 2380
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd server client API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Scheduler"
    protocol    = "tcp"
    from_port   = 10259
    to_port     = 10259
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Contoller Manager"
    protocol    = "tcp"
    from_port   = 10257
    to_port     = 10257
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Control Plane SG"
  }
}


resource "aws_security_group" "kubeadm_demo_sg_worker_nodes" {
  name = "kubeadm-worker-node security group"

  ingress {
    description = "kubelet API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort services"
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Worker Nodes SG"
  }

}
