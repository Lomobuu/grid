### Shared resources
locals {
  application         = "grids"
  environment         = "test"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}