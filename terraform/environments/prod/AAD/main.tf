### Shared resources
locals {
  application         = "grids"
  environment         = "prod"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}