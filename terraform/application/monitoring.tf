locals {
  external_url = var.external_hostname != null ? "https://${var.external_hostname}" : null
}

module "statuscake" {
  count = var.enable_monitoring ? 1 : 0

  source = "./vendor/modules/dfe-terraform-modules//monitoring/statuscake"

  uptime_urls = compact([module.web_application.probe_url, local.external_url])
  ssl_urls    = compact([local.external_url])

  contact_groups = [288912, 282453]
}
