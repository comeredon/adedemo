# Azure Deployment Environments Setup Script
# This script sets up the complete ADE infrastructure for the Container App demo

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = "ade-cre-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$DevCenterName = "devcenter-cre-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "containerapp-project",
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepoUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubPAT,
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubBranch = "main",
    
    [Parameter(Mandatory=$false)]
    [string]$CatalogName = "container-templates"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Deployment Environments Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current user for identity assignment
$currentUser = az ad signed-in-user show --query id -o tsv
Write-Host "✓ Current User ID: $currentUser" -ForegroundColor Green

# Create Dev Center
Write-Host "`nCreating Dev Center: $DevCenterName..." -ForegroundColor Yellow
az devcenter admin devcenter create `
    --name $DevCenterName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --identity-type SystemAssigned

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dev Center created successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to create Dev Center" -ForegroundColor Red
    exit 1
}

# Get Dev Center identity for role assignment
$devCenterIdentity = az devcenter admin devcenter show `
    --name $DevCenterName `
    --resource-group $ResourceGroupName `
    --query identity.principalId -o tsv

Write-Host "✓ Dev Center Identity: $devCenterIdentity" -ForegroundColor Green

# Assign Contributor role to Dev Center on the resource group
Write-Host "`nAssigning Contributor role to Dev Center..." -ForegroundColor Yellow
az role assignment create `
    --assignee $devCenterIdentity `
    --role "Contributor" `
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Role assigned successfully" -ForegroundColor Green
} else {
    Write-Host "⚠ Role assignment may have failed (might already exist)" -ForegroundColor Yellow
}

# Create Catalog with GitHub repo
Write-Host "`nCreating Catalog: $CatalogName..." -ForegroundColor Yellow
az devcenter admin catalog create `
    --name $CatalogName `
    --dev-center-name $DevCenterName `
    --resource-group $ResourceGroupName `
    --git-hub uri=$GitHubRepoUrl branch=$GitHubBranch path="/ade-templates" secret-identifier=$GitHubPAT

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Catalog created successfully" -ForegroundColor Green
    Write-Host "  Syncing catalog (this may take a few minutes)..." -ForegroundColor Yellow
    
    # Wait for catalog sync
    Start-Sleep -Seconds 10
    
    $syncStatus = az devcenter admin catalog show `
        --name $CatalogName `
        --dev-center-name $DevCenterName `
        --resource-group $ResourceGroupName `
        --query syncState -o tsv
    
    Write-Host "  Catalog sync status: $syncStatus" -ForegroundColor Cyan
} else {
    Write-Host "✗ Failed to create Catalog" -ForegroundColor Red
    exit 1
}

# Create Environment Types
Write-Host "`nCreating Environment Types..." -ForegroundColor Yellow
$envTypes = @("Dev", "Test", "Production")

foreach ($envType in $envTypes) {
    Write-Host "  Creating environment type: $envType" -ForegroundColor Cyan
    az devcenter admin environment-type create `
        --name $envType `
        --dev-center-name $DevCenterName `
        --resource-group $ResourceGroupName
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ $envType environment type created" -ForegroundColor Green
    }
}

# Create Project
Write-Host "`nCreating Project: $ProjectName..." -ForegroundColor Yellow
az devcenter admin project create `
    --name $ProjectName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --dev-center-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.DevCenter/devcenters/$DevCenterName"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Project created successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to create Project" -ForegroundColor Red
    exit 1
}

# Configure Project Environment Types
Write-Host "`nConfiguring Project Environment Types..." -ForegroundColor Yellow
foreach ($envType in $envTypes) {
    Write-Host "  Configuring $envType for project" -ForegroundColor Cyan
    
    az devcenter admin project-environment-type create `
        --name $envType `
        --project-name $ProjectName `
        --resource-group $ResourceGroupName `
        --deployment-target-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName" `
        --status Enabled `
        --identity-type SystemAssigned `
        --roles "{'b24988ac-6180-42a0-ab88-20f7382dd24c':'Contributor'}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ $envType configured for project" -ForegroundColor Green
    }
}

# Assign DevCenter Dev User role to current user
Write-Host "`nAssigning DevCenter Dev User role to current user..." -ForegroundColor Yellow
$projectId = az devcenter admin project show `
    --name $ProjectName `
    --resource-group $ResourceGroupName `
    --query id -o tsv

az role assignment create `
    --assignee $currentUser `
    --role "DevCenter Dev User" `
    --scope $projectId

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Role assigned successfully" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resources Created:" -ForegroundColor Yellow
Write-Host "  • Dev Center: $DevCenterName" -ForegroundColor White
Write-Host "  • Project: $ProjectName" -ForegroundColor White
Write-Host "  • Catalog: $CatalogName" -ForegroundColor White
Write-Host "  • Environment Types: Dev, Test, Production" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Push the ade-templates folder to your GitHub repository" -ForegroundColor White
Write-Host "2. Wait for catalog sync to complete (check in Azure Portal)" -ForegroundColor White
Write-Host "3. Developers can create environments using:" -ForegroundColor White
Write-Host ""
Write-Host "   az devcenter dev environment create \" -ForegroundColor Cyan
Write-Host "     --dev-center $DevCenterName \" -ForegroundColor Cyan
Write-Host "     --project-name $ProjectName \" -ForegroundColor Cyan
Write-Host "     --environment-name my-container-app \" -ForegroundColor Cyan
Write-Host "     --environment-type Dev \" -ForegroundColor Cyan
Write-Host "     --catalog-name $CatalogName \" -ForegroundColor Cyan
Write-Host "     --environment-definition-name container-app-demo" -ForegroundColor Cyan
Write-Host ""
Write-Host "View in Portal:" -ForegroundColor Yellow
Write-Host "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName/providers/Microsoft.DevCenter/devcenters/$DevCenterName" -ForegroundColor Cyan
Write-Host ""
