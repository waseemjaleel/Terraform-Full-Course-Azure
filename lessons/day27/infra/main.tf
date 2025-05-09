# Get current Azure client config for tenant_id and object_id
data "azurerm_client_config" "current" {}

locals {
  resource_name_prefix = "${var.environment}-${random_string.suffix.result}"
  common_tags          = merge(var.tags, { Environment = var.environment })
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# Create user-assigned managed identities first
# Commenting out managed identities as they are not needed when using ACR username/password auth
# resource "azurerm_user_assigned_identity" "frontend" {
#   count               = var.deploy_compute ? 1 : 0
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   name                = "${local.resource_name_prefix}-frontend-identity"
#   tags                = local.common_tags
# }

# resource "azurerm_user_assigned_identity" "backend" {
#   count               = var.deploy_compute ? 1 : 0
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   name                = "${local.resource_name_prefix}-backend-identity"
#   tags                = local.common_tags
# }

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  resource_name_prefix     = local.resource_name_prefix
  vnet_address_space       = var.vnet_address_space
  public_subnet_prefixes   = var.public_subnet_prefixes
  private_subnet_prefixes  = var.private_subnet_prefixes
  database_subnet_prefixes = var.database_subnet_prefixes
  bastion_subnet_prefix    = var.bastion_subnet_prefix
  appgw_subnet_prefix      = var.appgw_subnet_prefix
  tags                     = local.common_tags
}

# Azure Container Registry
module "acr" {
  source = "./modules/acr"

  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  resource_name_prefix     = local.resource_name_prefix
  georeplication_locations = [var.secondary_location] # Added for geo-replication
  tags                     = local.common_tags
}

# Assign AcrPull role to identities before VMSS creation
# Commenting out as we're using ACR admin username/password authentication
# resource "azurerm_role_assignment" "frontend_identity_acrpull" {
#   count                = var.deploy_compute ? 1 : 0
#   scope                = module.acr.acr_id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.frontend[0].principal_id
#
#   depends_on = [azurerm_user_assigned_identity.frontend, module.acr]
# }
#
# resource "azurerm_role_assignment" "backend_identity_acrpull" {
#   count                = var.deploy_compute ? 1 : 0
#   scope                = module.acr.acr_id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.backend[0].principal_id
#
#   depends_on = [azurerm_user_assigned_identity.backend, module.acr]
# }

# Key Vault
module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  resource_name_prefix = local.resource_name_prefix
  tenant_id            = data.azurerm_client_config.current.tenant_id
  object_id            = data.azurerm_client_config.current.object_id
  tags                 = local.common_tags

  depends_on = [module.database]
}

# After Key Vault is created, store database credentials as secrets
resource "azurerm_key_vault_secret" "db_host" {
  name         = "db-host"
  value        = module.database.server_fqdn
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault, module.database]
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "db-username"
  value        = module.database.administrator_login
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault, module.database]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = module.database.administrator_password
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault, module.database]
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "db-name"
  value        = var.postgres_db_name
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault]
}

# Database
module "database" {
  source = "./modules/database"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  resource_name_prefix = local.resource_name_prefix
  database_subnet_ids  = module.networking.database_subnet_ids
  private_dns_zone_id  = module.dns.private_dns_zone_id
  postgres_sku_name    = var.postgres_sku_name
  postgres_version     = var.postgres_version
  postgres_storage_mb  = var.postgres_storage_mb
  postgres_db_name     = var.postgres_db_name
  tags                 = local.common_tags

  depends_on = [module.dns]
}

# DNS for Private Endpoints
module "dns" {
  source = "./modules/dns"

  resource_group_name = azurerm_resource_group.main.name
  vnet_id             = module.networking.vnet_id
  tags                = local.common_tags
}

# Compute - Frontend VMSS
module "frontend" {
  count  = var.deploy_compute ? 1 : 0
  source = "./modules/compute"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  resource_name_prefix = local.resource_name_prefix
  subnet_id            = module.networking.public_subnet_ids[0]
  appgw_subnet_id      = module.networking.appgw_subnet_id
  vm_size              = var.frontend_vm_size
  instance_count       = var.frontend_instances
  admin_username       = var.admin_username
  acr_login_server     = module.acr.login_server
  acr_admin_username   = module.acr.admin_username
  acr_admin_password   = module.acr.admin_password
  docker_image         = var.frontend_image
  is_frontend          = true
  application_port     = 3000
  health_probe_path    = "/"
  key_vault_id         = module.keyvault.key_vault_id
  # No longer using managed identities for ACR auth - pass null instead
  user_assigned_identity_id = null
  tags                      = local.common_tags

