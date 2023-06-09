variable "project_name" {
  description = "A prefix for names of objects created by this module"
  type        = string
  nullable    = false
}

variable "capi_core_version" {
  description = "The core CAPI provider version"
  type = string
  default     = "cluster-api:v99.1.0-rich2"
}

variable "capi_infra_providers" {
  description = "The CAPI infratrsucture providers to enable"
  type        = string
  default     = "docker-rich:v99.1.0-rich2"
}

variable "capi_bootstrap_providers" {
  description = "The CAPI bootstrap providers to enable (comma separate)"
  type = string
  default = "kubeadm:v99.1.0-rich2"
}

variable "capi_controlplane_providers" {
  description = "The CAPI controlplane providers to enable (comma separate)"
  type = string
  default = "kubeadm:v99.1.0-rich2"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-2a"
}

variable "bastion_ami" {
  type    = string
  default = "ami-0a242269c4b530c5e" // Amazon Linux 2 2023
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.small"
}

variable "capimgmt_instance_type" {
  type    = string
  default = "t3.large"
}

variable "capimgmt_ami" {
  type    = string
  default = "ami-09744628bed84e434" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-03-25
}

variable "capimgmt_server_count" {
  type    = number
  default = 1
}

variable "capimgmt_agent_count" {
  type    = number
  default = 0
}

variable "capimgmt_agent_observability_count" {
  type    = number
  default = 0
}

variable "capimgmt_rke2_version" {
  type    = string
  default = "v1.23.10+rke2r1"
}

variable "capimgmt_max_pods" {
  type    = number
  default = 300
}

variable "capimgmt_node_cidr_mask_size" {
  type    = number
  default = 22
}

variable "capimgmt_san" {
  type    = string
  default = "upstream.local.gd"
}

variable "capimgmt_local_port" {
  type    = number
  default = 6443
}

variable "dockerhost_server_count" {
  description = "The number of docker host servers to create"
  type        = number
  default     = 1
}

variable "dockerhost_instance_type" {
  type    = string
  default = "t3.xlarge"
}

variable "dockerhost_ami" {
  type    = string
  default = "ami-09744628bed84e434" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-03-25
}

variable "dockerhost_deploy_nodeexporter" {
  type    = bool
  default = true 
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "capi_concurrency" {
  description = "The controller concurrency level for CAPI"
  type        = number
  default     = 10
}

variable "capi_kube_api_qps" {
  description = "The qps for the rest client"
  type        = number
  default     = 20
}

variable "capi_kube_api_burst" {
  description = "The burst rate for the rest client"
  type        = number
  default     = 30
}
