provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# 🔹 Resource Group
resource "azurerm_resource_group" "databricks_rg" {
  name     = "databricks-rg"
  location = "East US"
}

# 🔹 Databricks Workspace
resource "azurerm_databricks_workspace" "databricks" {
  name                = "my-databricks-workspace"
  resource_group_name = azurerm_resource_group.databricks_rg.name
  location            = azurerm_resource_group.databricks_rg.location
  sku                 = "premium"  # Change to "standard" if needed
}

# 🔹 Output Databricks URL
output "databricks_url" {
  value = azurerm_databricks_workspace.databricks.workspace_url
}
