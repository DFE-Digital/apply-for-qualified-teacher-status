locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "apply-for-qts"
}

module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=aks-application-configuration"

  namespace             = var.namespace
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url
  }
}

module "web_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=aks-application"

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
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=aks-application"

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
