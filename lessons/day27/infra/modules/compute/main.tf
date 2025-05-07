/*
 * Compute Module
 * This module creates either frontend or backend compute resources with:
 * - VM Scale Set for application hosting
 * - Load balancer (Application Gateway for frontend, internal LB for backend)
 * - Managed identity for secure authentication
 * - Custom data script for Docker container setup
 */

locals {
  # Determine tier name based on frontend/backend flag
  tier_name     = var.is_frontend ? "frontend" : "backend"
  tier_priority = var.is_frontend ? 100 : 200

  # Full image name with ACR login server
  full_image_name = "${var.acr_login_server}/${var.docker_image}"

  # Setup script for the VMs - this will run on each VM to pull and run the Docker container
  custom_data = <<-CUSTOM_DATA
#!/bin/bash
# Install necessary packages
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce azure-cli

# Configure docker to use the system-assigned managed identity for ACR authentication
az login --identity
az acr login --name ${split(".", var.acr_login_server)[0]} --expose-token

# Pull and run container
docker pull ${local.full_image_name}

# Setup environment variables for container
%{if !var.is_frontend && var.database_connection != null}
# Backend container needs DB environment variables
docker run -d -p ${var.application_port}:${var.application_port} \
  -e DB_USERNAME=${var.database_connection.username} \
  -e DB_PASSWORD=${var.database_connection.password} \
  -e DB_HOST=${var.database_connection.host} \
  -e DB_PORT=${var.database_connection.port} \
  -e DB_NAME=${var.database_connection.dbname} \
  -e SSL=${var.database_connection.sslmode} \
  -e PORT=${var.application_port} \
  --restart always \
  ${local.full_image_name}
%{else}
# Frontend container with simpler setup
docker run -d -p ${var.application_port}:${var.application_port} \
  -e PORT=${var.application_port} \
  --restart always \
  ${local.full_image_name}
%{endif}
CUSTOM_DATA
}

# VM SSH Key for Admin Access
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Public IP for Load Balancer (Frontend only)
resource "azurerm_public_ip" "lb" {
  count               = var.is_frontend ? 1 : 0
  name                = "${var.resource_name_prefix}-${local.tier_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Application Gateway for Frontend
resource "azurerm_application_gateway" "frontend" {
  count               = var.is_frontend ? 1 : 0
  name                = "${var.resource_name_prefix}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.lb[0].id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.application_port
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "health-probe"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }

  probe {
    name                = "health-probe"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = var.application_port
    path                = var.health_probe_path
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

# Internal Load Balancer for Backend
resource "azurerm_lb" "backend" {
  count               = var.is_frontend ? 0 : 1
  name                = "${var.resource_name_prefix}-${local.tier_name}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "internal-ip-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  count           = var.is_frontend ? 0 : 1
  name            = "${var.resource_name_prefix}-${local.tier_name}-backend-pool"
  loadbalancer_id = azurerm_lb.backend[0].id
}

resource "azurerm_lb_probe" "backend" {
  count               = var.is_frontend ? 0 : 1
  name                = "${var.resource_name_prefix}-${local.tier_name}-probe"
  loadbalancer_id     = azurerm_lb.backend[0].id
  protocol            = "Http"
  port                = var.application_port
  request_path        = var.health_probe_path
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "backend" {
  count                          = var.is_frontend ? 0 : 1
  name                           = "${var.resource_name_prefix}-${local.tier_name}-rule"
  loadbalancer_id                = azurerm_lb.backend[0].id
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = "internal-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend[0].id]
  probe_id                       = azurerm_lb_probe.backend[0].id
}

# VM Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.resource_name_prefix}-${local.tier_name}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.instance_count
  admin_username      = var.admin_username
  custom_data         = base64encode(local.custom_data)
  upgrade_mode        = "Automatic"
  health_probe_id     = var.is_frontend ? null : azurerm_lb_probe.backend[0].id
  tags                = var.tags

  # Enable termination notification to allow graceful shutdown
  termination_notification {
    enabled = true
    timeout = "PT5M" # 5 minutes
  }

  # Enable automatic repairs for unhealthy VMs
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT30M" # 30 minutes grace period
    action       = "Replace"
  }

  # Configure scale-in policy to remove oldest VMs first
  scale_in {
    rule                   = "OldestVM"
    force_deletion_enabled = false
  }

  # Configure rolling upgrade policy for smoother updates
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT1M"
    prioritize_unhealthy_instances_enabled  = true
  }

  # Prevent direct SSH access, use Bastion instead
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${local.tier_name}-nic"
    primary = true

    ip_configuration {
      name                                         = "${local.tier_name}-ipconfig"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      load_balancer_backend_address_pool_ids       = var.is_frontend ? null : [azurerm_lb_backend_address_pool.backend[0].id]
      application_gateway_backend_address_pool_ids = var.is_frontend ? [for pool in azurerm_application_gateway.frontend[0].backend_address_pool : pool.id] : null
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Auto-scaling settings - moved to a separate resource as required by provider version 4.27.0
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${var.resource_name_prefix}-${local.tier_name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "AutoScale"

    capacity {
      default = var.instance_count
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}
