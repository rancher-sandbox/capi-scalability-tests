variable "server_names" {
  description = "List of names of server nodes"
  type        = list(string)
}

variable "capi_infra_providers" {
  description = "The CAPI infratrsucture providers to enable"
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

variable "capi_concurrency" {
  description = "The controller concurrency level for CAPI"
  type        = number
}

variable "capi_kube_api_qps" {
  description = "The qps for the rest client"
  type        = number
}

variable "capi_kube_api_burst" {
  description = "The burst rate for the rest client"
  type        = number
}