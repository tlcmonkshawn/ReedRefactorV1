# PowerShell script to generate secure secrets for Rails application
# Usage: .\scripts\generate_secrets.ps1

Write-Host "=" * 60
Write-Host "BootieHunter V1 - Secret Generation"
Write-Host "=" * 60
Write-Host ""

# Generate Rails secret key base (64 bytes = 128 hex characters)
$railsSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 128 | ForEach-Object { [char]$_ })
$railsSecret = -join ((0..255) | Get-Random -Count 64 | ForEach-Object { '{0:X2}' -f $_ })
# Better approach: use .NET's RNGCryptoServiceProvider
Add-Type -AssemblyName System.Security
$bytes = New-Object byte[] 64
$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$rng.GetBytes($bytes)
$railsSecret = -join ($bytes | ForEach-Object { '{0:X2}' -f $_ })

# Generate JWT secret key (32 bytes = 64 hex characters)
$jwtBytes = New-Object byte[] 32
$rng.GetBytes($jwtBytes)
$jwtSecret = -join ($jwtBytes | ForEach-Object { '{0:X2}' -f $_ })

Write-Host "SECRET_KEY_BASE=$railsSecret"
Write-Host ""
Write-Host "JWT_SECRET_KEY=$jwtSecret"
Write-Host ""
Write-Host "=" * 60
Write-Host "Copy these values to your .env file"
Write-Host "=" * 60
Write-Host ""
Write-Host "Note: If you have Rails installed, you can also use: rails secret"

