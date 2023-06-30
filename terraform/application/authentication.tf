resource "azuread_application" "main" {
  count = var.enable_sign_in_with_active_directory ? 1 : 0

  display_name = "Apply for QTS in England"
  description  = "Sign in to Apply for QTS in England."

  web {
    redirect_uris = ["https://${coalesce(var.external_hostname, module.web_application.hostname)}/staff/auth/azure_activedirectory_v2/callback"]
  }
}

resource "time_rotating" "six_months" {
  count = var.enable_sign_in_with_active_directory ? 1 : 0

  rotation_days = 180
}

resource "azuread_application_password" "main" {
  count = var.enable_sign_in_with_active_directory ? 1 : 0

  application_object_id = azuread_application.main[0].object_id

  rotate_when_changed = {
    rotation = time_rotating.six_months[0].id
  }
}
