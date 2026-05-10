resource "azurerm_container_registry" "devops_with_ai_acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  tags                = var.tags
}