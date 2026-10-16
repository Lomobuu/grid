### Shared resources
locals {
  application         = "gridsss"
  environment         = "prod"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}