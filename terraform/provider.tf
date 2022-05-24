locals {
  azure_credentials                 = try(jsondecode(var.azure_sp_credentials_json), null)
  application_environment_variables = yamldecode(data.azurerm_key_vault_secret.secrets["APPLY-QTS-APP-VARIABLES"].value)
}

provider "azurerm" {
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
  skip_provider_registration = true

  features {}
}

provider "cloudfoundry" {
  api_url  = var.paas_api_url
  user     = data.azurerm_key_vault_secret.secrets["PAAS-USER"].value
  password = data.azurerm_key_vault_secret.secrets["PAAS-PASSWORD"].value
}
