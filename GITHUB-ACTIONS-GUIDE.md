# GitHub Actions for Azure Deployment Environments

This repository includes GitHub Actions workflows that enable automatic deployment to Azure Deployment Environments.

## 🚀 Available Workflows

### 1. Deploy to Azure Deployment Environment
**File**: `.github/workflows/deploy-to-ade.yml`

**Triggers**:
- **Manual**: Via GitHub Actions UI with custom parameters
- **Automatic**: On push to `main` branch (when code changes are detected)

**What it does**:
- Creates a new Azure Deployment Environment
- Deploys your container application
- Provides deployment summary with app URL
- Monitors deployment progress

### 2. Cleanup Azure Deployment Environment
**File**: `.github/workflows/cleanup-ade.yml`

**Triggers**:
- **Manual only**: Via GitHub Actions UI

**What it does**:
- Safely deletes an Azure Deployment Environment
- Requires confirmation to prevent accidental deletions
- Provides cleanup summary

## ⚙️ Setup Instructions

### Step 1: Create Azure Service Principal

You need to create an Azure Service Principal that GitHub Actions can use to authenticate with Azure.

```powershell
# Create a service principal with Contributor role on your resource group
$sp = az ad sp create-for-rbac --name "github-actions-ade-demo" --role "Contributor" --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/ade-cre-demo" --json-auth

# Also assign Deployment Environments User role on the project
az role assignment create --assignee $(echo $sp | jq -r '.clientId') --role "Deployment Environments User" --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/ade-cre-demo/providers/Microsoft.DevCenter/projects/ade-sandbox-project"
```

The output will look like this:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Step 2: Add GitHub Repository Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Create these 4 repository secrets (click **New repository secret** for each):

| Secret Name | Value | Source |
|-------------|-------|---------|
| `AZURE_CLIENT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | `clientId` from Step 1 JSON |
| `AZURE_TENANT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | `tenantId` from Step 1 JSON |
| `AZURE_CLIENT_SECRET` | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | `clientSecret` from Step 1 JSON |
| `AZURE_SUBSCRIPTION_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | `subscriptionId` from Step 1 JSON |

### Step 3: Update Workflow Variables (if needed)

If your Azure resources have different names, update these variables in the workflow files:

```yaml
env:
  DEV_CENTER_NAME: 'ade-sandbox-dc'          # Your Dev Center name
  PROJECT_NAME: 'ade-sandbox-project'        # Your Project name
  CATALOG_NAME: 'container-app-templates'    # Your Catalog name
  TEMPLATE_NAME: 'container-app-demo'        # Your Template name
  RESOURCE_GROUP: 'ade-cre-demo'             # Your Resource Group name
