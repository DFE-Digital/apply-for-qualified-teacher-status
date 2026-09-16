locals {
  azure_credentials = try(jsondecode(var.azure_sp_credentials_json), null)
}

provider "azurerm" {
  subscription_id = try(local.azure_credentials.subscriptionId, null)
  client_id       = try(local.azure_credentials.clientId, null)
  client_secret   = try(local.azure_credentials.clientSecret, null)
  tenant_id       = try(local.azure_credentials.tenantId, null)

  resource_provider_registrations = "none"

  features {}
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = module.cluster_data.kubelogin_args
  }
}

provider "statuscake" {
  api_token = module.infrastructure_secrets.map.STATUSCAKE-API-TOKEN
}

provider "airbyte" {
  # Configuration options
  server_url    = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}/api/public/v1" : ""
  client_id     = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-CLIENT-ID : ""
  client_secret = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-CLIENT-SECRET : ""
}
