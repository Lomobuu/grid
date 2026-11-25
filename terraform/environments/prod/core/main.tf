### Shared resources
locals {

  application         = "gridsssss"
  environment         = "prod"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

