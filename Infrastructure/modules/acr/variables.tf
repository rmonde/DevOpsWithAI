variable "acr_name" {
  type        = string
  default     = ""
  description = "Name of the Container Registry"
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = ""
  description = "Location of the resource group"
}

variable "acr_sku" {
  type        = string
  default     = "Basic"
  description = "SKU of the Container Registry"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the Container Registry"
}