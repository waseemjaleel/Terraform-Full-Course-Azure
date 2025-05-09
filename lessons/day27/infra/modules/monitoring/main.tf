# Azure Monitor Module for VMSS Monitoring
# This module creates Log Analytics workspace and diagnostic settings for VMSS

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.resource_name_prefix}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Diagnostic settings for frontend VMSS
resource "azurerm_monitor_diagnostic_setting" "frontend_vmss" {
  count                      = var.create_frontend_diagnostics ? 1 : 0
  name                       = "${var.resource_name_prefix}-frontend-diag"
  target_resource_id         = var.frontend_vmss_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Removed unsupported log categories and only using supported metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic settings for backend VMSS
resource "azurerm_monitor_diagnostic_setting" "backend_vmss" {
  count                      = var.create_backend_diagnostics ? 1 : 0
  name                       = "${var.resource_name_prefix}-backend-diag"
  target_resource_id         = var.backend_vmss_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Removed unsupported log categories and only using supported metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# VM Insights solution for enhanced monitoring
resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name         = "VMInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  tags = var.tags
}

# Create an Azure Monitor Action Group for alerts
resource "azurerm_monitor_action_group" "vmss_alerts" {
  name                = "${var.resource_name_prefix}-vmss-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "vmssalerts"

  email_receiver {
    name                    = "admin"
    email_address           = var.alert_email != null ? var.alert_email : "admin@example.com"
    use_common_alert_schema = true
  }
}

# CPU Alert for frontend VMSS
resource "azurerm_monitor_metric_alert" "frontend_cpu" {
  count               = var.create_frontend_diagnostics ? 1 : 0
  name                = "${var.resource_name_prefix}-frontend-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.frontend_vmss_id]
  description         = "Alert when frontend VMSS CPU exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.vmss_alerts.id
  }
}

# CPU Alert for backend VMSS
resource "azurerm_monitor_metric_alert" "backend_cpu" {
  count               = var.create_backend_diagnostics ? 1 : 0
  name                = "${var.resource_name_prefix}-backend-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.backend_vmss_id]
  description         = "Alert when backend VMSS CPU exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.vmss_alerts.id
  }
}
