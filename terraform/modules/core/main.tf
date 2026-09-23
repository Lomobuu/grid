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

module "key_vault" {
  source  = "equinor/key-vault/azurerm"
  version = "~> 11.11"

  vault_name                 = "kv-${local.application}-fozzen-${var.environment}"
  resource_group_name        = azurerm_resource_group.ResourceGroup.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# module "web_app" {
#   source  = "equinor/web-app/azurerm"
#   version = "~> 15.20"

#   app_name                   = "wa-${local.application}-fozzen-${var.environment}"
#   resource_group_name        = azurerm_resource_group.ResourceGroup.name
#   location                   = var.location
#   app_service_plan_id        = module.app_service.plan_id
#   log_analytics_workspace_id = module.log_analytics.workspace_id
# }

# resource "azurerm_monitor_action_group" "this" {
#   name                = "ag-${random_id.example.hex}"
#   resource_group_name = azurerm_resource_group.ResourceGroup.name
#   short_name          = "p0action"
#   enabled             = true

#   arm_role_receiver {
#     name                    = "Monitoring Contributor"
#     role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
#     use_common_alert_schema = true
#   }
# }

# module "app_service" {
#   source  = "equinor/app-service/azurerm"
#   version = "~> 2.1"

#   plan_name           = "plan-${local.application}-fozzen-${var.environment}"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   action_group_id     = azurerm_monitor_action_group.this.id
# }