### Shared resources
locals {
  application         = "grids"
  environment         = "test"
}


module "core" {
  source = "../../../modules/velero"

  environment         = local.environment
  storage_account_name = "stfozzen3cd99e72959d692e" # TODO: Remove hardcode
  storage_resource_group_name = "rg-kappa-test-weu" # TODO: REmove hardcode
}

output "velero_client_id" {
value = module.core.velero_client_id
}
output "velero_client_secret" {
value = module.core.velero_client_secret
sensitive = true
}