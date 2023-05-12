terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

resource "ssh_resource" "node_exporter_installation" {
  count      = length(var.server_names)
  host         = var.server_names[count.index]
  private_key  = file(var.ssh_private_key_path)
  user         = "root"
  bastion_host = var.ssh_bastion_host
  timeout      = "240s"

   file {
    content     = file("${path.module}/install_node_exporter.sh")
    destination = "/root/install_node_exporter.sh"
    permissions = "0700"
  }

  commands = [
    "/root/install_node_exporter.sh"
  ]
}