# Grant Cloud Run service account access to secrets
# Run this AFTER the first Cloud Run deployment (service account will be auto-created)

$ErrorActionPreference = "Stop"

$PROJECT_ID = "reed-bootie-hunter"

Write-Host "=== Granting Cloud Run access to secrets ===" -ForegroundColor Cyan
Write-Host ""

# Get project number
$PROJECT_NUMBER = gcloud projects describe $PROJECT_ID --format="value(projectNumber)"

if (-not $PROJECT_NUMBER) {
    Write-Host "❌ Error: Could not get project number for $PROJECT_ID" -ForegroundColor Red
    exit 1
}

$SERVICE_ACCOUNT = "${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

Write-Host "Project: $PROJECT_ID" -ForegroundColor White
Write-Host "Project Number: $PROJECT_NUMBER" -ForegroundColor White
Write-Host "Service Account: $SERVICE_ACCOUNT" -ForegroundColor White
Write-Host ""

# List of secrets
$SECRETS = @(
    "SECRET_KEY_BASE",
    "JWT_SECRET_KEY",
    "GEMINI_API_KEY",
    "ADMIN_PASSWORD",
    "GOOGLE_APPLICATION_CREDENTIALS_JSON"
)

# Grant access to each secret
$successCount = 0
foreach ($secret in $SECRETS) {
    Write-Host "Granting access to $secret..." -ForegroundColor Yellow
    
    # Check if secret exists
    try {
        $null = gcloud secrets describe $secret --project=$PROJECT_ID 2>&1
    } catch {
        Write-Host "  ⚠️  Secret $secret does not exist, skipping..." -ForegroundColor Yellow
        continue
    }
    
    # Grant access
    $output = gcloud secrets add-iam-policy-binding $secret `
        --member="serviceAccount:${SERVICE_ACCOUNT}" `
        --role="roles/secretmanager.secretAccessor" `
        --project=$PROJECT_ID `
        2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Access granted to $secret" -ForegroundColor Green
        $successCount++
    } else {
        if ($output -match "does not exist") {
            Write-Host "  ⚠️  Service account not created yet" -ForegroundColor Yellow
            Write-Host "     It will be auto-created on first Cloud Run deployment" -ForegroundColor Gray
            Write-Host "     Run this script again after deploying to Cloud Run" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠️  Failed: $output" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
if ($successCount -eq $SECRETS.Count) {
    Write-Host "=== Secret access setup complete! ===" -ForegroundColor Green
} else {
    Write-Host "=== Partial setup complete ===" -ForegroundColor Yellow
    Write-Host "Some permissions may need to be granted after first Cloud Run deployment" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Cloud Run services can now access secrets via:" -ForegroundColor Cyan
Write-Host "  --update-secrets SECRET_NAME=SECRET_NAME:latest" -ForegroundColor White

