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

variable "rate_limit" {
  type = list(object({
    agent        = optional(string)
    priority     = optional(number)
    duration     = optional(number)
    limit        = optional(number)
    selector     = optional(string)
    operator     = optional(string)
    match_values = optional(string)
  }))
  default = null
}

variable "rate_limit_max" {
  type    = string
  default = null
}

locals {
  hostname = "${var.domains[0]}.${var.zone}"
}
