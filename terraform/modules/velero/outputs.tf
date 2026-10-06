output "velero_client_id" {
  value = azuread_application.velero.client_id
}

output "velero_client_secret" {
  value     = azuread_application_password.velero.value
  sensitive = true
}

output "velero_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}