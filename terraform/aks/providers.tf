locals {
  azure_credentials = try(jsondecode(var.azure_sp_credentials_json), null)
}

provider "azurerm" {
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
  skip_provider_registration = true

  features {}
}
