/*
 * ACR Module
 * This module creates an Azure Container Registry (ACR) for storing Docker images.
 * It uses the Premium SKU to enable geo-replication, enhanced security, and more.
 */

# Generate a random string for uniqueness
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.resource_name_prefix, "-", "")}acr${random_string.acr_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  # Premium SKU features
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
    }
  }

  network_rule_bypass_option = "AzureServices"

  network_rule_set {
    default_action = "Allow"

    # Uncomment and customize if you want to allow specific IPs
    # ip_rule {
    #   action   = "Allow"
    #   ip_range = "203.0.113.0/24"
    # }
  }

  public_network_access_enabled = true # Set to false if you want only private access
}
