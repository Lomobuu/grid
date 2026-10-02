terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.9"
    }
  }
    backend "azurerm" {
      key = "test/aad/terraform.tfstate"
  }
}

