locals {
    application  = "grid"

    tags = {
    Application        = title(local.application)
    Environment        = title(var.environment)
  }
}
 


module "log_analytics" {
  source  = "equinor/log-analytics/azurerm"
  version = "2.2.0"

  workspace_name      = "log-${local.application}-fozzen-${var.environment}"
  resource_group_name = data.resource_group_name
  location            = var.location
}

module "storage" {
  source = "equinor/storage/azurerm"

  account_name               = "st${local.application}fozzen${var.environment}"
  resource_group_name        = data.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.tags
}

resource "azurerm_eventgrid_topic" "topic" {
  name                       = "topic-${local.application}-fozzen-${var.environment}"
  resource_group_name        = data.resource_group_name
  location                   = var.location

  tags = local.tags
}