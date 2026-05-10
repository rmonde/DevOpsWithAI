output "acr_name" {
  value = azurerm_container_registry.devops_with_ai_acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.devops_with_ai_acr.login_server
}

output "acr_id" {
  description = "Full resource ID of the ACR — used to scope the AcrPull role assignment"
  value       = azurerm_container_registry.devops_with_ai_acr.id
}