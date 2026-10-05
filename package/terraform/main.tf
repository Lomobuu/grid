### CREATE RESOURCE GROUP FROM PACKAGE
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
### READ SHARED KEY VAULT
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}
### READ SECRET FROM SHARED KEY VAULT
data "azurerm_key_vault_secret" "storage_suffix" {
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "random_id" "this" {
  byte_length = 8
}

### CREATE STORAGE ACCOUNT BASED ON SECRET (show it can access the secret)
resource "azurerm_storage_account" "storage" {
  name                     = "stfozzen${random_id.this.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    keyvault_secret = data.azurerm_key_vault_secret.storage_suffix.value
  }
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksfozzen${random_id.this.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "fozzendnsprefix${random_id.this.hex}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    keyvault_secret = data.azurerm_key_vault_secret.storage_suffix.value
  }
}
