locals {

  application   = "grids"
    tags = {
    Application        = title(local.application)
    Environment        = title(var.environment)
  }
}

resource "azuread_application" "app" {
  display_name = "${local.application}-${var.environment}"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_password" "app" {
  application_id = azuread_application.app.id
  display_name   = "${local.application}-application-secret"
}

data "azuread_client_config" "current" {}