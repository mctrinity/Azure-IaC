variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

# Backend Storage Configuration
variable "backend_rg_name" {
  description = "Resource group name for Terraform backend"
  type        = string
}

variable "backend_storage_account" {
  description = "Storage account for Terraform backend"
  type        = string
}

variable "backend_container" {
  description = "Container for Terraform backend state"
  type        = string
}

variable "backend_key" {
  description = "Terraform backend state key"
  type        = string
}

# Resource Group
variable "resource_group_name" {
  description = "Name of the resource group for Databricks"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

# Databricks Workspace
variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "databricks_sku" {
  description = "Databricks SKU (standard, premium, etc.)"
  type        = string
}

# Networking Variables
variable "vnet_name" {
  description = "Name of the virtual network for Databricks"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_name" {
  description = "Name of the subnet for Databricks"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}