```

## 🎯 How to Use the Workflows

### Deploy Your Application

#### Option 1: Manual Deployment (Recommended for testing)
1. Go to **Actions** tab in your GitHub repository
2. Select **"Deploy to Azure Deployment Environment"**
3. Click **"Run workflow"**
4. Fill in the parameters:
   - **Environment Name**: Unique name for your deployment (e.g., `my-test-app`)
   - **Container Image**: Docker image to deploy (optional, defaults to hello-world)
   - **Min Replicas**: Minimum instances (default: 1)
   - **Max Replicas**: Maximum instances (default: 3)
   - **Environment Type**: Choose Sandbox or adedemo
5. Click **"Run workflow"**

#### Option 2: Automatic Deployment (on code changes)
1. Push changes to the `main` branch
2. The workflow automatically triggers if:
   - Files in `src/` folder change
   - `Dockerfile` changes
   - Workflow file itself changes
3. Environment name will be auto-generated: `main-{commit-hash}`

### Monitor Deployment Progress

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the real-time logs
4. Check the **Summary** section for deployment details including the app URL

### Access Your Deployed Application

After successful deployment:
1. Check the workflow **Summary** for the application URL
2. Or use Azure CLI:
   ```powershell
   az devcenter dev environment list --dev-center "ade-sandbox-dc" --project-name "ade-sandbox-project" --user-id "me"
   ```

### Cleanup Environments

1. Go to **Actions** tab
2. Select **"Cleanup Azure Deployment Environment"**
3. Click **"Run workflow"**
4. Enter:
   - **Environment Name**: Name of environment to delete
   - **Confirm Deletion**: Type `DELETE` to confirm
5. Click **"Run workflow"**

## 📋 Workflow Parameters

### Deploy Workflow Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `environment_name` | ✅ Yes | - | Unique name for your environment |
| `container_image` | ❌ No | `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` | Container image to deploy |
| `min_replicas` | ❌ No | `1` | Minimum number of replicas |
| `max_replicas` | ❌ No | `3` | Maximum number of replicas |
| `environment_type` | ❌ No | `Sandbox` | Environment type (Sandbox/adedemo) |

### Cleanup Workflow Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `environment_name` | ✅ Yes | Name of environment to delete |
| `confirm_deletion` | ✅ Yes | Must type "DELETE" to confirm |

## 🔧 Customizing for Your Application

### Deploy Your Own Container Image

#### Option 1: Use existing image from Docker Hub/MCR
```yaml
# In workflow dispatch, set:
container_image: "nginx:alpine"
# or
container_image: "mcr.microsoft.com/dotnet/samples:aspnetapp"
```

#### Option 2: Build and push your own image
Add these steps before deployment in the workflow:

```yaml
- name: Build and push Docker image
  run: |
    # Build your application
    docker build -t myregistry.azurecr.io/myapp:${{ github.sha }} .
    
    # Push to registry
    docker push myregistry.azurecr.io/myapp:${{ github.sha }}
    
    # Set the image for deployment
    echo "CONTAINER_IMAGE=myregistry.azurecr.io/myapp:${{ github.sha }}" >> $GITHUB_ENV
```

### Environment-Specific Configurations

You can create different workflow files for different environments:
- `.github/workflows/deploy-to-dev.yml` (always deploys to Dev)
- `.github/workflows/deploy-to-prod.yml` (deploys to Production with approvals)

## 🛡️ Security Best Practices

1. **Least Privilege**: The service principal only has access to your specific resource group
2. **Secrets Management**: GitHub repository secrets are encrypted and only accessible during workflow runs
3. **Confirmation Required**: Cleanup workflow requires explicit "DELETE" confirmation
4. **Audit Trail**: All deployments and deletions are logged in GitHub Actions

## 🚨 Troubleshooting

### Common Issues

**Authentication Error**:
```
Error: Authentication failed
```
- Check that `AZURE_CREDENTIALS` secret is properly set
- Verify service principal has correct permissions

**Environment Already Exists**:
```
Environment already exists
```
- Use a different environment name
- Or delete the existing environment first using the cleanup workflow

**Template Not Found**:
```
Template 'container-app-demo' not found
```
- Verify the catalog has synced successfully
- Check template names in Azure Portal

**Permission Denied**:
```
User does not have permission to create environments
```
- Ensure service principal has "Deployment Environments User" role on the project

### Getting Help

1. Check workflow logs in GitHub Actions tab
2. Use Azure CLI to debug:
   ```powershell
   az devcenter dev environment list --dev-center "ade-sandbox-dc" --project-name "ade-sandbox-project" --user-id "me"
   ```
3. Check Azure Portal for resource status

## 📊 Monitoring and Costs

- **Monitor deployments**: Check Azure Portal → Azure Deployment Environments
- **Track costs**: Each environment creates a separate resource group for easy cost tracking
- **Clean up regularly**: Use the cleanup workflow to delete test environments

## 🎉 Example Scenarios

### Scenario 1: Feature Branch Testing
```powershell
# Create feature environment
Environment Name: feature-user-auth
Container Image: myregistry.azurecr.io/myapp:feature-branch
```

### Scenario 2: Demo Environment
```powershell
# Create demo environment
Environment Name: demo-v2
Container Image: nginx:alpine
Min Replicas: 2
Max Replicas: 5
```

### Scenario 3: Performance Testing
```powershell
# Create performance test environment
Environment Name: perf-test-1
Container Image: myregistry.azurecr.io/myapp:latest
Min Replicas: 5
Max Replicas: 10
```

---

**Happy Deploying! 🚀**

> Remember: Always clean up test environments to keep costs low!