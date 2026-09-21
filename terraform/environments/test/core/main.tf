### Shared resources
locals {

  application         = "grid"
  environment         = "Testing"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

