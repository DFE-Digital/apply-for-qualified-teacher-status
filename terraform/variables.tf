variable "environment_name" {
  type = string
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

variable "postgres_database_service_plan" {
  type    = string
  default = "small-13"
}

variable "redis_service_plan" {
  type    = string
  default = "tiny-6_x"
}

locals {
  apply_qts_routes = flatten([
    cloudfoundry_route.apply_qts_public
  ])

  apply_qts_app_name     = "apply-for-qts-in-england-${var.environment_name}"
  postgres_database_name = "apply-for-qts-in-england-${var.environment_name}-pg-svc"
  redis_database_name    = "apply-for-qts-in-england-${var.environment_name}-redis-svc"
}
