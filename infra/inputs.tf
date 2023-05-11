locals {
  region            = "eu-west-2"
  availability_zone = "eu-west-2a"

  bastion_ami = "ami-0a242269c4b530c5e" // Amazon Linux 2 2023
  bastion_instance_type = "t2.small"

  capimgmt_instance_type       = "t3.large"
  capimgmt_ami                 = "ami-09744628bed84e434" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-03-25
  capimgmt_server_count        = 1
  capimgmt_agent_count         = 0
  capimgmt_rke2_version        = "v1.23.10+rke2r1"
  capimgmt_max_pods            = 300
  capimgmt_node_cidr_mask_size = 22
  capimgmt_san                 = "upstream.local.gd"
  capimgmt_local_port          = 6443

  dockerhost_instance_type       = "t3.xlarge"
  dockerhost_ami                 = "ami-09744628bed84e434" // Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-03-25
  dockerhost_server_count        = 1

  capi_docker_provider_version = "v99.1.0-rich1"

  project_name         = var.project_name
  ssh_private_key_path = "~/.ssh/id_ed25519"
  ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
}