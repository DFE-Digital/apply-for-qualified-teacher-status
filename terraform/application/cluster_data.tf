module "cluster_data" {
  source = "./vendor/modules/dfe-terraform-modules//aks/cluster_data"
  name   = var.cluster
}
