# grid

[![Deploy Core Infrastructure](https://github.com/Lomobuu/grid/actions/workflows/terraform-core.yaml/badge.svg)](https://github.com/Lomobuu/grid/actions/workflows/terraform-core.yaml)

[![Deploy Vendor Package](https://github.com/Lomobuu/grid/actions/workflows/deploy-package.yaml/badge.svg)](https://github.com/Lomobuu/grid/actions/workflows/deploy-package.yaml)

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


# Vendor Package Deployment Solution

## Goal

Deploy vendor-delivered Terraform packages stored in Azure Blob Storage without storing the packages in Git.

Initial workflow:

```text
Upload ZIP manually to Blob Storage
        ↓
Event Grid
        ↓
GitHub Actions
        ↓
deploy-package.yml
        ↓
Deploy TEST / PROD
```

Future workflow:

```text
Select existing version
        ↓
GitHub Actions
        ↓
deploy-package.yml
        ↓
Deploy TEST / PROD
```

This future workflow will be used for:

- Rollback
- Redeployment
- Testing old releases
- Manual promotion between environments

---

# Phase 1 - Infrastructure

## Terraform Resources

Create the following infrastructure:

### Artifact Management

```text
Storage Account
└── Container: vendor-packages
```

Example structure:

```text
vendor-packages/
└── kappa/
    ├── 1.0.0.zip
    ├── 1.0.1.zip
    └── 1.0.2.zip
```

### Deployment Automation

```text
Event Grid System Topic
Event Grid Subscription
```

Trigger:

```text
Microsoft.Storage.BlobCreated
```

Filter:

```text
Subject Ends With ".zip"
```

---

# Phase 2 - Vendor Package Structure

Each ZIP should contain:

```text
terraform/
├── main.tf
├── variables.tf
├── versions.tf
└── ka.tfvars.example
```

Do NOT include:

```text
ka.tfvars
```

because environment-specific values belong to your deployment repository.

---

# Phase 3 - Repository Structure

Deployment repository:

```text
.github/
└── workflows/
    ├── deploy-package.yml
    └── deploy-version.yml

environments/
├── test/
│   └── ka.tfvars
└── prod/
    └── ka.tfvars
```

Example:

```text
environments/test/ka.tfvars
environments/prod/ka.tfvars
```

These files contain environment-specific values.

---

# Phase 4 - Automatic Deployment Workflow

## Trigger

The workflow is started when:

```text
Blob uploaded
```

through:

```text
Storage Account
    ↓
Event Grid
    ↓
GitHub Action
```

## Workflow Steps

### Step 1

Receive blob information.

Example:

```text
kappa/1.0.2.zip
```

### Step 2

Determine version:

```text
1.0.2
```

### Step 3

Download ZIP.

### Step 4

Extract ZIP.

### Step 5

Select environment.

### Step 6

Copy tfvars file:

```bash
cp environments/test/ka.tfvars terraform/ka.tfvars
```

or

```bash
cp environments/prod/ka.tfvars terraform/ka.tfvars
```

### Step 7

Run Terraform:

```bash
terraform init
terraform validate
terraform plan -var-file=ka.tfvars
terraform apply -var-file=ka.tfvars
```

---

# Upload package command

```
az storage blob upload --account-name stgridfozzentest --container-name vendor-packages --name 1.0.0.zip --file "<path>" --auth-mode login --overwrite
```