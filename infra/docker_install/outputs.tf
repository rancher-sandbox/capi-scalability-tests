resource "local_file" "docker_host_list" {
  content = <<-EOT
    %{~ for ip in var.private_ips }
${ip}
    %{ endfor ~}
  EOT

  filename = "${path.module}/../config/docker-host-ips.txt"
}