module "domains" {
  source              = "./vendor/modules/domains//domains/environment_domains"
  zone                = var.zone
  front_door_name     = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains
  environment         = var.environment_short
  host_name           = var.origin_hostname
}

data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}

data "azurerm_dns_zone" "main" {
  name                = var.zone
  resource_group_name = var.resource_group_name
}
