# Azure Deployment Environments Demo

This repository contains templates and setup scripts for demonstrating Azure Deployment Environments (ADE) with Azure Container Apps.

## 🚀 Quick Start

### Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI with `devcenter` extension
- GitHub Personal Access Token with `repo` scope

### Setup Instructions

1. **Clone this repository**
   ```bash
   git clone https://github.com/comeredon/adedemo.git
   cd adedemo
   ```

2. **Create a GitHub Personal Access Token**
   - Go to: https://github.com/settings/tokens
   - Generate a token with `repo` scope
   - Save it securely

3. **Run the setup script**
   ```powershell
   .\setup-ade.ps1 `
       -ResourceGroupName "ade-cre-demo" `
       -GitHubRepoUrl "https://github.com/comeredon/adedemo" `
       -GitHubPAT "YOUR_GITHUB_TOKEN_HERE"
   ```

4. **Test the deployment**
   ```powershell
   .\test-ade-deployment.ps1
   ```

## 📁 Repository Structure

```
adedemo/
├── ade-templates/              # Environment definition templates
│   ├── container-app-demo/     # Azure Container App template
│   │   ├── manifest.yaml       # Template metadata
│   │   ├── azuredeploy.json    # ARM template
│   │   └── azuredeploy.parameters.json
│   └── README.md
├── setup-ade.ps1               # Automated ADE infrastructure setup
├── test-ade-deployment.ps1     # Test environment deployment
├── ADE-SETUP-GUIDE.md          # Detailed setup guide
└── ADE-QUICK-REFERENCE.md      # Quick reference commands
```

## 🎯 What This Demo Provides

### For Administrators
- Automated setup of Azure Deployment Environments infrastructure
- Dev Center with catalog linked to this GitHub repository
- Environment types: Dev, Test, Production
- Proper role assignments and permissions

### For Developers
- Self-service environment provisioning
- Azure Container App deployment in minutes
- Consistent, repeatable infrastructure
- No need to understand ARM templates or infrastructure details

## 📖 Documentation

- **[ADE Setup Guide](ADE-SETUP-GUIDE.md)** - Complete step-by-step setup instructions
- **[Quick Reference](ADE-QUICK-REFERENCE.md)** - Common commands and patterns
- **[Template Documentation](ade-templates/README.md)** - Template details and parameters

## 🔧 Template Features

The included Container App template deploys:
- Azure Container App with external HTTPS ingress
- Container Apps Environment
- Log Analytics Workspace for monitoring
- Configurable auto-scaling (min/max replicas)
- Support for custom container images

## 💡 Usage Example

Once set up, developers can create environments with:

```powershell
az devcenter dev environment create `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --environment-name my-app `
    --environment-type Dev `
    --catalog-name container-templates `
    --environment-definition-name container-app-demo `
    --parameters '{"containerAppName": "my-app", "minReplicas": 2}' `
    --user-id "@me"
```

## 🌐 Access Points

- **Azure Portal (Admin)**: Manage Dev Centers and Projects
- **Dev Portal**: https://devportal.microsoft.com/ (Developer self-service)

## 🤝 Contributing

To add new templates:
1. Create a new folder under `ade-templates/`
2. Add `manifest.yaml` and ARM template files
3. Update the catalog documentation
4. Commit and push - the catalog will sync automatically

## 📝 License

This project is provided as-is for demonstration purposes.

## 🔗 Resources

- [Azure Deployment Environments Documentation](https://learn.microsoft.com/azure/deployment-environments/)
- [Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [ADE Template Specification](https://learn.microsoft.com/azure/deployment-environments/configure-catalog)
