locals {
  environment = "${var.app_environment}${var.app_suffix}"
}

module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=testing"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url

    AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.uploads.name,
    AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.uploads.primary_access_key,
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name
  }
}
