terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

resource "ssh_resource" "docker_engine_installation" {
  count      = length(var.server_names)
  host         = var.server_names[count.index]
  private_key  = file(var.ssh_private_key_path)
  user         = "root"
  bastion_host = var.ssh_bastion_host
  timeout      = "240s"
  
  file {
    content     = templatefile("${path.module}/install_docker.sh", {
      bind_ip = var.private_ips[count.index]
    })
    destination = "/root/install_docker.sh"
    permissions = "0700"
  }

   file {
    content     = file("${path.module}/create_kind_network.sh")
    destination = "/root/create_kind_network.sh"
    permissions = "0700"
  }

  commands = [
    "/root/install_docker.sh",
    "/root/create_kind_network.sh"
  ]
}

