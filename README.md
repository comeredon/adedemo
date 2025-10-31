# Azure Deployment Environments Demo

🚀 **Self-Service Container App Deployment with Azure Deployment Environments**

This repository demonstrates how to use Azure Deployment Environments (ADE) to enable developers to self-service deploy Azure Container Apps through GitHub Actions, Azure CLI, or the Azure Portal.

## 📋 What's Included

- **Azure Container App Template**: Complete ARM template for deploying containerized applications
- **GitHub Actions Workflows**: Automated CI/CD for environment deployment and cleanup
- **PowerShell Scripts**: Helper scripts for manual setup and deployment
- **Comprehensive Documentation**: Step-by-step guides for developers and administrators

## 🎯 Quick Start for Developers

### Option 1: GitHub Actions (Recommended)
1. Push code to `main` branch → automatic deployment
2. Or manually trigger via Actions tab with custom parameters
3. Get your app URL from the workflow summary

### Option 2: PowerShell Script
```powershell
.\create-environment.ps1 -EnvironmentName "my-app"
```

### Option 3: Azure CLI
```powershell
az devcenter dev environment create --dev-center "ade-sandbox-dc" --project-name "ade-sandbox-project" --environment-name "my-app" --environment-type "Sandbox" --catalog-name "container-app-templates" --environment-definition-name "container-app-demo" --parameters '{"environmentName": "my-app"}' --user-id "me"
```

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| **[DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md)** | Complete developer instructions for using ADE |
| **[GITHUB-ACTIONS-GUIDE.md](GITHUB-ACTIONS-GUIDE.md)** | CI/CD setup and usage guide |
| **[ADE-SETUP-GUIDE.md](ADE-SETUP-GUIDE.md)** | Administrative setup documentation |

## 🏗️ Repository Structure

```
📦 adedemo
├── 📁 .github/workflows/          # GitHub Actions for CI/CD
│   ├── deploy-to-ade.yml         # Main deployment workflow
│   └── cleanup-ade.yml           # Environment cleanup workflow
├── 📁 ade-templates/              # Azure Deployment Environment templates
│   └── 📁 container-app-demo/    # Container App template
│       ├── manifest.yaml         # Template metadata
│       ├── azuredeploy.json      # ARM template
│       └── azuredeploy.parameters.json
├── 📄 setup-ade.ps1              # Initial ADE infrastructure setup
├── 📄 setup-github-actions.ps1   # Service principal setup for GitHub Actions
├── 📄 create-environment.ps1     # Helper script for creating environments
└── 📄 test-ade-deployment.ps1    # Testing script
```

## ⚡ Features

### For Developers
- **Self-Service Deployment**: Create environments without admin intervention
- **Multiple Deployment Methods**: GitHub Actions, CLI, Portal, or scripts
- **Auto-Scaling**: Container apps scale based on demand (1-3 replicas default)
- **Secure Access**: HTTPS endpoints with managed SSL certificates
- **Easy Cleanup**: One-click environment deletion

### For Administrators  
- **Template Management**: Version-controlled ARM templates in Git
- **Cost Control**: Separate resource groups per environment for cost tracking
- **Security**: RBAC-based access with least-privilege principles
- **Audit Trail**: Complete deployment and deletion history
- **Scalable**: Easy to add more templates and environment types

## 🛠️ What Gets Deployed

Each environment creates:
- **Azure Container App**: Your containerized application
- **Container App Environment**: Managed Kubernetes environment  
- **Log Analytics Workspace**: Centralized logging and monitoring
- **Resource Group**: Isolated per environment for easy management

## 🌐 Live Demo

Try the deployment:
1. Fork this repository
2. Follow the [GitHub Actions Guide](GITHUB-ACTIONS-GUIDE.md) to set up authentication
3. Run the deployment workflow
4. Access your app at the generated URL

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify templates in `ade-templates/`
4. Test with the provided scripts
5. Submit a pull request

## 📞 Support

- **Issues**: Report bugs or request features via GitHub Issues
- **Documentation**: Check the guides in the `/docs` section
- **Azure Support**: For Azure-specific issues, contact your cloud administrator

## 🏷️ Azure Resources

- **Dev Center**: `ade-sandbox-dc`
- **Project**: `ade-sandbox-project`  
- **Environment Types**: Sandbox, adedemo
- **Region**: East US

---

**Ready to deploy? Check out the [Developer Guide](DEVELOPER-GUIDE.md) to get started! 🚀**