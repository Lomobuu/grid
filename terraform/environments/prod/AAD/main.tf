### Shared resources
locals {
  application         = "gridsssss"
  environment         = "prod"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}