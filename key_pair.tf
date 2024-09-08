resource "tls_private_key" "kubadm_demo_private_key" {

  algorithm = "RSA"
  rsa_bits  = 4096

  #   provisioner "local-exec" { # Create a "pubkey.pem" to your computer!!
  #     command = "echo '${self.public_key_pem}' > ./pubkey.pem"
  #   }

  provisioner "local-exec" { # Create a "pubkey.pem" to your computer!!
    command = <<EOT
    rm ./pubkey.pem
    echo '${self.public_key_pem}' > ./pubkey.pem
    chmod 600 ./pubkey.pem
    EOT

  }
}

resource "aws_key_pair" "kubeadm_demo_key_pair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.kubadm_demo_private_key.public_key_openssh

  #   provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
  #     command = "echo '${tls_private_key.kubadm_demo_private_key.private_key_pem}' > ./private-key.pem"
  #   }
  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = <<EOT
      rm ./private-key.pem
      echo '${tls_private_key.kubadm_demo_private_key.private_key_pem}' > ./private-key.pem
      chmod 600 ./private-key.pem
    EOT
  }

}
