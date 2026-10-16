### Shared resources
locals {
  application         = "gridss"
  environment         = "test"
}


module "core" {
  source = "../../../modules/AAD"

  environment = local.environment

  redirect_uris = [
    "https://${local.application}-${local.environment}.example.com/oauth2/callback",
    "https://${local.application}-${local.environment}.example.com/signin-oidc",
  ]
}