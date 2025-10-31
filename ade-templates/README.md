# Azure Deployment Environments - Container App Template

This repository contains Azure Deployment Environment templates for deploying Azure Container Apps.

## Templates

### container-app-demo

Deploys a complete Azure Container App solution including:
- Log Analytics Workspace for monitoring
- Container Apps Environment
- Container App with configurable settings

## Parameters

- `environmentName` (required): Name of the environment
- `location` (optional): Azure region (defaults to resource group location)
- `containerAppName` (optional): Name for the container app (auto-generated if not specified)
- `containerImage` (optional): Container image to deploy (defaults to Microsoft hello-world sample)
- `minReplicas` (optional): Minimum replica count (default: 1)
- `maxReplicas` (optional): Maximum replica count (default: 3)

## Usage with Azure Deployment Environments

1. Link this repository as a catalog in your Dev Center
2. Create an environment type (e.g., "Dev", "Test", "Production")
3. Developers can deploy using Azure CLI:

```bash
az devcenter dev environment create \
  --dev-center-name <dev-center-name> \
  --project-name <project-name> \
  --environment-name my-container-app \
  --environment-type Dev \
  --catalog-name <catalog-name> \
  --environment-definition-name container-app-demo \
  --parameters '{"containerAppName": "my-app", "minReplicas": 2}'
```

## Outputs

After deployment, the template outputs:
- `containerAppFQDN`: The fully qualified domain name of the container app
- `containerAppUrl`: The complete HTTPS URL to access the application
