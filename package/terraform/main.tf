### CREATE RESOURCE GROUP FROM PACKAGE
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
}
### READ SHARED KEY VAULT
data "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}
### READ SECRET FROM SHARED KEY VAULT
data "azurerm_key_vault_secret" "storage_suffix" {
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.main.id
}
### CREATE STORAGE ACCOUNT BASED ON SECRET (show it can access the secret)
resource "azurerm_storage_account" "test" {
  name                     = "st${data.azurerm_key_vault_secret.storage_suffix.value}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}