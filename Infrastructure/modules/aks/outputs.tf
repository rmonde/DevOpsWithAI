output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.devops_with_ai_aks.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for kubectl"
  value       = azurerm_kubernetes_cluster.devops_with_ai_aks.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "AKS API server endpoint"
  value       = azurerm_kubernetes_cluster.devops_with_ai_aks.kube_config[0].host
  sensitive   = true
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the cluster's system-assigned managed identity"
  value       = azurerm_kubernetes_cluster.devops_with_ai_aks.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity — this is what pulls images from ACR, not the cluster identity"
  value       = azurerm_kubernetes_cluster.devops_with_ai_aks.kubelet_identity[0].object_id
}
