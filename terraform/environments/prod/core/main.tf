### Shared resources
locals {

  application         = "gridss"
  environment         = "prod"
  location            = "Norway East"
}

module "core" {
  source = "../../../modules/core"

  location            = local.location
  environment         = local.environment
}

