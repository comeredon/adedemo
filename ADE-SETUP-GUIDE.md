# Azure Deployment Environments Demo Setup Guide

This guide will help you set up Azure Deployment Environments (ADE) to enable developers to self-service deploy Azure Container Apps from a GitHub repository template.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Dev Center                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Catalog (GitHub Repo)                  │    │
│  │  • container-app-demo template                      │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Environment Types (Dev/Test/Prod)          │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Linked to
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                        Project                               │
│  • Developers create environments                           │
│  • Self-service portal                                      │
│  • Quota management                                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Deploys to
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Resource Group: ade-cre-demo                    │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Azure Container App + Environment          │    │
│  │         Log Analytics Workspace                    │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. Azure subscription with permissions to create resources
2. GitHub repository (this repo or a new one)
3. GitHub Personal Access Token (PAT) with `repo` scope
4. Azure CLI with `devcenter` extension installed

## Step 1: Push Templates to GitHub

First, commit and push the `ade-templates` folder to your GitHub repository:

```powershell
# Initialize git if not already done
git add ade-templates/
git commit -m "Add Azure Deployment Environment templates for Container Apps"
git push origin main
```

## Step 2: Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (Full control of private repositories)
4. Copy the token (you'll need it for the setup script)

## Step 3: Run the Setup Script

Run the PowerShell setup script to create all necessary ADE resources:

```powershell
.\setup-ade.ps1 `
    -ResourceGroupName "ade-cre-demo" `
    -Location "eastus" `
    -DevCenterName "devcenter-cre-demo" `
    -ProjectName "containerapp-project" `
    -GitHubRepoUrl "https://github.com/YOUR-USERNAME/YOUR-REPO" `
    -GitHubPAT "ghp_YourGitHubTokenHere" `
    -GitHubBranch "main" `
    -CatalogName "container-templates"
```

This script will create:
- ✅ Dev Center with system-assigned managed identity
- ✅ Catalog linked to your GitHub repository
- ✅ Environment Types (Dev, Test, Production)
- ✅ Project connected to the Dev Center
- ✅ Role assignments for deployment permissions

## Step 4: Verify Catalog Sync

Wait for the catalog to sync (usually 2-5 minutes):

```powershell
az devcenter admin catalog show `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --query "{Name:name, SyncState:syncState, LastSyncTime:lastSyncStats.lastSyncTime}"
```

Expected output:
```json
{
  "Name": "container-templates",
  "SyncState": "Succeeded",
  "LastSyncTime": "2025-10-31T..."
}
```

## Step 5: Test the Deployment

Run the test script to create a sample environment:

```powershell
.\test-ade-deployment.ps1 `
    -DevCenterName "devcenter-cre-demo" `
    -ProjectName "containerapp-project" `
    -EnvironmentType "Dev"
```

## Developer Self-Service Usage

Once set up, developers can create their own environments using:

### Using Azure CLI

```powershell
# Create a new environment
az devcenter dev environment create `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --environment-name my-app-env `
    --environment-type Dev `
    --catalog-name container-templates `
    --environment-definition-name container-app-demo `
    --parameters '{"containerAppName": "my-app", "minReplicas": 2, "maxReplicas": 5}' `
    --user-id "@me"

# Check deployment status
az devcenter dev environment show `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --name my-app-env `
    --user-id "@me"

# List all my environments
az devcenter dev environment list `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --user-id "@me"

# Delete environment when done
az devcenter dev environment delete `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --name my-app-env `
    --user-id "@me" `
    --yes
```

### Using Azure Portal

1. Navigate to the Dev Portal: https://devportal.microsoft.com/
2. Select your project
3. Click "+ New" → "Environment"
4. Select the template and configure parameters
5. Click "Create"

### Using Azure Developer CLI (azd)

```bash
azd init --template container-app-demo
azd env new my-app-env
azd up
```

## Template Parameters

The Container App template supports these parameters:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `environmentName` | string | Yes | - | Name of the environment |
| `location` | string | No | Resource group location | Azure region |
| `containerAppName` | string | No | Auto-generated | Container app name |
| `containerImage` | string | No | `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` | Container image to deploy |
| `minReplicas` | int | No | 1 | Minimum replica count |
| `maxReplicas` | int | No | 3 | Maximum replica count |

## Outputs

After deployment, you'll get:
- `containerAppFQDN`: The FQDN of your container app
- `containerAppUrl`: The complete HTTPS URL

## Troubleshooting

### Catalog Not Syncing

```powershell
# Check catalog status
az devcenter admin catalog show `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo

# Manually trigger sync
az devcenter admin catalog sync `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo
```

### Permission Issues

```powershell
# Verify role assignments
az role assignment list `
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/ade-cre-demo" `
    --query "[].{Principal:principalName, Role:roleDefinitionName}"
```

### Environment Creation Fails

1. Check catalog sync status
2. Verify GitHub PAT has correct permissions
3. Ensure manifest.yaml is properly formatted
4. Check ARM template for syntax errors

## Cleanup

To remove all resources:

```powershell
# Delete all environments first
az devcenter dev environment list `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project | ConvertFrom-Json | ForEach-Object {
    az devcenter dev environment delete `
        --dev-center devcenter-cre-demo `
        --project-name containerapp-project `
        --name $_.name `
        --user-id "@me" `
        --yes
}

# Delete the project
az devcenter admin project delete `
    --name containerapp-project `
    --resource-group ade-cre-demo `
    --yes

# Delete the dev center
az devcenter admin devcenter delete `
    --name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --yes

# Delete the resource group (optional)
az group delete --name ade-cre-demo --yes
```

## Next Steps

- Add more templates to the catalog (Azure Functions, Static Web Apps, etc.)
- Configure approval workflows for production deployments
- Set up cost management and quotas
- Integrate with CI/CD pipelines
- Add custom parameters for environment-specific configurations

## Resources

- [Azure Deployment Environments Documentation](https://learn.microsoft.com/azure/deployment-environments/)
- [Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [ADE Template Specification](https://learn.microsoft.com/azure/deployment-environments/configure-catalog)
