locals {
  application = "velero"

  location_suffix = {
    "North Europe"   = "ne"
    "Norway East"    = "rwe"
    "West Europe"    = "weu"
  }[var.location]

  tags = {
    Application = title(local.application)
    Environment = title(var.environment)
  }
}

data "azurerm_client_config" "current" {}

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
  scope                = module.storage.account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.velero.object_id
}

resource "azurerm_role_assignment" "storage_key_operator" {
  scope                = module.storage.account_id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azuread_service_principal.velero.object_id
}

module "log_analytics" {
  source  = "equinor/log-analytics/azurerm"
  version = "2.5.0"

  workspace_name      = "log-${local.application}-fozzen-${var.environment}"
  resource_group_name = var.storage_resource_group_name
  location            = var.location
}

module "storage" {
  source = "equinor/storage/azurerm"

  account_name               = var.storage_account_name
  resource_group_name        = var.storage_resource_group_name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.tags
}

resource "azurerm_storage_container" "container" {
  name                  = "velero"
  storage_account_id    = module.storage.account_id
  container_access_type = "private"
}