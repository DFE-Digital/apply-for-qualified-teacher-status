terraform {
  required_version = "1.4.5"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}
