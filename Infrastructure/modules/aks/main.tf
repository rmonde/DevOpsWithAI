resource "azurerm_kubernetes_cluster" "devops_with_ai_aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name         = "system"
    node_count   = var.node_count
    vm_size      = var.node_vm_size
    # Default Azure CNI limit is 30 pods/node which is too low when running
    # Prometheus stack + ArgoCD + app services simultaneously.
    max_pods     = 50
  }

  # System-assigned managed identity — Azure handles credential rotation automatically.
  # This is simpler than a service principal and is the current recommended approach.
  identity {
    type = "SystemAssigned"
  }

  # Azure auto-enables OIDC issuer on managed clusters; omitting this causes
  # Terraform to try disabling it, which Azure rejects with OIDCIssuerFeatureCannotBeDisabled.
  oidc_issuer_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = var.tags
}
