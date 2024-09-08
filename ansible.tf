
resource "null_resource" "ansible_pre_task" {
  provisioner "local-exec" {
    command     = file("${path.module}/check_ansible.sh")
    interpreter = ["/bin/bash", "-c"]
  }
}



resource "ansible_host" "kubadm_demo_control_plane_host" {
  depends_on = [
    aws_instance.kubeadm_demo_control_plane
  ]
  name   = "control_plane"
  groups = ["master"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.kubeadm_demo_control_plane.public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
    node_hostname                = "master"
  }
}

resource "ansible_host" "kubadm_demo_worker_nodes_host" {
  depends_on = [
    aws_instance.kubeadm_demo_worker_nodes
  ]
  count  = 2
  name   = "worker-${count.index}"
  groups = ["workers"]
  variables = {
    node_hostname                = "worker-${count.index}"
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.kubeadm_demo_worker_nodes[count.index].public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
  }
}

resource "null_resource" "run_ansible" {

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yml playbook.yml"
  }

  # Add explicit dependencies on key resources if needed
  depends_on = [
    null_resource.ansible_pre_task, ansible_host.kubadm_demo_control_plane_host, ansible_host.kubadm_demo_worker_nodes_host, null_resource.add_master_ip_to_hosts, null_resource.add_worker_ip_to_hosts, tls_private_key.kubadm_demo_private_key, aws_key_pair.kubeadm_demo_key_pair
  ]
}
