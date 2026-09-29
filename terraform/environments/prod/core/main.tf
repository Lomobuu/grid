### Shared resources
locals {

  application         = "grids"
  environment         = "prod"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

