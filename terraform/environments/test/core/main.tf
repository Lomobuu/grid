### Shared resources
locals {
  resource_group_name = "RG-${local.application}-fozzen-${local.environment}"

  application         = "grid"
  location            = "northeurope"
  environment         = "prod"
}

data "azurerm_resource_group" "this" {
  name = local.resource_group_name
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

