# grid
event grid with blob storage test


# Step by step guide

Create managed identity OR app registration with access right to run terraform

Create resource group with name:

`<resource_type>-<project>-[<component>]-<environment>-[<location>]-[<instance>]`

Uses:
https://github.com/equinor/terraform-azurerm-storage
https://github.com/equinor/azure-terraform-backend-template

from:
https://github.com/equinor/terraform-baseline

run:
```
az deployment sub create --name terraform-backend --location northeurope --template-uri https://raw.githubusercontent.com/equinor/azure-terraform-backend-template/main/azuredeploy.json --parameters resourceGroupName=rg-vsps-tfstate-mgmt-weu-001 storageAccountName=stvspstfstateweu001
```

Creates the neccecary storage for backend.

Then with terraform have
- grid event
- storage account(blob storage for uploads new package) + log analytics


