### Shared resources
locals {

  application         = "gridssss"
  environment         = "prod"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

