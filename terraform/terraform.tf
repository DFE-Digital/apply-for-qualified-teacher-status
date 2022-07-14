terraform {
  required_version = "~> 1.0"

  backend "azurerm" {
    container_name = "afqts-tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.84"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.15"
    }

    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "1.0.1"
    }
  }
}
