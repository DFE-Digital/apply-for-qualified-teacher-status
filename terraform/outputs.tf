output "apply_for_qts_in_england_fqdn" {
  value = "${cloudfoundry_route.apply_qts_public.hostname}.${data.cloudfoundry_domain.cloudapps.name}"
}
