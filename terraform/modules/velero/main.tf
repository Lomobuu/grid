locals {
  application = "velero"

  tags = {
    Application = title(local.application)
    Environment = title(var.environment)
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "velero" {
  name                = var.storage_account_name
  resource_group_name = var.storage_resource_group_name
}

resource "azuread_application" "velero" {
  display_name = "app-${local.application}-${var.environment}"
}

resource "azuread_service_principal" "velero" {
  client_id = azuread_application.velero.client_id
}

resource "azuread_application_password" "velero" {
  application_id = azuread_application.velero.id
  display_name   = "${local.application}-secret"
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = data.azurerm_storage_account.velero.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.velero.object_id
}

resource "azurerm_role_assignment" "storage_key_operator" {
  scope                = data.azurerm_storage_account.velero.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azuread_service_principal.velero.object_id
}