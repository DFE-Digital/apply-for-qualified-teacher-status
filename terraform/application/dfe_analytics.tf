module "dfe_analytics" {
  source = "./vendor/modules/dfe-terraform-modules//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = "${var.app_environment}${var.app_suffix}"
  gcp_dataset           = "events_${var.app_environment}"
  gcp_project_id        = "apply-for-qts-in-england"
  gcp_project_number    = 385922361840
}
