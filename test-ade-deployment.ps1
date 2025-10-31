# Quick Test Script for Azure Deployment Environment
# This script creates a test environment using the container app template

param(
    [Parameter(Mandatory=$false)]
    [string]$DevCenterName = "devcenter-cre-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "containerapp-project",
    
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName = "test-container-app-$(Get-Random -Maximum 9999)",
    
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentType = "Dev",
    
    [Parameter(Mandatory=$false)]
    [string]$CatalogName = "container-templates"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating Test Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment Name: $EnvironmentName" -ForegroundColor Yellow
Write-Host "Environment Type: $EnvironmentType" -ForegroundColor Yellow
Write-Host ""

# Create the environment
Write-Host "Creating environment (this may take several minutes)..." -ForegroundColor Yellow

az devcenter dev environment create `
    --dev-center $DevCenterName `
    --project-name $ProjectName `
    --environment-name $EnvironmentName `
    --environment-type $EnvironmentType `
    --catalog-name $CatalogName `
    --environment-definition-name container-app-demo `
    --parameters '{\"containerAppName\": \"demo-app-'$(Get-Random -Maximum 9999)'\"}' `
    --user-id "@me"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Environment creation initiated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Monitor deployment status with:" -ForegroundColor Yellow
    Write-Host "az devcenter dev environment show \" -ForegroundColor Cyan
    Write-Host "  --dev-center $DevCenterName \" -ForegroundColor Cyan
    Write-Host "  --project-name $ProjectName \" -ForegroundColor Cyan
    Write-Host "  --name $EnvironmentName \" -ForegroundColor Cyan
    Write-Host "  --user-id @me" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "List all environments:" -ForegroundColor Yellow
    Write-Host "az devcenter dev environment list \" -ForegroundColor Cyan
    Write-Host "  --dev-center $DevCenterName \" -ForegroundColor Cyan
    Write-Host "  --project-name $ProjectName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Delete environment when done:" -ForegroundColor Yellow
    Write-Host "az devcenter dev environment delete \" -ForegroundColor Cyan
    Write-Host "  --dev-center $DevCenterName \" -ForegroundColor Cyan
    Write-Host "  --project-name $ProjectName \" -ForegroundColor Cyan
    Write-Host "  --name $EnvironmentName \" -ForegroundColor Cyan
    Write-Host "  --user-id @me --yes" -ForegroundColor Cyan
} else {
    Write-Host "✗ Failed to create environment" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "1. Verify catalog has synced successfully" -ForegroundColor White
    Write-Host "2. Check that environment definition exists in catalog" -ForegroundColor White
    Write-Host "3. Ensure you have proper permissions (DevCenter Dev User role)" -ForegroundColor White
    exit 1
}
