output "url" {
  value = module.web_application.url
}

output "external_urls" {
  value = [
    module.web_application.url
  ]
}

output "postgres_azure_backup_storage_account_name" {
  value = module.postgres.azure_backup_storage_account_name
}

output "postgres_azure_backup_storage_container_name" {
  value = module.postgres.azure_backup_storage_container_name
}

output "azure_storage_account_name" {
  value = azurerm_storage_account.uploads.name
}

output "azure_storage_access_key" {
  value     = azurerm_storage_account.uploads.primary_access_key
  sensitive = true
}

output "azure_storage_container" {
  value = azurerm_storage_container.uploads.name
}
