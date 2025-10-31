# Setup Service Principal for GitHub Actions
# This script creates the necessary Azure service principal for GitHub Actions to deploy to ADE

param(
    [Parameter(Mandatory=$false)]
    [string]$ServicePrincipalName = "github-actions-ade-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "ade-cre-demo",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "ade-sandbox-project"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Actions Service Principal Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current subscription
$subscriptionId = az account show --query id -o tsv
Write-Host "✓ Using subscription: $subscriptionId" -ForegroundColor Green

# Create service principal with Contributor role on resource group
Write-Host "`nCreating service principal: $ServicePrincipalName..." -ForegroundColor Yellow
$spOutput = az ad sp create-for-rbac `
    --name $ServicePrincipalName `
    --role "Contributor" `
    --scopes "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName" `
    --json-auth

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Service principal created successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to create service principal" -ForegroundColor Red
    exit 1
}

# Parse the service principal output to get client ID
$spJson = $spOutput | ConvertFrom-Json
$clientId = $spJson.clientId
Write-Host "✓ Service Principal Client ID: $clientId" -ForegroundColor Green

# Assign Deployment Environments User role on the project
Write-Host "`nAssigning Deployment Environments User role..." -ForegroundColor Yellow
$projectScope = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.DevCenter/projects/$ProjectName"

az role assignment create `
    --assignee $clientId `
    --role "Deployment Environments User" `
    --scope $projectScope

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Role assigned successfully" -ForegroundColor Green
} else {
    Write-Host "⚠ Role assignment may have failed (might already exist)" -ForegroundColor Yellow
}

# Display the JSON for GitHub secret
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Secret Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to your GitHub repository" -ForegroundColor Yellow
Write-Host "2. Navigate to Settings → Secrets and variables → Actions" -ForegroundColor Yellow
Write-Host "3. Click 'New repository secret'" -ForegroundColor Yellow
Write-Host "4. Name: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "5. Value: Copy the JSON below" -ForegroundColor Yellow
Write-Host ""
Write-Host "JSON for GitHub Secret (AZURE_CREDENTIALS):" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host $spOutput -ForegroundColor White
Write-Host ""
Write-Host "⚠️ IMPORTANT: Save this JSON securely - it contains sensitive credentials!" -ForegroundColor Red
Write-Host ""

# Test the service principal
Write-Host "Testing service principal authentication..." -ForegroundColor Yellow
$testLogin = az login --service-principal `
    --username $spJson.clientId `
    --password $spJson.clientSecret `
    --tenant $spJson.tenantId 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Service principal authentication test successful" -ForegroundColor Green
    
    # Test ADE permissions
    Write-Host "`nTesting Deployment Environments permissions..." -ForegroundColor Yellow
    $testCommand = az devcenter dev environment list `
        --dev-center "ade-sandbox-dc" `
        --project-name $ProjectName `
        --user-id "me" 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Deployment Environments access test successful" -ForegroundColor Green
    } else {
        Write-Host "⚠ Deployment Environments access test failed - check permissions" -ForegroundColor Yellow
    }
    
    # Switch back to original account
    Write-Host "`nSwitching back to your account..." -ForegroundColor Yellow
    az logout
    # Note: User will need to re-authenticate, but that's expected
} else {
    Write-Host "⚠ Service principal authentication test failed" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Copy the JSON above and add it as AZURE_CREDENTIALS secret in GitHub" -ForegroundColor White
Write-Host "2. Commit and push the GitHub Actions workflows to your repository" -ForegroundColor White
Write-Host "3. Test the deployment workflow in GitHub Actions" -ForegroundColor White
Write-Host ""
Write-Host "GitHub Repository: https://github.com/comeredon/adedemo" -ForegroundColor Cyan
Write-Host "Actions URL: https://github.com/comeredon/adedemo/actions" -ForegroundColor Cyan
Write-Host ""
