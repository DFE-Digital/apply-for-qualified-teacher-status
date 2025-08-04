locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "apply-for-qts"
}

module "application_configuration" {
  source = "./vendor/modules/dfe-terraform-modules//aks/application_configuration"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  is_rails_application = true

  config_variables = merge(
    local.environment_variables,
    {
      HOSTING_ENVIRONMENT = local.environment

      BIGQUERY_PROJECT_ID = var.bigquery_federated_auth ? module.dfe_analytics[0].bigquery_project_id : "apply-for-qts-in-england"
      BIGQUERY_DATASET    = var.bigquery_federated_auth ? module.dfe_analytics[0].bigquery_dataset : "events_${var.app_environment}"
      BIGQUERY_TABLE_NAME = var.bigquery_federated_auth ? module.dfe_analytics[0].bigquery_table_name : "events"
  })

  secret_key_vault_short = "app"
  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url

    AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.uploads.name
    AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.uploads.primary_access_key
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name

    GOOGLE_CLOUD_CREDENTIALS = var.bigquery_federated_auth ? module.dfe_analytics[0].google_cloud_credentials : null
  }
}

module "web_application" {
  source = "./vendor/modules/dfe-terraform-modules//aks/application"

  name   = "web"
  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image    = var.docker_image
  replicas        = var.app_replicas
  enable_logit    = var.enable_logit
  run_as_non_root = var.run_as_non_root
}

module "worker_application" {
  source = "./vendor/modules/dfe-terraform-modules//aks/application"

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

  enable_logit    = var.enable_logit
  enable_gcp_wif  = var.bigquery_federated_auth ? true : null
  run_as_non_root = var.run_as_non_root
}
