# Run Migrations Against Render Database
# This connects to the Render PostgreSQL database and runs migrations locally

Write-Host "=== Running Migrations Against Render Database ===" -ForegroundColor Cyan
Write-Host ""

# Check if bundle is available
Write-Host "Checking Ruby dependencies..." -ForegroundColor Yellow
try {
    $bundleCheck = bundle check 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Installing dependencies..." -ForegroundColor Yellow
        bundle install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "✅ Dependencies ready" -ForegroundColor Green
} catch {
    Write-Host "❌ Bundle not found. Make sure Rails is installed." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Render database connection details
$DATABASE_URL = "postgresql://reed_refactor_v1_db_user:SxjuMqAwC8DOmmrwZ6Bm1lfMz2u6g9ZD@dpg-d48g7n4hg0os73894qrg-a.oregon-postgres.render.com:5432/reed_refactor_v1_db?sslmode=require"

Write-Host "Connecting to Render database..." -ForegroundColor Yellow
Write-Host "Database: reed_refactor_v1_db" -ForegroundColor Gray
Write-Host "Host: dpg-d48g7n4hg0os73894qrg-a.oregon-postgres.render.com" -ForegroundColor Gray
Write-Host ""

# Set environment variable for Rails
$env:DATABASE_URL = $DATABASE_URL
$env:RAILS_ENV = "production"

Write-Host "Running migrations..." -ForegroundColor Yellow
bundle exec rails db:migrate

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Migrations completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verifying migrations..." -ForegroundColor Yellow
    
    # Check migration status
    bundle exec rails runner "puts 'Migrations run: ' + ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM schema_migrations').first['count'].to_s"
    bundle exec rails runner "puts 'Users table exists: ' + ActiveRecord::Base.connection.table_exists?('users').to_s"
    
    Write-Host ""
    Write-Host "=== Migration Complete! ===" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Migrations failed!" -ForegroundColor Red
    exit 1
}

