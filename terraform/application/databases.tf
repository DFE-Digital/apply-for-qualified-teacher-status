module "redis" {
  source = "./vendor/modules/dfe-terraform-modules//aks/redis"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}

module "postgres" {
  source = "./vendor/modules/dfe-terraform-modules//aks/postgres"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure                = var.deploy_azure_backing_services
  azure_enable_monitoring  = var.enable_monitoring
  azure_extensions         = ["pg_stat_statements", "pgcrypto"]
  azure_maintenance_window = var.azure_maintenance_window
}
