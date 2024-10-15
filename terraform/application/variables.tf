variable "app_environment" {
  type = string
}

variable "app_replicas" {
  type        = number
  description = "Number of replicas of the web app"
  default     = 1
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "azure_resource_prefix" {
  type = string
}

variable "azure_maintenance_window" {
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "cluster" {
  type = string
}

variable "config_short" {
  type = string
}

variable "deploy_azure_backing_services" {
  type    = string
  default = true
}

variable "docker_image" {
  type = string
}

variable "enable_logit" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "external_hostname" {
  type    = string
  default = null
}

variable "namespace" {
  type = string
}

variable "service_short" {
  type = string
}

variable "uploads_container_delete_retention_days" {
  default = 7
  type    = number
}

variable "uploads_storage_environment_tag" {
  type = string
}

variable "uploads_storage_account_name" {
  type    = string
  default = null
}

locals {
  environment_variables = yamldecode(file("${path.module}/config/${var.app_environment}/variables.yml"))
}
