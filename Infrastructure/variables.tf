variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the main resource group"
  type        = string
  default     = "rg-devopswithai"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-devopswithai"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS API server URL"
  type        = string
  default     = "devopswithai"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "devopswithai"
    environment = "learning"
  }
}

variable "acr_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acrdevopswithai"
}

variable "acr_resource_group_name" {
  description = "Resource group the ACR lives in — can differ from the main AKS resource group"
  type        = string
}

variable "acr_sku" {
  description = "ACR SKU — Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}
