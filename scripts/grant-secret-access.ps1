# Grant Cloud Run service account access to Secret Manager secrets (PowerShell version)

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
    gcloud secrets add-iam-policy-binding $secret `
        --member="serviceAccount:${SERVICE_ACCOUNT}" `
        --role="roles/secretmanager.secretAccessor" `
        --project=$PROJECT_ID `
        --quiet 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Access granted to $secret" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Failed to grant access to $secret" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Secret access setup complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Cloud Run services can now access secrets via:" -ForegroundColor Cyan
Write-Host "  --update-secrets SECRET_NAME=SECRET_NAME:latest" -ForegroundColor White

