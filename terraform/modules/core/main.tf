locals {

  application   = "grid"

  location_suffix = {
    "North Europe"   = "ne"
    "Norway East"    = "rwe"
  }[var.location]

    tags = {
    Application        = title(local.application)
    Environment        = title(var.environment)
  }
}
 

resource "azurerm_resource_group" "ResourceGroup" {
  name     = "rg-${local.application}-${var.environment}-${local.location_suffix}"
  location = var.location

  tags = local.tags
}

module "log_analytics" {
  source  = "equinor/log-analytics/azurerm"
  version = "2.5.0"

  workspace_name      = "log-${local.application}-fozzen-${var.environment}"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = var.location
}

module "storage" {
  source = "equinor/storage/azurerm"

  account_name               = "st${local.application}fozzen${var.environment}"
  resource_group_name        = azurerm_resource_group.ResourceGroup.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.tags
}

resource "azurerm_storage_container" "container" {
  name                  = "vendor-package"
  storage_account_id    = module.storage.account_id
  container_access_type = "private"
}