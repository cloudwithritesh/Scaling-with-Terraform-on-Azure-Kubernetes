variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "sku" { type = string, default = "Basic" }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags
}

output "acr_id"   { value = azurerm_container_registry.acr.id }
output "acr_name" { value = azurerm_container_registry.acr.name }
