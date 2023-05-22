locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "apply-for-qts"
}

module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=testing"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  config_variables = {
    HOSTING_ENVIRONMENT = var.app_environment

    RAILS_SERVE_STATIC_FILES = "true"

    BIGQUERY_PROJECT_ID = "apply-for-qts-in-england",
    BIGQUERY_DATASET    = "events_${var.app_environment}",
    BIGQUERY_TABLE_NAME = "events",
  }

  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url

    AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.uploads.name,
    AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.uploads.primary_access_key,
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name

    DQT_API_URL = var.dqt_api_url
  }
}

module "web_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=testing"

  name   = "web"
  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
}

module "worker_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=testing"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image  = var.docker_image
  command       = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]
  probe_command = ["pgrep", "-f", "sidekiq"]
}
