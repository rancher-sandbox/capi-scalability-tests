output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

# output "latest_sles_ami" {
#   value = data.aws_ami.sles15sp4
# }

output "latest_ubuntu_ami" {
  value = data.aws_ami.ubuntu
}

output "prom_policy" {
    value = aws_iam_instance_profile.prom_profile.name
}