### Shared resources
locals {
  application         = "velero"
  environment         = "test"
  location            = "West Europe"
  location_short      = "weu"
}


module "core" {
  source = "../../../modules/velero"

  environment         = local.environment
  storage_account_name = "stfozzen${local.application}${local.environment}"
  storage_resource_group_name = "rg-kappa-${local.environment}-${local.location_short}"
  location = local.location
}

output "velero_client_id" {
value = module.core.velero_client_id
}
output "velero_client_secret" {
value = module.core.velero_client_secret
sensitive = true
}