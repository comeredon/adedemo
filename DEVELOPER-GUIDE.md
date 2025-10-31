# Azure Deployment Environments - Container App Demo

## 🚀 Quick Start for Developers

This repository contains Azure Deployment Environment templates that allow you to quickly deploy Azure Container Apps through self-service.

### Available Templates

- **container-app-demo**: Deploys a complete Azure Container App with managed environment and Log Analytics workspace

## 🛠️ How to Create Your Own Environment

### Method 1: Using GitHub Actions (Recommended for CI/CD)

**Automatic Deployment (on code push):**
1. Push your code to the `main` branch
2. GitHub Actions automatically creates an environment
3. Check the Actions tab for progress and the app URL

**Manual Deployment:**
1. Go to **Actions** tab in GitHub
2. Select **"Deploy to Azure Deployment Environment"**
3. Click **"Run workflow"** and fill parameters
4. Monitor progress and get the app URL

📚 **See [GitHub Actions Guide](GITHUB-ACTIONS-GUIDE.md) for complete setup instructions**

### Method 2: Using the PowerShell Script

```powershell
# Basic deployment with default settings
.\create-environment.ps1 -EnvironmentName "my-app"

# Custom deployment with your own container image
.\create-environment.ps1 `
    -EnvironmentName "my-custom-app" `
    -ContainerImage "nginx:latest" `
    -MinReplicas 2 `
    -MaxReplicas 10
```

### Method 3: Using Azure CLI Directly

```powershell
az devcenter dev environment create `
    --dev-center "ade-sandbox-dc" `
    --project-name "ade-sandbox-project" `
    --environment-name "my-container-app" `
    --environment-type "Sandbox" `
    --catalog-name "container-app-templates" `
    --environment-definition-name "container-app-demo" `
    --parameters '{"environmentName": "myapp", "containerImage": "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"}' `
    --user-id "me"
```

### Method 4: Using Azure Portal

1. Go to [Azure Developer Portal](https://devportal.microsoft.com/)
2. Select the **ade-sandbox-project** project
3. Click **"+ New Environment"**
4. Select **container-app-demo** template
5. Configure your parameters:
   - **environmentName**: Choose a unique name for your app
   - **containerImage**: Docker image to deploy (optional)
   - **minReplicas**: Minimum number of instances (optional)
   - **maxReplicas**: Maximum number of instances (optional)
6. Click **"Create"**

## 📋 Template Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `environmentName` | ✅ Yes | - | Unique name for your environment |
| `location` | ❌ No | Resource group location | Azure region |
| `containerAppName` | ❌ No | Auto-generated | Name of the container app |
| `containerImage` | ❌ No | `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` | Container image to deploy |
| `minReplicas` | ❌ No | 1 | Minimum number of replicas |
| `maxReplicas` | ❌ No | 3 | Maximum number of replicas |

## 🏗️ What Gets Deployed

Each environment creates a new resource group containing:
- **Azure Container App**: Your containerized application
- **Container App Environment**: Managed Kubernetes environment
- **Log Analytics Workspace**: For logging and monitoring

## 🔍 Managing Your Environments

### List Your Environments
```powershell
az devcenter dev environment list `
    --dev-center "ade-sandbox-dc" `
    --project-name "ade-sandbox-project" `
    --user-id "me"
```

### Check Environment Status
```powershell
az devcenter dev environment show `
    --dev-center "ade-sandbox-dc" `
    --project-name "ade-sandbox-project" `
    --name "your-environment-name" `
    --user-id "me"
```

### Delete Environment (Clean Up)
```powershell
az devcenter dev environment delete `
    --dev-center "ade-sandbox-dc" `
    --project-name "ade-sandbox-project" `
    --name "your-environment-name" `
    --user-id "me" `
    --yes
```

## 📱 Example Use Cases

### Deploy a Simple Web App
```powershell
.\create-environment.ps1 -EnvironmentName "hello-world"
```

### Deploy Nginx Web Server
```powershell
.\create-environment.ps1 `
    -EnvironmentName "nginx-server" `
    -ContainerImage "nginx:alpine" `
    -MinReplicas 1 `
    -MaxReplicas 5
```

### Deploy a Node.js Application
```powershell
.\create-environment.ps1 `
    -EnvironmentName "my-node-app" `
    -ContainerImage "node:18-alpine" `
    -MinReplicas 2 `
    -MaxReplicas 8
```

## 🌐 Accessing Your Application

After deployment, your application will be available at:
- **URL Format**: `https://[app-name].[random-string].eastus.azurecontainerapps.io`
- The exact URL will be displayed after deployment completion

## 🏷️ Environment Types

- **Sandbox**: For development and testing (current setup)
- Additional environment types can be configured by administrators

## 🛡️ Security & Access

- Only authorized users can create environments in this project
- Each environment is deployed to its own resource group for isolation
- All resources are deployed in the East US region

## 🆘 Troubleshooting

### Common Issues

**Environment creation fails with permissions error:**
```
Solution: Ensure you have "Deployment Environments User" role on the project
```

**Container app not accessible:**
```
Check if the container image is publicly available and listens on port 80
```

**Template not found:**
```
Verify the catalog has synced successfully:
az devcenter admin catalog show --name "container-app-templates" --dev-center-name "ade-sandbox-dc" --resource-group "ade-cre-demo"
```

## 📞 Support

- For template issues: Create an issue in this repository
- For Azure Deployment Environments questions: Contact your platform team
- For Azure Container Apps documentation: [Microsoft Learn](https://learn.microsoft.com/azure/container-apps/)

## 🔗 Useful Links

- **[GitHub Actions Guide](GITHUB-ACTIONS-GUIDE.md)** - Complete CI/CD setup instructions
- [Azure Developer Portal](https://devportal.microsoft.com/)
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Deployment Environments Documentation](https://learn.microsoft.com/azure/deployment-environments/)
- [Container Images Registry](https://mcr.microsoft.com/)

---

**Happy Coding! 🎉**

> Remember to delete your environments when you're done to keep costs low and resources clean!