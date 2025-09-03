output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "acr_name" {
  value = module.acr.acr_name
}

output "aks_name" {
  value = module.aks.cluster_name
}

output "kubeconfig" {
  value     = module.aks.kube_config_raw
  sensitive = true
}
