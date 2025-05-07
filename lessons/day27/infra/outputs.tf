output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.networking.vnet_name
}

output "frontend_public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = module.frontend.public_ip_address
}

output "application_gateway_name" {
  description = "The name of the Application Gateway"
  value       = module.frontend.application_gateway_name
}

output "backend_internal_lb_ip" {
  description = "The private IP address of the internal load balancer"
  value       = module.backend.load_balancer_private_ip
}

output "postgres_server_name" {
  description = "The name of the PostgreSQL server"
  value       = module.database.server_name
}

output "postgres_server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL server"
  value       = module.database.server_fqdn
}

output "postgres_replica_name" {
  description = "The name of the PostgreSQL replica server"
  value       = module.database.replica_name
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.keyvault.key_vault_uri
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = module.acr.login_server
}

output "private_dns_zone_name" {
  description = "The name of the private DNS zone"
  value       = module.dns.private_dns_zone_name
}

output "frontend_vmss_id" {
  description = "The ID of the frontend Virtual Machine Scale Set"
  value       = module.frontend.vmss_id
}

output "backend_vmss_id" {
  description = "The ID of the backend Virtual Machine Scale Set"
  value       = module.backend.vmss_id
}

output "bastion_host_name" {
  description = "The name of the Bastion Host"
  value       = module.networking.bastion_host_name
}