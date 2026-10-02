provider "azuread" {
  use_oidc = true
}

provider "azurerm" {
  features {}
  use_oidc = true
}