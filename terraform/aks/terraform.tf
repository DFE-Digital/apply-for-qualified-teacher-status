terraform {
  required_version = "1.5.0"

  backend "azurerm" {}

  required_providers {
    statuscake = {
      source = "StatusCakeDev/statuscake"
    }
  }
}
