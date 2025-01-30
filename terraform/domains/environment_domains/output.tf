output "external_urls" {
  value = flatten([
    for domain in var.domains : (domain == "apex" ?
      "https://${var.zone}" :
      "https://${domain}.${var.zone}"
    )
  ])
}
