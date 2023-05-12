terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

resource "ssh_sensitive_resource" "clusterctl_init" {
  count        = length(var.server_names) > 0 ? 1 : 0
  host         = var.server_names[0]
  private_key  = file(var.ssh_private_key_path)
  user         = "root"
  bastion_host = var.ssh_bastion_host
  timeout      = "240s"

  file {
    content  = file("${path.module}/install_clusterctl.sh")
    destination = "/root/install_clusterctl.sh"
    permissions = "0700"
  }

  file {
    content  = templatefile("${path.module}/init.sh", {
        capi_infra_providers = var.capi_infra_providers
    })
    destination = "/root/init.sh"
    permissions = "0700"
  }

  file {
    content  = file("${path.module}/clusterctl.yaml")
    destination = "/root/clusterctl.yaml"
    permissions = "0644"
  }

  commands = [
    "/root/install_clusterctl.sh",
    "/root/init.sh",
  ]
}