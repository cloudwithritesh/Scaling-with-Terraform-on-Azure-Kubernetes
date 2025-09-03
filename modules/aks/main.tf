variable "name"               { type = string }
variable "location"           { type = string }
variable "resource_group_name"{ type = string }
variable "subnet_id"          { type = string }
variable "kubernetes_version" { type = string, default = "1.29.7" }
variable "system_node_count"  { type = number, default = 1 }
variable "user_node_min"      { type = number, default = 0 }
variable "user_node_max"      { type = number, default = 3 }
variable "acr_id"             { type = string }
variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}
variable "service_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
variable "docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns"

  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  identity { type = "SystemAssigned" }

  default_node_pool {
    name                = "systemnp"
    vm_size             = "Standard_D4s_v5"
    node_count          = var.system_node_count
    type                = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
    vnet_subnet_id      = var.subnet_id
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
  }

  lifecycle {
    ignore_changes = [ default_node_pool[0].node_count ]
  }
}

# User node pool with autoscaler
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4s_v5"
  enable_auto_scaling   = true
  min_count             = var.user_node_min
  max_count             = var.user_node_max
  mode                  = "User"
  vnet_subnet_id        = var.subnet_id
}

data "azurerm_client_config" "current" {}

# Grant AKS pull to ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
