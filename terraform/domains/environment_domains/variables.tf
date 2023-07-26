variable "zone" {
  type        = string
  description = "Name of DNS zone"
  default     = "apply-for-qts-in-england.education.gov.uk"
}

variable "front_door_name" {
  type        = string
  description = "Name of Azure Front Door"
  default     = "s189p01-afqtsdomains-fd"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resouce group name"
  default     = "s189p01-afqtsdomains-rg"
}

variable "domains" {
  description = "List of domains record names"
}

variable "environment_tag" {
  type        = string
  description = "Environment"
}

variable "environment_short" {
  type        = string
  description = "Short name for environment"
}

variable "origin_hostname" {
  type        = string
  description = "Origin endpoint url"
}

locals {
  hostname = "${var.domains[0]}.${var.zone}"
}
