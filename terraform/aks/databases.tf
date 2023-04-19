resource "random_string" "postgres_username" {
  length  = 16
  special = false
  upper   = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = true
}

module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=aks-postgres"

  namespace             = var.namespace
  environment           = "${var.app_environment}${var.app_suffix}"
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  admin_username = random_string.postgres_username.result
  admin_password = random_password.postgres_password.result

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}
