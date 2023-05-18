locals {
  uploads_storage_product_name = "Apply for QTS in England"
}

resource "azurerm_storage_account" "uploads" {
  name                              = "${var.azure_resource_prefix}${var.service_short}uploads${var.config_short}sa"
  resource_group_name               = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  location                          = "UK South"
  account_replication_type          = var.app_environment != "production" ? "LRS" : "GRS"
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true

  tags = {
    Environment        = var.uploads_storage_environment_tag
    Product            = local.uploads_storage_product_name
    "Service Offering" = local.uploads_storage_product_name
  }

  blob_properties {
    last_access_time_enabled = true

    container_delete_retention_policy {
      days = var.uploads_container_delete_retention_days
    }
  }
}

resource "azurerm_storage_encryption_scope" "uploads" {
  name                               = "microsoftmanaged"
  storage_account_id                 = azurerm_storage_account.uploads.id
  source                             = "Microsoft.Storage"
  infrastructure_encryption_required = true
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.uploads.name
  container_access_type = "private"
}
