variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "frontend_vmss_id" {
  description = "The ID of the frontend VM Scale Set"
  type        = string
  default     = null
}

variable "backend_vmss_id" {
  description = "The ID of the backend VM Scale Set"
  type        = string
  default     = null
}

variable "create_frontend_diagnostics" {
  description = "Whether to create diagnostic settings for frontend VMSS"
  type        = bool
  default     = false
}

variable "create_backend_diagnostics" {
  description = "Whether to create diagnostic settings for backend VMSS"
  type        = bool
  default     = false
}

variable "log_analytics_sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "The number of days to retain logs"
  type        = number
  default     = 30
}

variable "metric_retention_days" {
  description = "The number of days to retain metrics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = null
}
