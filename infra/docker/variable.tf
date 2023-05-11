variable "server_names" {
  description = "List of names of server nodes to deploy"
  type        = list(string)
}

variable "private_ips" {
  description = "List of private ip addresses of the docker hosts"
  type        = list(string)
}

variable "ssh_private_key_path" {
  description = "Path of private ssh key used to access the instance"
  type        = string
}

variable "ssh_bastion_host" {
  description = "Public name of the SSH bastion host. Leave null for publicly accessible instances"
  default     = null
}