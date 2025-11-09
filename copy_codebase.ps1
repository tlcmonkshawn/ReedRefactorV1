# Selective Copy Script - Bootie Hunter V1 → ReedRefactorV1
# Copies only essential code, skips junk

$source = "c:\Code\REED_Bootie_Hunter_V1"
$dest = "c:\Code\ReedRefactorV1"

Write-Host "Starting selective copy from Bootie Hunter V1..." -ForegroundColor Green

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$dest\backend" | Out-Null
New-Item -ItemType Directory -Force -Path "$dest\frontend" | Out-Null
New-Item -ItemType Directory -Force -Path "$dest\docs" | Out-Null
New-Item -ItemType Directory -Force -Path "$dest\backend\scripts" | Out-Null

# Copy Backend
Write-Host "Copying backend..." -ForegroundColor Yellow
Copy-Item -Path "$source\backend\app" -Destination "$dest\backend\app" -Recurse -Force
Copy-Item -Path "$source\backend\config" -Destination "$dest\backend\config" -Recurse -Force
Copy-Item -Path "$source\backend\db" -Destination "$dest\backend\db" -Recurse -Force
Copy-Item -Path "$source\backend\lib" -Destination "$dest\backend\lib" -Recurse -Force
Copy-Item -Path "$source\backend\Gemfile" -Destination "$dest\backend\" -Force
Copy-Item -Path "$source\backend\Gemfile.lock" -Destination "$dest\backend\" -Force
Copy-Item -Path "$source\backend\Procfile" -Destination "$dest\backend\" -Force
Copy-Item -Path "$source\backend\Rakefile" -Destination "$dest\backend\" -Force
Copy-Item -Path "$source\backend\config.ru" -Destination "$dest\backend\" -Force

# Copy essential scripts only
Write-Host "Copying essential scripts..." -ForegroundColor Yellow
Copy-Item -Path "$source\backend\scripts\setup_database.ps1" -Destination "$dest\backend\scripts\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\backend\scripts\generate_secrets.ps1" -Destination "$dest\backend\scripts\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\backend\scripts\generate_secrets.rb" -Destination "$dest\backend\scripts\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\backend\scripts\create_env_file.ps1" -Destination "$dest\backend\scripts\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\backend\scripts\setup_check.rb" -Destination "$dest\backend\scripts\" -Force -ErrorAction SilentlyContinue

# Copy backend docs
if (Test-Path "$source\backend\docs") {
    Copy-Item -Path "$source\backend\docs" -Destination "$dest\backend\docs" -Recurse -Force
}

# Copy Frontend
Write-Host "Copying frontend..." -ForegroundColor Yellow
Copy-Item -Path "$source\frontend\lib" -Destination "$dest\frontend\lib" -Recurse -Force
Copy-Item -Path "$source\frontend\web" -Destination "$dest\frontend\web" -Recurse -Force
Copy-Item -Path "$source\frontend\pubspec.yaml" -Destination "$dest\frontend\" -Force
Copy-Item -Path "$source\frontend\pubspec.lock" -Destination "$dest\frontend\" -Force
Copy-Item -Path "$source\frontend\analysis_options.yaml" -Destination "$dest\frontend\" -Force

# Copy Documentation (excluding archive)
Write-Host "Copying documentation..." -ForegroundColor Yellow
Copy-Item -Path "$source\PRODUCT_PROFILE.md" -Destination "$dest\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\AGENTS.md" -Destination "$dest\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\QUICK_START.md" -Destination "$dest\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$source\DEVELOPER_HANDOFF.md" -Destination "$dest\" -Force -ErrorAction SilentlyContinue

# Copy docs folder but exclude archive
if (Test-Path "$source\docs") {
    Get-ChildItem -Path "$source\docs" -Exclude "archive" | Copy-Item -Destination "$dest\docs\" -Recurse -Force
    # Copy subdirectories individually
    if (Test-Path "$source\docs\backend") {
        Copy-Item -Path "$source\docs\backend" -Destination "$dest\docs\backend" -Recurse -Force
    }
    if (Test-Path "$source\docs\database") {
        Copy-Item -Path "$source\docs\database" -Destination "$dest\docs\database" -Recurse -Force
    }
    if (Test-Path "$source\docs\deployment") {
        Copy-Item -Path "$source\docs\deployment" -Destination "$dest\docs\deployment" -Recurse -Force
    }
    if (Test-Path "$source\docs\frontend") {
        Copy-Item -Path "$source\docs\frontend" -Destination "$dest\docs\frontend" -Recurse -Force
    }
    if (Test-Path "$source\docs\getting-started") {
        Copy-Item -Path "$source\docs\getting-started" -Destination "$dest\docs\getting-started" -Recurse -Force
    }
    # Copy root doc files
    Get-ChildItem -Path "$source\docs\*.md" | Copy-Item -Destination "$dest\docs\" -Force
}

# Copy Configuration
Write-Host "Copying configuration..." -ForegroundColor Yellow
Copy-Item -Path "$source\render.yaml" -Destination "$dest\" -Force -ErrorAction SilentlyContinue

# Verify what was copied
Write-Host "`nVerification:" -ForegroundColor Green
Write-Host "Backend app: $(Test-Path '$dest\backend\app')"
Write-Host "Backend config: $(Test-Path '$dest\backend\config')"
Write-Host "Backend db: $(Test-Path '$dest\backend\db')"
Write-Host "Frontend lib: $(Test-Path '$dest\frontend\lib')"
Write-Host "Docs (no archive): $(Test-Path '$dest\docs') - Archive excluded: $(-not (Test-Path '$dest\docs\archive'))"

Write-Host "`nCopy complete! Review the code and commit." -ForegroundColor Green

