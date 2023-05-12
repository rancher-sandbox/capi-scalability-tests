output "help" {
  value = <<-EOT
    CAPI MANAGEMENT CLUSTER ACCESS:
      export KUBECONFIG=./config/capimgmt.yaml

    DOCKER HOST ADDRESSES (use in CAPD manifests):
      ${join("\n      ", module.docker_hosts.*.private_ip)}
 EOT
}