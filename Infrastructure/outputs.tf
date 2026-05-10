output "resource_group_name" {
  description = "Main resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_get_credentials_command" {
  description = "Run this after apply to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}

output "kube_config_raw" {
  description = "Raw kubeconfig (sensitive)"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "cluster_identity_principal_id" {
  description = "Managed identity principal ID — needed if you attach an ACR later"
  value       = module.aks.cluster_identity_principal_id
}
