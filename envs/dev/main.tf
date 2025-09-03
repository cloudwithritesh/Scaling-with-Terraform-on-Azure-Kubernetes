terraform {
  backend "local" {}
}

locals {
  name     = var.name
  location = var.location
  tags     = {
    Environment = "dev"
    Project     = "aks-demo"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = local.location
  tags     = local.tags
}

module "network" {
  source              = "../../modules/network"
  name                = local.name
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  tags                = local.tags
}

resource "random_string" "acr" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

module "acr" {
  source              = "../../modules/acr"
  name                = "${replace(local.name,"-","")}${random_string.acr.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  tags                = local.tags
}

module "aks" {
  source              = "../../modules/aks"
  name                = "${local.name}-aks"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_ids[0]
  kubernetes_version  = var.kubernetes_version
  system_node_count   = var.system_node_count
  user_node_min       = var.user_node_min
  user_node_max       = var.user_node_max
  acr_id              = module.acr.acr_id
  dns_service_ip      = var.dns_service_ip
  service_cidr        = var.service_cidr
  tags                = local.tags
}

# Kube + Helm providers configured from the created cluster
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(yamldecode(module.aks.kube_config_raw).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(module.aks.kube_config_raw).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(module.aks.kube_config_raw).clusters[0].cluster.certificate-authority-data)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(yamldecode(module.aks.kube_config_raw).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(module.aks.kube_config_raw).users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(module.aks.kube_config_raw).clusters[0].cluster.certificate-authority-data)
  }
}

# NGINX Ingress via Helm (run manually)
# helm_release "nginx_ingress" removed for simplicity

output "kubeconfig" {
  description = "Raw kubeconfig to use with kubectl"
  value       = module.aks.kube_config_raw
  sensitive   = true
}