  depends_on = [
    module.acr,
    module.keyvault
    # Removed dependency on azurerm_role_assignment.frontend_identity_acrpull as we're using admin auth
  ]
}

# Compute - Backend VMSS
module "backend" {
  count  = var.deploy_compute ? 1 : 0
  source = "./modules/compute"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  resource_name_prefix = local.resource_name_prefix
  subnet_id            = module.networking.private_subnet_ids[0]
  vm_size              = var.backend_vm_size
  instance_count       = var.backend_instances
  admin_username       = var.admin_username
  acr_login_server     = module.acr.login_server
  acr_admin_username   = module.acr.admin_username
  acr_admin_password   = module.acr.admin_password
  docker_image         = var.backend_image
  is_frontend          = false
  application_port     = 8080
  health_probe_path    = "/health"
  key_vault_id         = module.keyvault.key_vault_id
  # No longer using managed identities for ACR auth - pass null instead
  user_assigned_identity_id = null
  tags                      = local.common_tags

  database_connection = {
    host     = module.database.server_fqdn
    port     = 5432
    username = module.database.administrator_login
    password = module.database.administrator_password
    dbname   = var.postgres_db_name
    sslmode  = "require"
  }

  depends_on = [
    module.acr,
    module.keyvault,
    module.database
    # Removed dependency on azurerm_role_assignment.backend_identity_acrpull as we're using admin auth
  ]
}

# Monitoring Module for VMSS
# module "monitoring" {
#   source = "./modules/monitoring"

#   resource_group_name         = azurerm_resource_group.main.name
#   location                    = var.location
#   resource_name_prefix        = local.resource_name_prefix
#   frontend_vmss_id            = var.deploy_compute ? module.frontend[0].vmss_id : null
#   backend_vmss_id             = var.deploy_compute ? module.backend[0].vmss_id : null
#   create_frontend_diagnostics = var.deploy_compute
#   create_backend_diagnostics  = var.deploy_compute
#   log_analytics_sku           = var.log_analytics_sku
#   log_retention_days          = var.log_retention_days
#   alert_email                 = var.alert_email
#   tags                        = local.common_tags

#   depends_on = [module.frontend, module.backend]
# }

# DUPLICATE RESOURCES - COMMENTED OUT TO RESOLVE 409 CONFLICT
# These role assignments are already created by frontend_identity_acrpull and backend_identity_acrpull above
# Role Assignment - Frontend VMSS gets AcrPull role on ACR
# resource "azurerm_role_assignment" "frontend_acrpull" {
#   count                = var.deploy_compute ? 1 : 0
#   scope                = module.acr.acr_id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.frontend[0].principal_id
#   depends_on = [module.frontend, module.acr]
# }

# Role Assignment - Backend VMSS gets AcrPull role on ACR
# resource "azurerm_role_assignment" "backend_acrpull" {
#   count                = var.deploy_compute ? 1 : 0
#   scope                = module.acr.acr_id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.backend[0].principal_id
#   depends_on = [module.backend, module.acr]
# }

# Key Vault Access Policy for Frontend VMSS
# Commenting out as they reference the commented-out managed identities
# resource "azurerm_key_vault_access_policy" "frontend" {
#   count        = var.deploy_compute ? 1 : 0
#   key_vault_id = module.keyvault.key_vault_id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   # Changed to use the frontend user-assigned identity directly
#   object_id = azurerm_user_assigned_identity.frontend[0].principal_id
#
#   secret_permissions = [
#     "Get",
#     "List"
#   ]
#
#   depends_on = [module.keyvault, module.frontend]
# }

# Key Vault Access Policy for Backend VMSS
# Commenting out as they reference the commented-out managed identities
# resource "azurerm_key_vault_access_policy" "backend" {
#   count        = var.deploy_compute ? 1 : 0
#   key_vault_id = module.keyvault.key_vault_id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   # Changed to use the backend user-assigned identity directly
#   object_id = azurerm_user_assigned_identity.backend[0].principal_id
#
#   secret_permissions = [
#     "Get",
#     "List"
#   ]
#
#   depends_on = [module.keyvault, module.backend]
# }
