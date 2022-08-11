variable "environment_name" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}
variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "paas_api_url" {
  default = "https://api.london.cloud.service.gov.uk"
}

variable "paas_org_name" {
  type    = string
  default = "dfe"
}

variable "paas_space" {
  type = string
}

variable "apply_qts_docker_image" {
  type = string
}

variable "apply_qts_instances" {
  default = 1
}

variable "apply_qts_memory" {
  default = "1024"
}

variable "apply_qts_disk_quota" {
  default = "2048"
}
variable "enable_external_logging" {
  type    = bool
  default = true
}

variable "postgres_database_service_plan" {
  type    = string
  default = "small-13"
}

variable "paas_restore_db_from_db_instance" {
  default = ""
}

variable "paas_restore_db_from_point_in_time_before" {
  default = ""
}

variable "redis_service_plan" {
  type    = string
  default = "tiny-6_x"
}

variable "education_hostnames" {
  type    = list(any)
  default = []
}

variable "prometheus_app" {
  default = null
}

variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

variable "forms_container_delete_retention_days" {
  default = 7
  type    = number
}

variable "forms_storage_account_name" {
  default = null
}

variable "region_name" {
  default = "west europe"
  type    = string
}

variable env_config {}

variable app_config_file { default = "workspace_variables/app_config.yml" }

locals {
  apply_qts_routes = flatten([
    cloudfoundry_route.apply_qts_public,
    cloudfoundry_route.apply_qts_internal,
    values(cloudfoundry_route.education)
  ])

  apply_qts_app_name     = "apply-for-qts-in-england-${var.environment_name}${var.app_suffix}"
  postgres_database_name = "apply-for-qts-in-england-${var.environment_name}${var.app_suffix}-pg-svc"
  redis_database_name    = "apply-for-qts-in-england-${var.environment_name}${var.app_suffix}-redis-svc"
  logging_service_name   = "apply-for-qts-in-england-logit-ssl-drain-${var.environment_name}${var.app_suffix}"

  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres.id,
    cloudfoundry_service_instance.redis.id,
  ]
  app_user_provided_service_bindings = var.enable_external_logging ? [cloudfoundry_user_provided_service.logging.id] : []
  app_service_bindings               = concat(local.app_cloudfoundry_service_instances, local.app_user_provided_service_bindings)
  bigquery_project_id                = "apply-for-qts-in-england"
  bigquery_dataset                   = "events_${var.environment_name}"
  bigquery_table_name                = "events"

  restore_db_backup_params = var.paas_restore_db_from_db_instance != "" ? {
    restore_from_point_in_time_of     = var.paas_restore_db_from_db_instance
    restore_from_point_in_time_before = var.paas_restore_db_from_point_in_time_before
  } : {}
  app_config    = yamldecode(file(var.app_config_file))[var.env_config]
}
