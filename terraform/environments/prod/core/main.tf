### Shared resources
locals {

  application         = "grid"
  environment         = "Production"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

