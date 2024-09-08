
resource "aws_vpc" "kubeadm_demo_vpc" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    # NOTE: very important to use an uppercase N to set the name in the console
    Name                               = "kubeadm_demo_vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
  depends_on = [null_resource.ansible_pre_task]

}

resource "aws_subnet" "kubeadm_demo_subnet" {

  vpc_id                  = aws_vpc.kubeadm_demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "kubadm_demo_public_subnet"
  }
  depends_on = [null_resource.ansible_pre_task]

}


resource "aws_internet_gateway" "kubeadm_demo_igw" {
  vpc_id = aws_vpc.kubeadm_demo_vpc.id

  tags = {
    Name = "Kubeadm Demo Internet GW"
  }

}

resource "aws_route_table" "kubeadm_demo_routetable" {
  vpc_id = aws_vpc.kubeadm_demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_demo_igw.id
  }

  tags = {
    Name = "kubeadm Demo IGW route table"
  }

}

resource "aws_route_table_association" "kubeadm_demo_route_association" {
  subnet_id      = aws_subnet.kubeadm_demo_subnet.id
  route_table_id = aws_route_table.kubeadm_demo_routetable.id
}