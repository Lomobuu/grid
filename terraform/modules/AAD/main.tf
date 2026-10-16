# modules/AAD/main.tf
locals {
  application = "gridsss"
  tags = {
    Application = title(local.application)
    Environment = title(var.environment)
  }
}

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name     = "${local.application}-${var.environment}"
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = var.redirect_uris
    logout_url    = var.logout_url

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "app" {
  application_id = azuread_application.app.id
  display_name   = "${local.application}-application-secret"
  end_date       = timeadd(timestamp(), "4320h") # ~180 days

  lifecycle {
    ignore_changes = [end_date] # timestamp() would otherwise force a new secret every apply
  }
}