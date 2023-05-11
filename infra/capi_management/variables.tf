variable "server_names" {
  description = "List of names of server nodes"
  type        = list(string)
}

variable "docker_provider_version" {
  description = "The version of the forked docker provider to use"
  type = string
}

variable "ssh_private_key_path" {
  description = "Path of private ssh key used to access the instance"
  type        = string
}

variable "ssh_bastion_host" {
  description = "Public name of the SSH bastion host. Leave null for publicly accessible instances"
  default     = null
}