# Database Setup Script
# Run this after installing PostgreSQL and setting up .env file

Write-Host "=== BootyHunter Database Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path ".\.env")) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "   Please create .env file from .env.template" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ .env file found" -ForegroundColor Green
Write-Host ""

# Check if bundle is installed
Write-Host "Checking Ruby dependencies..." -ForegroundColor Yellow
try {
    $bundleCheck = bundle check 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Installing dependencies..." -ForegroundColor Yellow
        bundle install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Bundle not found. Make sure Rails is installed." -ForegroundColor Red
    Write-Host "   Install with: gem install rails" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Create database
Write-Host "Creating database..." -ForegroundColor Yellow
rails db:create
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create database" -ForegroundColor Red
    Write-Host "   Check your .env file has correct PostgreSQL password" -ForegroundColor Yellow
    Write-Host "   Make sure PostgreSQL is running" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Database created" -ForegroundColor Green

Write-Host ""

# Run migrations
Write-Host "Running migrations..." -ForegroundColor Yellow
rails db:migrate
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to run migrations" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Migrations completed" -ForegroundColor Green

Write-Host ""
Write-Host "=== Database Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Start Rails server: rails server" -ForegroundColor White
Write-Host "2. Test: Open http://localhost:3000/health" -ForegroundColor White
Write-Host ""

