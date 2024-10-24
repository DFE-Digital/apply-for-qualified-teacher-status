provider "google" {
  project = "apply-for-qts-in-england"
}

module "dfe_analytics" {
  source = "./vendor/modules/dfe-terraform-modules//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = "${var.app_environment}${var.app_suffix}"
  gcp_taxonomy_id       = 5456044749211275650
  gcp_policy_tag_id     = 2399328962407973209
  gcp_keyring           = "afqts-key-ring"
  gcp_key               = "afqts-key"
}
