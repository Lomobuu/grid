locals {

  application   = "gridssss"

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

module "key_vault" {
  source  = "equinor/key-vault/azurerm"
  version = "~> 11.11"

  vault_name                 = "kv-${local.application}-fozzen-${var.environment}"
  resource_group_name        = azurerm_resource_group.ResourceGroup.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

module "log_analytics" {
  source  = "equinor/log-analytics/azurerm"
  version = "2.5.0"

  workspace_name      = "log-${local.application}-fozzen-${var.environment}"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksfozzen${local.application}"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  dns_prefix          = "fozzendnsprefix${local.application}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  node_provisioning_profile {
    
  }

  identity {
    type = "SystemAssigned"
  }

}
