# Create .env file script
# This helps you create the .env file with required values

Write-Host "=== BootyHunter .env File Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if .env already exists
if (Test-Path ".\.env") {
    Write-Host "⚠️  .env file already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Aborted. Keeping existing .env file." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Setting up .env file..." -ForegroundColor Yellow
Write-Host ""

# Get PostgreSQL password
Write-Host "PostgreSQL Configuration:" -ForegroundColor Cyan
$dbPassword = Read-Host "Enter PostgreSQL password (the one you set during installation)"
if ([string]::IsNullOrWhiteSpace($dbPassword)) {
    Write-Host "❌ Password is required!" -ForegroundColor Red
    exit 1
}

# Generate secrets
Write-Host ""
Write-Host "Generating secrets..." -ForegroundColor Yellow
try {
    $railsSecret = rails secret 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Could not generate Rails secret. Using random string." -ForegroundColor Yellow
        Add-Type -AssemblyName System.Security
        $bytes = New-Object byte[] 64
        $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
        $rng.GetBytes($bytes)
        $railsSecret = -join ($bytes | ForEach-Object { '{0:X2}' -f $_ })
    }
} catch {
    Write-Host "⚠️  Rails not found. Using random string for secret." -ForegroundColor Yellow
    Add-Type -AssemblyName System.Security
    $bytes = New-Object byte[] 64
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $rng.GetBytes($bytes)
    $railsSecret = -join ($bytes | ForEach-Object { '{0:X2}' -f $_ })
}

# Create .env content
$envContent = @"
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=$dbPassword

# Rails Configuration
RAILS_ENV=development
SECRET_KEY_BASE=$railsSecret
RAILS_MAX_THREADS=5

# JWT Authentication
JWT_SECRET_KEY=$railsSecret

# Redis (for Sidekiq background jobs)
REDIS_URL=redis://localhost:6379/0

# Google Gemini AI (Add later when API keys are ready)
# GEMINI_API_KEY=your_gemini_api_key_here

# Google Cloud Storage (Add later when API keys are ready)
# GOOGLE_CLOUD_PROJECT_ID=your_project_id_here
# GOOGLE_CLOUD_STORAGE_BUCKET=your_bucket_name_here
# GOOGLE_CLOUD_CREDENTIALS_PATH=path/to/credentials.json

# Square MCP Integration (Add later when API keys are ready)
# SQUARE_ACCESS_TOKEN=your_square_access_token_here
# SQUARE_APPLICATION_ID=your_square_application_id_here
# SQUARE_LOCATION_ID=your_square_location_id_here

# Discogs MCP Integration (Add later when API keys are ready)
# DISCOGS_USER_TOKEN=your_discogs_user_token_here

# Admin Authentication
ADMIN_PASSWORD=change_me_to_secure_password

# CORS Origins (for development)
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
"@

# Write to file
$envContent | Out-File -FilePath ".\.env" -Encoding utf8 -NoNewline

Write-Host ""
Write-Host "✅ .env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review .env file: notepad .env" -ForegroundColor White
Write-Host "2. Run database setup: .\scripts\setup_database.ps1" -ForegroundColor White
Write-Host ""

