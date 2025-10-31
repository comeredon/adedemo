# Azure Deployment Environments - Quick Reference

## Setup Commands

### Install ADE Extension
```powershell
az extension add --name devcenter
```

### Run Initial Setup
```powershell
.\setup-ade.ps1 `
    -ResourceGroupName "ade-cre-demo" `
    -GitHubRepoUrl "https://github.com/YOUR-USERNAME/YOUR-REPO" `
    -GitHubPAT "YOUR_GITHUB_PAT"
```

## Developer Commands

### Create Environment
```powershell
az devcenter dev environment create `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --environment-name my-app `
    --environment-type Dev `
    --catalog-name container-templates `
    --environment-definition-name container-app-demo `
    --user-id "@me"
```

### List My Environments
```powershell
az devcenter dev environment list `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --user-id "@me"
```

### Check Environment Status
```powershell
az devcenter dev environment show `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --name my-app `
    --user-id "@me"
```

### Get Environment Outputs
```powershell
az devcenter dev environment show `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --name my-app `
    --user-id "@me" `
    --query "outputs"
```

### Delete Environment
```powershell
az devcenter dev environment delete `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --name my-app `
    --user-id "@me" `
    --yes
```

## Admin Commands

### Check Catalog Sync Status
```powershell
az devcenter admin catalog show `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --query "{Name:name, State:syncState, LastSync:lastSyncStats.lastSyncTime}"
```

### Manually Sync Catalog
```powershell
az devcenter admin catalog sync `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo
```

### List Environment Definitions
```powershell
az devcenter admin environment-definition list `
    --catalog-name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo
```

### List All Environments (Admin View)
```powershell
az devcenter admin environment list `
    --project-name containerapp-project `
    --resource-group ade-cre-demo
```

### Update Catalog Branch
```powershell
az devcenter admin catalog update `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --git-hub branch=feature-branch
```

## Portal URLs

### Azure Portal (Admin)
```
https://portal.azure.com/#view/Microsoft_Azure_DevCenter/DevCenterMenuBlade/~/overview/resourceId/%2Fsubscriptions%2F{subscriptionId}%2FresourceGroups%2Fade-cre-demo%2Fproviders%2FMicrosoft.DevCenter%2Fdevcenters%2Fdevcenter-cre-demo
```

### Dev Portal (Developer)
```
https://devportal.microsoft.com/
```

## Template Parameter Examples

### Minimal
```json
{
  "environmentName": "my-env"
}
```

### With Custom Container
```json
{
  "environmentName": "my-env",
  "containerAppName": "custom-app",
  "containerImage": "myregistry.azurecr.io/myapp:latest",
  "minReplicas": 2,
  "maxReplicas": 10
}
```

### Production Configuration
```json
{
  "environmentName": "prod-app",
  "containerAppName": "production-app",
  "containerImage": "myregistry.azurecr.io/myapp:v1.0.0",
  "minReplicas": 3,
  "maxReplicas": 20
}
```

## Common Patterns

### Create with Custom Parameters
```powershell
$params = @{
    environmentName = "my-env"
    containerAppName = "my-app"
    containerImage = "nginx:latest"
    minReplicas = 2
    maxReplicas = 5
} | ConvertTo-Json -Compress

az devcenter dev environment create `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --environment-name my-nginx-env `
    --environment-type Dev `
    --catalog-name container-templates `
    --environment-definition-name container-app-demo `
    --parameters $params `
    --user-id "@me"
```

### Wait for Deployment Completion
```powershell
$envName = "my-app"
do {
    $status = az devcenter dev environment show `
        --dev-center devcenter-cre-demo `
        --project-name containerapp-project `
        --name $envName `
        --user-id "@me" `
        --query "provisioningState" -o tsv
    
    Write-Host "Status: $status"
    Start-Sleep -Seconds 10
} while ($status -eq "Creating")

if ($status -eq "Succeeded") {
    $url = az devcenter dev environment show `
        --dev-center devcenter-cre-demo `
        --project-name containerapp-project `
        --name $envName `
        --user-id "@me" `
        --query "outputs.containerAppUrl.value" -o tsv
    
    Write-Host "✓ Deployment complete! App URL: $url"
}
```

### Bulk Delete Environments
```powershell
az devcenter dev environment list `
    --dev-center devcenter-cre-demo `
    --project-name containerapp-project `
    --user-id "@me" | ConvertFrom-Json | ForEach-Object {
    Write-Host "Deleting: $($_.name)"
    az devcenter dev environment delete `
        --dev-center devcenter-cre-demo `
        --project-name containerapp-project `
        --name $_.name `
        --user-id "@me" `
        --yes
}
```

## Troubleshooting

### Check Dev Center Identity
```powershell
az devcenter admin devcenter show `
    --name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --query "identity.principalId"
```

### Verify Role Assignments
```powershell
$rgScope = "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/ade-cre-demo"
az role assignment list --scope $rgScope --query "[].{Principal:principalName, Role:roleDefinitionName}"
```

### View Catalog Sync Errors
```powershell
az devcenter admin catalog show `
    --name container-templates `
    --dev-center-name devcenter-cre-demo `
    --resource-group ade-cre-demo `
    --query "lastSyncStats.{Errors:errors, LastSync:lastSyncTime}"
```
