variable "app_environment" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "azure_resource_prefix" {
  type = string
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

variable "dqt_api_url" {
  type = string
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "enable_sign_in_with_active_directory" {
  type    = bool
  default = false
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
