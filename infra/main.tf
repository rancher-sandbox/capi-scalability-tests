terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    tls = {
      source = "hashicorp/tls"
    }
    random = {
      source = "hashicorp/random"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "helm" {
  kubernetes {
    host                   = "https://${local.capimgmt_san}:6443"
    client_certificate     = module.secrets.master_user_cert
    client_key             = module.secrets.master_user_key
    cluster_ca_certificate = module.secrets.cluster_ca_certificate
  }
}

module "aws_shared" {
  source              = "./aws_shared"
  project_name        = local.project_name
  ssh_public_key_path = local.ssh_public_key_path
}

module "aws_network" {
  source            = "./aws_network"
  region            = local.region
  availability_zone = local.availability_zone
  project_name      = local.project_name
}

module "secrets" {
  source = "./secrets"
}

module "bastion" {
  depends_on            = [module.aws_network]
  source                = "./aws_host"
  ami                   = local.bastion_ami
  instance_type         = local.bastion_instance_type
  availability_zone     = local.availability_zone
  project_name          = local.project_name
  name                  = "bastion"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = local.ssh_private_key_path
  subnet_id             = module.aws_network.public_subnet_id
  vpc_security_group_id = module.aws_network.public_security_group_id
}

module "capimgmt_server_nodes" {
  depends_on            = [module.aws_network]
  count                 = local.capimgmt_server_count
  source                = "./aws_host"
  ami                   = local.capimgmt_ami
  instance_type         = local.capimgmt_instance_type
  availability_zone     = local.availability_zone
  project_name          = local.project_name
  name                  = "capi-management-server-node-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = local.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
  ssh_tunnels           = count.index == 0 ? [[local.capimgmt_local_port, 6443], [3000, 443]] : []
}

module "capimgmt_agent_nodes" {
  depends_on            = [module.aws_network]
  count                 = local.capimgmt_agent_count
  source                = "./aws_host"
  ami                   = local.capimgmt_ami
  instance_type         = local.capimgmt_instance_type
  availability_zone     = local.availability_zone
  project_name          = local.project_name
  name                  = "capi-management-agent-node-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = local.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
}

module "capimgmt_rke2" {
  source       = "./rke2"
  project      = local.project_name
  name         = "capimgmt"
  server_names = [for node in module.capimgmt_server_nodes : node.private_name]
  agent_names  = [for node in module.capimgmt_agent_nodes : node.private_name]
  sans         = [local.capimgmt_san]

  ssh_private_key_path = local.ssh_private_key_path
  ssh_bastion_host     = module.bastion.public_name
  ssh_local_port       = local.capimgmt_local_port

  rke2_version        = local.capimgmt_rke2_version
  max_pods            = local.capimgmt_max_pods
  node_cidr_mask_size = local.capimgmt_node_cidr_mask_size

  client_ca_key          = module.secrets.client_ca_key
  client_ca_cert         = module.secrets.client_ca_cert
  server_ca_key          = module.secrets.server_ca_key
  server_ca_cert         = module.secrets.server_ca_cert
  request_header_ca_key  = module.secrets.request_header_ca_key
  request_header_ca_cert = module.secrets.request_header_ca_cert
  master_user_cert       = module.secrets.master_user_cert
  master_user_key        = module.secrets.master_user_key
}

module "capimgmt_install" {
  depends_on              = [module.capimgmt_rke2]
  source                  = "./capi_management"
  server_names            = [for node in module.capimgmt_server_nodes : node.private_name]
  docker_provider_version = local.capi_docker_provider_version
  
  ssh_private_key_path    = local.ssh_private_key_path
  ssh_bastion_host        = module.bastion.public_name
}

module "docker_hosts" {
  depends_on            = [module.aws_network]
  count                 = local.dockerhost_server_count
  source                = "./aws_host"
  ami                   = local.dockerhost_ami
  instance_type         = local.dockerhost_instance_type
  availability_zone     = local.availability_zone
  project_name          = local.project_name
  name                  = "docker-host-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = local.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
}

module "docker_install" {
  depends_on            = [module.docker_hosts]
  source                = "./docker"

  server_names          = [for node in module.docker_hosts : node.private_name]
  private_ips           = [for node in module.docker_hosts : node.private_ip]

  ssh_private_key_path    = local.ssh_private_key_path
  ssh_bastion_host        = module.bastion.public_name
}

module "observability_install" {
  depends_on              = [module.docker_install]
  source                  = "./observability"
}