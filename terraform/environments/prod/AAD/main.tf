### Shared resources
locals {
  application         = "gridss"
  environment         = "prod"
}


module "core" {
  source = "../../../modules/AAD"

  environment         = local.environment
}