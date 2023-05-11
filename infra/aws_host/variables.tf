variable "project_name" {
  description = "A prefix for names of objects created by this module"
  default     = "capist"
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type        = string
}

variable "name" {
  description = "Symbolic name of this instance"
  type        = string
}

variable "ami" {
  description = "AMI ID"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.small"
}

variable "ssh_key_name" {
  description = "Name of the SSH key used to access the instance"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path of private ssh key used to access the instance"
  type        = string
}

variable "ssh_bastion_host" {
  description = "Public name of the SSH bastion host. Leave null for publicly accessible instances"
  default     = null
}

variable "ssh_tunnels" {
  description = "Opens SSH tunnels to this host via the bastion"
  type        = list(list(number))
  default     = []
}

variable "subnet_id" {
  description = "ID of the subnet to connect to"
  type        = string
}

variable "vpc_security_group_id" {
  description = "ID of the security group to connect to"
  type        = string
}

variable "root_volume_size_gb" {
  description = "Size of the root volume"
  default     = 50
}