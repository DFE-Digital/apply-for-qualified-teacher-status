variable "gcp_dataset" {
  default = null
}
variable "gcp_keyring" {
  default = null
}
variable "gcp_key" {
  default = null
}
variable "gcp_project" {}
variable "gcp_project_number" {}
variable "gcp_table_deletion_protection" {
  default = true
}

locals {
  # Global constants
  gcp_region           = "europe-west2"
  gcp_table_name       = "events"
  gcp_workload_id_pool = "azure-cip-identity-pool"

  gcp_key_ring               = "bigquery-${var.service_short}-${local.environment}-2"
  gcp_key                    = "bigquery-${var.service_short}-${local.environment}-2"
  gcp_dataset_name           = var.gcp_dataset == null ? replace("${var.service_short}_events_${local.environment}_spike", "-", "_") : var.gcp_dataset
  gcp_principal              = "principal://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${local.gcp_workload_id_pool}"
  gcp_principal_with_subject = "${local.gcp_principal}/subject/${data.azurerm_user_assigned_identity.gcp_wif.principal_id}"

  gcp_credentials_map = {
    universe_domain    = "googleapis.com"
    type               = "external_account"
    audience           = "//iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/azure-cip-identity-pool/providers/azure-cip-oidc-provider"
    subject_token_type = "urn:ietf:params:oauth:token-type:jwt"
    token_url          = "https://sts.googleapis.com/v1/token"
    credential_source = {
      url = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
    }
    service_account_impersonation_url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.appender.email}:generateAccessToken"
    service_account_impersonation = {
      token_lifetime_seconds = 3600
    }
  }
  gcp_credentials = jsonencode(local.gcp_credentials_map)
}

provider "google" {
  project = var.gcp_project
  region  = local.gcp_region
}

# data "google_project" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "gcp_wif" {
  name                = "${var.azure_resource_prefix}-gcp-wif-${var.cluster}-${var.namespace}-id"
  resource_group_name = "s189t01-tsc-ts-rg" # This could be an output of cluster data module
}

resource "google_service_account" "appender" {
  account_id   = "appender-${var.service_short}-${local.environment}"
  display_name = "Service Account appender to ${local.service_name} in ${local.environment} environment"
}

resource "google_service_account_iam_binding" "appender" {
  service_account_id = google_service_account.appender.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    local.gcp_principal_with_subject
  ]
}

# Create key ring if it doesn't exist
resource "google_kms_key_ring" "bigquery" {
  count = var.gcp_keyring == null ? 1 : 0

  name     = local.gcp_key_ring
  location = local.gcp_region
}

# Create key if it doesn't exist
resource "google_kms_crypto_key" "bigquery" {
  count = var.gcp_key == null ? 1 : 0

  name     = local.gcp_key
  key_ring = google_kms_key_ring.bigquery[0].id
}

# Add permission if key didn't exist
data "google_bigquery_default_service_account" "main" {}
resource "google_kms_crypto_key_iam_member" "bigquery" {
  count = var.gcp_key == null ? 1 : 0

  crypto_key_id = google_kms_crypto_key.bigquery[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_bigquery_default_service_account.main.email}"
}

# Create dataset if it doesn't exist
resource "google_bigquery_dataset" "main" {
  count = var.gcp_dataset == null ? 1 : 0

  dataset_id = local.gcp_dataset_name
  location   = local.gcp_region
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key_iam_member.bigquery[0].crypto_key_id
  }
}

# Add service account permission to dataset, wether we create it or it already exists
resource "google_bigquery_dataset_iam_binding" "appender" {
  dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
  role       = "projects/${var.gcp_project}/roles/bigquery_appender_custom"

  members = [
    "serviceAccount:${google_service_account.appender.email}",
  ]
}

# Create table if dataset doesn't exist
resource "google_bigquery_table" "events" {
  count = var.gcp_dataset == null ? 1 : 0

  dataset_id               = google_bigquery_dataset.main[0].dataset_id
  table_id                 = local.gcp_table_name
  description              = "Events streamed into the BigQuery from the application"
  clustering               = ["event_type"]
  deletion_protection      = var.gcp_table_deletion_protection
  require_partition_filter = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key_iam_member.bigquery[0].crypto_key_id
  }

  time_partitioning {
    type  = "DAY"
    field = "occurred_at"
  }

  # https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/create-events-table.sql
  schema = file("${path.module}/config/events.json")
}
