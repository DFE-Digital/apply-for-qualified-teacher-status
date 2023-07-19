terraform {
  required_version = "1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }
  }

  backend "azurerm" {
    container_name = "afqtsdomains-tf"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}
