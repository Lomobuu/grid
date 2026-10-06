param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("test", "prod")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"

$terraformPath = Join-Path $PSScriptRoot "..\terraform\environments\$Environment\velero"

Push-Location $terraformPath

try {
    $clientId = terraform output -raw velero_client_id
    $clientSecret = terraform output -raw velero_client_secret

    gh secret set VELERO_CLIENT_ID `
      --env $Environment `
      --body $clientId

    gh secret set VELERO_CLIENT_SECRET `
      --env $Environment `
      --body $clientSecret

    Write-Host "Updated Velero secrets for $Environment"
}
finally {
    Pop-Location
}