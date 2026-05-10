variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for the state storage account"
  type        = string
  default     = "eastus"
}
