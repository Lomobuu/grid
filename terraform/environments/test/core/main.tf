### Shared resources
locals {

  application         = "gridss"
  environment         = "test"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

