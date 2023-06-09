output "url" {
  value = "https://${module.web_application.hostname}"
}

output "postgres_azure_backup_storage_account_name" {
  value = module.postgres.azure_backup_storage_account_name
}

output "postgres_azure_backup_storage_container_name" {
  value = module.postgres.azure_backup_storage_container_name
}
