### Shared resources
locals {

  application         = "grid"
  environment         = "test"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

