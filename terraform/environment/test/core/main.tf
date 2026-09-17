### Shared resources
locals {
  resource_group_name = "RG-${local.application}-fozzen-${local.environment}"

  application         = "grid"
  location            = "norwayeast"
  environment         = "prod"
}

data "azurerm_resource_group" "this" {
  name = local.resource_group_name
}

module "core" {
  source = "../../modules/core"

  resource_group_name = data.azurerm_resource_group.this.name
  location            = local.location
}

