variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy the cluster into"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster API server"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for nodes — Standard_D2s_v3 is the recommended minimum for AKS; Standard_B2s is not supported in AKS node pools"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags to apply to all AKS resources"
  type        = map(string)
  default     = {}
}
