resource "local_file" "login_script" {
  content = <<-EOT
    #!/bin/sh
    ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" \
      %{if var.ssh_bastion_host != null~}
      -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p root@${var.ssh_bastion_host}" root@${aws_instance.instance.private_dns} \
      %{else~}
      root@${aws_instance.instance.public_dns} \
      %{endif~}
      $@
  EOT

  filename = "${path.module}/../config/ssh-to-${aws_instance.instance.private_dns}-${var.name}.sh"
}