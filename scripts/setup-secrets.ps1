# Setup Secret Manager secrets for GCP deployment (PowerShell version)
# This script creates all required secrets in Google Secret Manager

$ErrorActionPreference = "Stop"

$PROJECT_ID = "reed-bootie-hunter"
$REGION = "us-west1"

Write-Host "=== Setting up Secret Manager secrets for $PROJECT_ID ===" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
try {
    $null = gcloud --version 2>&1
} catch {
    Write-Host "❌ Error: gcloud CLI is not installed" -ForegroundColor Red
    Write-Host "   Install from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

# Check if project exists
try {
    $null = gcloud projects describe $PROJECT_ID 2>&1
} catch {
    Write-Host "❌ Error: Project $PROJECT_ID not found or not accessible" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project $PROJECT_ID found" -ForegroundColor Green
Write-Host ""

# Generate SECRET_KEY_BASE if not provided
if (-not $env:SECRET_KEY_BASE) {
    Write-Host "Generating SECRET_KEY_BASE..." -ForegroundColor Yellow
    # Use OpenSSL if available, otherwise generate random bytes
    try {
        $SECRET_KEY_BASE = openssl rand -hex 64 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "OpenSSL failed"
        }
    } catch {
        # Fallback: use .NET random generator
        $bytes = New-Object byte[] 64
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)
        $SECRET_KEY_BASE = [System.BitConverter]::ToString($bytes).Replace("-", "").ToLower()
    }
    $SECRET_KEY_BASE | Out-File -FilePath ".secret_key_base" -NoNewline
    Write-Host "Generated SECRET_KEY_BASE (saved to .secret_key_base for reference)" -ForegroundColor Green
    Write-Host "⚠️  IMPORTANT: Save this value! It's needed for session encryption." -ForegroundColor Yellow
    Write-Host ""
} else {
    $SECRET_KEY_BASE = $env:SECRET_KEY_BASE
}

# Function to create or update secret
function Create-Secret {
    param(
        [string]$SecretName,
        [string]$SecretValue,
        [string]$Description = ""
    )
    
    Write-Host "Creating/updating secret: $SecretName" -ForegroundColor Yellow
    
    # Check if secret exists
    $secretExists = $false
    try {
        $null = gcloud secrets describe $SecretName --project=$PROJECT_ID 2>&1
        $secretExists = $true
    } catch {
        $secretExists = $false
    }
    
    if ($secretExists) {
        Write-Host "  Secret exists, adding new version..." -ForegroundColor Gray
        $SecretValue | gcloud secrets versions add $SecretName `
            --data-file=- `
            --project=$PROJECT_ID 2>&1 | Out-Null
    } else {
        Write-Host "  Creating new secret..." -ForegroundColor Gray
        $SecretValue | gcloud secrets create $SecretName `
            --data-file=- `
            --replication-policy="automatic" `
            --project=$PROJECT_ID 2>&1 | Out-Null
    }
    
    Write-Host "  ✅ Secret $SecretName created/updated" -ForegroundColor Green
    Write-Host ""
}

# 1. SECRET_KEY_BASE
Create-Secret -SecretName "SECRET_KEY_BASE" -SecretValue $SECRET_KEY_BASE -Description "Rails secret key base for session encryption"

# 2. JWT_SECRET_KEY (use same as SECRET_KEY_BASE or from env)
if (-not $env:JWT_SECRET_KEY) {
    $JWT_SECRET_KEY = $SECRET_KEY_BASE
} else {
    $JWT_SECRET_KEY = $env:JWT_SECRET_KEY
}
Create-Secret -SecretName "JWT_SECRET_KEY" -SecretValue $JWT_SECRET_KEY -Description "JWT secret key for token signing"

# 3. GEMINI_API_KEY (prompt if not set)
if (-not $env:GEMINI_API_KEY) {
    Write-Host "⚠️  GEMINI_API_KEY not set in environment" -ForegroundColor Yellow
    Write-Host "   Please set it: `$env:GEMINI_API_KEY='your-key-here'" -ForegroundColor Yellow
    Write-Host "   Or create it manually:" -ForegroundColor Yellow
    Write-Host "   'your-key' | gcloud secrets create GEMINI_API_KEY --data-file=- --project=$PROJECT_ID" -ForegroundColor Gray
    Write-Host ""
} else {
    Create-Secret -SecretName "GEMINI_API_KEY" -SecretValue $env:GEMINI_API_KEY -Description "Google Gemini API key for AI features"
}

# 4. ADMIN_PASSWORD
if (-not $env:ADMIN_PASSWORD) {
    $ADMIN_PASSWORD = "iamagoodgirl"
    Write-Host "⚠️  Using default ADMIN_PASSWORD. Consider changing it!" -ForegroundColor Yellow
}
Create-Secret -SecretName "ADMIN_PASSWORD" -SecretValue $ADMIN_PASSWORD -Description "Admin password for migration endpoints"

# 5. GOOGLE_APPLICATION_CREDENTIALS_JSON (check for file)
if (-not $env:GOOGLE_APPLICATION_CREDENTIALS_JSON) {
    if (Test-Path "service-account-key.json") {
        Write-Host "Found service-account-key.json, using it for GOOGLE_APPLICATION_CREDENTIALS_JSON" -ForegroundColor Green
        $GOOGLE_APPLICATION_CREDENTIALS_JSON = Get-Content "service-account-key.json" -Raw
        Create-Secret -SecretName "GOOGLE_APPLICATION_CREDENTIALS_JSON" -SecretValue $GOOGLE_APPLICATION_CREDENTIALS_JSON -Description "Google Cloud service account JSON credentials"
    } else {
        Write-Host "⚠️  GOOGLE_APPLICATION_CREDENTIALS_JSON not set and service-account-key.json not found" -ForegroundColor Yellow
        Write-Host "   Create a service account and download the key, then:" -ForegroundColor Yellow
        Write-Host "   Get-Content service-account-key.json | gcloud secrets create GOOGLE_APPLICATION_CREDENTIALS_JSON --data-file=- --project=$PROJECT_ID" -ForegroundColor Gray
        Write-Host ""
    }
} else {
    Create-Secret -SecretName "GOOGLE_APPLICATION_CREDENTIALS_JSON" -SecretValue $env:GOOGLE_APPLICATION_CREDENTIALS_JSON -Description "Google Cloud service account JSON credentials"
}

Write-Host "=== Secret setup complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Grant Cloud Run service account access to secrets (run scripts/grant-secret-access.ps1)" -ForegroundColor White
Write-Host "2. Verify secrets: gcloud secrets list --project=$PROJECT_ID" -ForegroundColor White
Write-Host ""

