### Shared resources
locals {
  application         = "gridssss"
  environment         = "prod"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}