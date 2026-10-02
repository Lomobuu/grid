resource "azuread_application" "app" {
  display_name = "kappa"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_password" "app" {
  application_id = azuread_application.app.id
  display_name   = "terraform-secret"
}

output "client_id" {
  value = azuread_application.app.client_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "client_secret" {
  value     = azuread_application_password.app.value
  sensitive = true
}

data "azuread_client_config" "current" {}