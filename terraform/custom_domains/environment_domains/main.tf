module "domains" {
  source              = "git::https://github.com/DFE-Digital/terraform-modules.git//domains/environment_domains?ref=0.5.4"
  zone                = var.zone
  front_door_name     = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains
  environment         = var.environment_short
  host_name           = data.azurerm_linux_web_app.app.default_hostname
  rule_set_ids        = [azurerm_cdn_frontdoor_rule_set.ruleset.id]

}

data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}

data "azurerm_linux_web_app" "app" {
  provider            = azurerm.app_subcription
  name                = var.app_name
  resource_group_name = var.app_resource_group_name
}

data "azurerm_dns_zone" "main" {
  name                = var.zone
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_rule_set" "ruleset" {
  name                     = var.environment_short
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_rule" "rule" {
  for_each = var.redirect_rules
  depends_on = [module.domains]
  name                      = replace(
                                replace(each.key, ".", ""),
                                "-", "")
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.ruleset.id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {

    url_redirect_action {
      redirect_type        = "Moved"
      redirect_protocol    = "Https"
      destination_hostname = each.value
    }
  }

  conditions {
    host_name_condition {
      operator         = "Equal"
      match_values     = [each.key]
    }
  }
}
