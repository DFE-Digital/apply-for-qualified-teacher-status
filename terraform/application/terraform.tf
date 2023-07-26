terraform {
  required_version = "1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.64.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.21.1"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "= 2.1.0"
    }
  }

  backend "azurerm" {
    container_name = "afqts-tfstate"
  }
}
