# Azure Databricks Deployment with Terraform and GitHub Actions

## Overview
This repository contains Terraform configurations to deploy an **Azure Databricks workspace** along with GitHub Actions for CI/CD automation.

## Deployment Architecture
Terraform deploys:
- An **Azure Resource Group** for Databricks.
- An **Azure Databricks Workspace**.
- **Optional**: The **Databricks-managed resource group** that stores additional resources.

## Prerequisites
- **Terraform** installed (`>=1.10.5`)
- **Azure CLI** installed and authenticated (`az login`)
- **GitHub Secrets** configured with:
  - `AZURE_CLIENT_ID`
  - `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_CLIENT_SECRET`

## Deployment Steps
### **1️⃣ Initialize and Apply Terraform**
```bash
terraform init
terraform plan
terraform apply -auto-approve
```
✅ This deploys the Databricks workspace and outputs the **Databricks URL**.

### **2️⃣ Access Databricks Workspace**
Retrieve the workspace URL:
```bash
az databricks workspace show --name my-databricks-workspace --resource-group databricks-rg --query "workspaceUrl" -o tsv
```
✅ Open the URL in your browser.

## Destroying Resources
### **Destroy Databricks Workspace and Managed Resources**
```bash
terraform destroy -auto-approve
```
🚨 **Note:** Azure Databricks automatically creates a **managed resource group** with additional services (e.g., storage accounts). This **is not automatically deleted** by Terraform.

### **Manually Delete Databricks-Managed Resource Group**
Find the managed resource group:
```bash
az group list --query "[?starts_with(name, 'databricks-rg-')].name" -o tsv
```
Delete it:
```bash
az group delete --name "<databricks-rg-xxxxxxx>" --yes --no-wait
```
✅ This ensures Databricks and all related resources are fully removed.

## Optional: Manage the Databricks-Managed Resource Group in Terraform
If you want Terraform to **track and delete** the managed resource group, add the following to `main.tf`:
```hcl
resource "azurerm_resource_group" "databricks_managed_rg" {
  name     = azurerm_databricks_workspace.databricks.managed_resource_group_name
  location = azurerm_resource_group.databricks_rg.location

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags]
  }
}
```
🚨 **This is optional** because Databricks **manages this group automatically**. Including it in Terraform **may cause errors** during `terraform destroy`.

## Choosing the Best Approach for Managing Databricks Resources
Since Databricks **automatically creates a managed resource group**, you need to decide whether **Terraform should manage it or not**.

| **Scenario** | **Include in Terraform?** | **How to Manage?** |
|-------------|------------------|-----------------|
| **Want full Terraform control** | ✅ Yes | Add `databricks_managed_rg` to Terraform. Terraform will track and delete it. |
| **Want Azure to manage it** | ❌ No | Let Azure handle the managed resource group and **manually delete** it after `terraform destroy`. |
| **Avoid Databricks errors during destroy** | ❌ No | Use `az group delete` to remove the managed RG manually after Terraform destroy. |

### **💡 Recommended Approach for Beginners**
If you're **new to Databricks**, the best option is **letting Azure manage the Databricks resource group** (Option 2).

### **How to Manage it Manually?**
1️⃣ Deploy Databricks normally with Terraform.  
2️⃣ After `terraform destroy`, manually delete the managed resource group:
```bash
az group list --query "[?starts_with(name, 'databricks-rg-')].name" -o tsv
az group delete --name "<databricks-managed-rg-name>" --yes --no-wait
```
✅ **This keeps Terraform simple while allowing you to clean up resources manually.**

## Automating Deployment with GitHub Actions
### **1️⃣ Set Up GitHub Actions Workflow**
Create `.github/workflows/deploy_databricks.yml`:
```yaml
name: Deploy Azure Databricks with Terraform

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Install Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
```
✅ This workflow will **deploy Databricks** automatically on a push to `main`.

### **2️⃣ Remove GitHub Actions Workflow (Optional)**
If you want to **disable automatic deployments**, delete the workflow:
```bash
rm -rf .github/workflows/deploy_databricks.yml
```
Commit the change:
```bash
git commit -m "Removed GitHub Actions workflow for Databricks deployment"
git push origin main
```
✅ This prevents future GitHub-triggered deployments.

## Conclusion
This guide provides a **fully automated** way to deploy and manage **Azure Databricks** using **Terraform & GitHub Actions**. You can choose whether to **let Azure manage the Databricks resource group or control it via Terraform**.

🚀 **Now you're ready to run Spark workloads, data pipelines, and ML models in Azure Databricks!**

