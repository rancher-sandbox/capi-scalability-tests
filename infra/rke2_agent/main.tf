terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
  }
}


resource "ssh_resource" "agent_installation" {
  count      = length(var.agent_names)

  host         = var.agent_names[count.index]
  private_key  = file(var.ssh_private_key_path)
  user         = "root"
  bastion_host = var.ssh_bastion_host
  timeout      = "600s"

  file {
    content = templatefile("${path.module}/install_rke2.sh", {
      rke2_version = var.rke2_version,
      sans         = [var.agent_names[count.index]]
      token        = var.registration_token
      server_url   = "https://${var.server_name}:9345"

      client_ca_key          = var.client_ca_key
      client_ca_cert         = var.client_ca_cert
      server_ca_key          = var.server_ca_key
      server_ca_cert         = var.server_ca_cert
      request_header_ca_key  = var.request_header_ca_key
      request_header_ca_cert = var.request_header_ca_cert
      sleep_time             = 0
      max_pods               = var.max_pods
      node_cidr_mask_size    = var.node_cidr_mask_size
      node_labels            = var.node_labels
      node_taints            = var.node_taints
    })
    destination = "/root/install_rke2.sh"
    permissions = "0700"
  }

  commands = [
    "/root/install_rke2.sh > >(tee install_rke2.log) 2> >(tee install_rke2.err >&2)"
  ]
}

//    --node-label value                            (agent/node) Registering and starting kubelet with set of labels
// 'node-role.kubernetes.io/worker=worker'
//   --node-taint value 
//node-taint:
//  - "CriticalAddonsOnly=true:NoExecute"