resource "local_file" "docker_host_list" {
  content = <<-EOT
    %{~ for host in var.server_names }
      ${host}
    %{ endfor ~}
  EOT

  filename = "${path.module}/../config/docker-host-ips.txt"
}