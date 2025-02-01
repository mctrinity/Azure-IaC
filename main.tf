terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# 🔹 Backend Storage Resources
resource "azurerm_resource_group" "backend_rg" {
  name     = var.backend_rg_name
  location = var.location
}

resource "azurerm_storage_account" "backend_storage" {
  name                     = var.backend_storage_account_id
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = azurerm_resource_group.backend_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "backend_container" {
  name                   = var.backend_container
  storage_account_id     = azurerm_storage_account.backend_storage.id
  container_access_type  = "private"
}

# 🔹 Resource Group
resource "azurerm_resource_group" "databricks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# 🔹 Databricks Workspace
resource "azurerm_databricks_workspace" "databricks" {
  name                = var.databricks_workspace_name
  resource_group_name = azurerm_resource_group.databricks_rg.name
  location            = azurerm_resource_group.databricks_rg.location
  sku                 = var.databricks_sku
}

# 🔹 Virtual Network (Optional, if needed)
resource "azurerm_virtual_network" "databricks_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.databricks_rg.name
  location            = var.location
  address_space       = var.vnet_address_space
}

# 🔹 Subnet for Databricks
resource "azurerm_subnet" "databricks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.databricks_rg.name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

# 🔹 Track Databricks-Managed Resource Group (Optional)
resource "azurerm_resource_group" "databricks_managed_rg" {
  name     = azurerm_databricks_workspace.databricks.managed_resource_group_name
  location = var.location

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags]
  }
}

# 🔹 Outputs
output "databricks_url" {
  value = azurerm_databricks_workspace.databricks.workspace_url
}

output "databricks_managed_rg" {
  value = azurerm_databricks_workspace.databricks.managed_resource_group_name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.databricks_vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.databricks_subnet.id
}
