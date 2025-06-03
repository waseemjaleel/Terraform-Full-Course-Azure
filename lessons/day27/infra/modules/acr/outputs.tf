output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "The username for admin access to ACR"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "The password for admin access to ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "identity_principal_id" {
  description = "The Principal ID for the System Assigned Identity of ACR"
  value       = azurerm_container_registry.acr.identity[0].principal_id
}