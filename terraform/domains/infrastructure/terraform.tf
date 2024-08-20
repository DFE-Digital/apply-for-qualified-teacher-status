terraform {
  required_version = "1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }

  backend "azurerm" {
    container_name       = "afqtsdomains-tf"
    resource_group_name  = "s189p01-afqtsdomains-rg"
    storage_account_name = "s189p01afqtsdomainstf"
    key                  = "afqtsdomains.tfstate"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}
