terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # After running bootstrap/, copy the storage_account_name output here.
  # Then run: terraform init
  backend "azurerm" {
    resource_group_name  = "rg-devopswithai-tfstate"
    storage_account_name = "tfstate7i2czd"
    container_name       = "tfstate"
    key                  = "devopswithai.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "aks" {
  source              = "./modules/aks"
  cluster_name        = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  tags                = var.tags
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_registry_name
  location            = var.location
  resource_group_name = var.acr_resource_group_name
  acr_sku             = var.acr_sku
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = module.acr.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}
