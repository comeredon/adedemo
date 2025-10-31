# Azure Deployment Environment - Container App Demo
# Quick script for developers to create their own container app environments

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory=$false)]
    [string]$ContainerImage = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest",
    
    [Parameter(Mandatory=$false)]
    [int]$MinReplicas = 1,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxReplicas = 3,
    
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentType = "Sandbox"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating Azure Container App Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment Name: $EnvironmentName" -ForegroundColor Yellow
Write-Host "Container Image: $ContainerImage" -ForegroundColor Yellow
Write-Host "Replicas: $MinReplicas - $MaxReplicas" -ForegroundColor Yellow
Write-Host "Environment Type: $EnvironmentType" -ForegroundColor Yellow
Write-Host ""

# Create the environment
Write-Host "Creating environment..." -ForegroundColor Green
$result = az devcenter dev environment create `
    --dev-center "ade-sandbox-dc" `
    --project-name "ade-sandbox-project" `
    --environment-name $EnvironmentName `
    --environment-type $EnvironmentType `
    --catalog-name "container-app-templates" `
    --environment-definition-name "container-app-demo" `
    --parameters "{`"environmentName`": `"$EnvironmentName`", `"containerImage`": `"$ContainerImage`", `"minReplicas`": $MinReplicas, `"maxReplicas`": $MaxReplicas}" `
    --user-id "me" | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Environment created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment Details:" -ForegroundColor Yellow
    Write-Host "  Name: $($result.name)" -ForegroundColor White
    Write-Host "  Resource Group: $($result.resourceGroupId.Split('/')[-1])" -ForegroundColor White
    Write-Host "  Status: $($result.provisioningState)" -ForegroundColor White
    Write-Host ""
    
    # Wait a moment and get the container app details
    Write-Host "Getting application URL..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    
    $resourceGroupName = $result.resourceGroupId.Split('/')[-1]
    $containerApps = az containerapp list --resource-group $resourceGroupName --query "[].{Name:name, Fqdn:properties.configuration.ingress.fqdn}" | ConvertFrom-Json
    
    if ($containerApps) {
        Write-Host "🌐 Your application is available at:" -ForegroundColor Green
        foreach ($app in $containerApps) {
            Write-Host "  https://$($app.Fqdn)" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "To delete this environment when done:" -ForegroundColor Yellow
    Write-Host "  az devcenter dev environment delete --dev-center 'ade-sandbox-dc' --project-name 'ade-sandbox-project' --name '$EnvironmentName' --user-id 'me' --yes" -ForegroundColor White
    
} else {
    Write-Host "✗ Failed to create environment" -ForegroundColor Red
}