output "storage_account_name" {
  description = "Copy this value into the backend block in ../main.tf"
  value       = azurerm_storage_account.tfstate.name
}

output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
