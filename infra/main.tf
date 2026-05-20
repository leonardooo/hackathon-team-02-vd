terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Usar Managed Identity em runtime — sem client_secret no código
}

locals {
  # Tags padrão SIFAP obrigatórias em todos os recursos
  default_tags = merge(var.tags, {
    project     = "sifap"
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  })
}

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  tags                = local.default_tags
}
