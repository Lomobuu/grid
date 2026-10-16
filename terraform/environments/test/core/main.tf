### Shared resources
locals {

  application         = "gridsss"
  environment         = "test"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

