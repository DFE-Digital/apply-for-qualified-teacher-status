variable "zone" {
  type        = string
  description = "Name of DNS zone"
}
variable "front_door_name" {
  type        = string
  description = "Name of Azure Front Door"
}
variable "resource_group_name" {
  type        = string
  description = "Name of resouce group name"
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
