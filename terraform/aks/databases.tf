module "redis" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=testing"

  namespace             = var.namespace
  environment           = "${var.app_environment}${var.app_suffix}"
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}