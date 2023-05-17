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

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = "https://${var.capimgmt_san}:6443"
    client_certificate     = module.secrets.master_user_cert
    client_key             = module.secrets.master_user_key
    cluster_ca_certificate = module.secrets.cluster_ca_certificate
  }
}

provider "kubectl" {
  host                   = "https://${var.capimgmt_san}:6443"
  cluster_ca_certificate = module.secrets.cluster_ca_certificate
  client_certificate     = module.secrets.master_user_cert
  client_key             = module.secrets.master_user_key
  load_config_file       = false
}

module "aws_shared" {
  source              = "./aws_shared"
  project_name        = var.project_name
  ssh_public_key_path = var.ssh_public_key_path
}

module "aws_network" {
  source            = "./aws_network"
  region            = var.region
  availability_zone = var.availability_zone
  project_name      = var.project_name
}

module "secrets" {
  source = "./secrets"
}

module "bastion" {
  depends_on            = [module.aws_network]
  source                = "./aws_host"
  ami                   = var.bastion_ami
  instance_type         = var.bastion_instance_type
  availability_zone     = var.availability_zone
  project_name          = var.project_name
  name                  = "bastion"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = var.ssh_private_key_path
  subnet_id             = module.aws_network.public_subnet_id
  vpc_security_group_id = module.aws_network.public_security_group_id
}

module "capimgmt_server_nodes" {
  depends_on            = [module.aws_network]
  count                 = var.capimgmt_server_count
  source                = "./aws_host"
  ami                   = var.capimgmt_ami
  instance_type         = var.capimgmt_instance_type
  availability_zone     = var.availability_zone
  project_name          = var.project_name
  name                  = "capi-management-server-node-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = var.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
  ssh_tunnels           = count.index == 0 ? [[var.capimgmt_local_port, 6443], [3000, 443]] : []
}

module "capimgmt_agent_nodes" {
  depends_on            = [module.aws_network]
  count                 = var.capimgmt_agent_count
  source                = "./aws_host"
  ami                   = var.capimgmt_ami
  instance_type         = var.capimgmt_instance_type
  availability_zone     = var.availability_zone
  project_name          = var.project_name
  name                  = "capi-management-agent-node-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = var.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
}

module "capimgmt_rke2" {
  source       = "./rke2"
  project      = var.project_name
  name         = "capimgmt"
  server_names = [for node in module.capimgmt_server_nodes : node.private_name]
  agent_names  = [for node in module.capimgmt_agent_nodes : node.private_name]
  sans         = [var.capimgmt_san]

  ssh_private_key_path = var.ssh_private_key_path
  ssh_bastion_host     = module.bastion.public_name
  ssh_local_port       = var.capimgmt_local_port

  rke2_version        = var.capimgmt_rke2_version
  max_pods            = var.capimgmt_max_pods
  node_cidr_mask_size = var.capimgmt_node_cidr_mask_size

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
  
  capi_infra_providers    = var.capi_infra_providers
  capi_kube_api_burst     = var.capi_kube_api_burst
  capi_kube_api_qps       = var.capi_kube_api_qps
  capi_concurrency        = var.capi_concurrency
  
  ssh_private_key_path    = var.ssh_private_key_path
  ssh_bastion_host        = module.bastion.public_name
}

module "docker_hosts" {
  depends_on            = [module.aws_network]
  count                 = var.dockerhost_server_count
  source                = "./aws_host"
  ami                   = var.dockerhost_ami
  instance_type         = var.dockerhost_instance_type
  availability_zone     = var.availability_zone
  project_name          = var.project_name
  name                  = "docker-host-${count.index}"
  ssh_key_name          = module.aws_shared.key_name
  ssh_private_key_path  = var.ssh_private_key_path
  subnet_id             = module.aws_network.private_subnet_id
  vpc_security_group_id = module.aws_network.private_security_group_id
  ssh_bastion_host      = module.bastion.public_name
}

module "docker_install" {
  depends_on            = [module.docker_hosts]
  source                = "./docker_install"

  server_names          = [for node in module.docker_hosts : node.private_name]
  private_ips           = [for node in module.docker_hosts : node.private_ip]

  ssh_private_key_path    = var.ssh_private_key_path
  ssh_bastion_host        = module.bastion.public_name
}

module "docker_node_exporter" {
  depends_on            = [module.docker_hosts]
  source                = "./node_exporter"
  count                 = var.dockerhost_deploy_nodeexporter ? 1 : 0

  server_names          = [for node in module.docker_hosts : node.private_name]
  private_ips           = [for node in module.docker_hosts : node.private_ip]

  ssh_private_key_path    = var.ssh_private_key_path
  ssh_bastion_host        = module.bastion.public_name
}

module "observability_install" {
  depends_on              = [
    module.capimgmt_install,
    module.docker_node_exporter
  ]
  source                  = "./observability"

  docker_hosts = [for node in module.docker_hosts : node.private_name]
}