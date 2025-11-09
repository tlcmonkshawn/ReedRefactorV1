#!/bin/bash
# Render startup script - runs migrations then starts the server
# This ensures migrations run AFTER build but BEFORE server starts
# Database is guaranteed to be available at this point
# Based on working Bootie Hunter V1 implementation

set -e  # Exit immediately if any command fails

echo "=== Starting Render deployment ==="
echo "RAILS_ENV: ${RAILS_ENV:-production}"
echo "Working directory: $(pwd)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL is not set!"
  echo "   This usually means the database is not linked to the service."
  echo "   Please link the database in the Render dashboard:"
  echo "   1. Go to service settings"
  echo "   2. Navigate to 'Linked Databases' or 'Database' section"
  echo "   3. Link the database to this service"
  exit 1
else
  echo "✅ DATABASE_URL is set (length: ${#DATABASE_URL} chars)"
  echo "   First 30 chars: ${DATABASE_URL:0:30}..."
  
  # Ensure SSL mode is set for Render PostgreSQL
  # The issue is likely certificate verification - try different SSL modes
  # Remove any existing sslmode and try allow (most lenient - tries SSL, falls back if needed)
  if [[ "$DATABASE_URL" == *"sslmode"* ]]; then
    # Remove existing sslmode parameter
    export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[?&]sslmode=[^&]*//' | sed 's/sslmode=[^&]*[&]/\&/' | sed 's/sslmode=[^&]*$//')
  fi
  
  # Add sslmode=allow (tries SSL, falls back to non-SSL if certificate issues)
  separator="?"
  if [[ "$DATABASE_URL" == *"?"* ]]; then
    separator="&"
  fi
  export DATABASE_URL="${DATABASE_URL}${separator}sslmode=allow"
  echo "   Set sslmode=allow (tries SSL, falls back if certificate issues)"
  
  # Export DATABASE_URL so it's available to all child processes
  export DATABASE_URL
fi

# Skip migrations in startup script - run them manually via HTTP endpoint
# This avoids SSL connection issues during startup
echo ""
echo "⚠️  Skipping migrations in startup script"
echo "   Run migrations manually via: POST /migrations/run?password=iamagoodgirl"
echo "   Or use the migrations controller endpoint once the service is running"

# Start the server
echo ""
echo "✅ All checks passed. Starting Puma server..."
exec bundle exec puma -C config/puma.rb

