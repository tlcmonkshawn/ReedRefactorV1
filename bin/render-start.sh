#!/bin/bash
# Render startup script - fixes SSL connection and starts the server
# Render PostgreSQL REQUIRES SSL - this script ensures DATABASE_URL has sslmode=require
# Based on working Bootie Hunter V1 implementation

set -e  # Exit immediately if any command fails

echo "=== Starting Render deployment ==="
echo "RAILS_ENV: ${RAILS_ENV:-production}"
echo "Working directory: $(pwd)"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL is not set!"
  echo "   Please set DATABASE_URL in Render Dashboard -> Environment Variables"
  exit 1
else
  echo "✅ DATABASE_URL is set (length: ${#DATABASE_URL} chars)"
  echo "   First 30 chars: ${DATABASE_URL:0:30}..."
  
  # Render PostgreSQL REQUIRES SSL
  # Database REQUIRES SSL - only set sslmode=require (no certificate parameters needed)
  if [[ "$DATABASE_URL" != *"sslmode"* ]] && [[ "$DATABASE_URL" != *"ssl=true"* ]]; then
    separator="?"
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      separator="&"
    fi
    # Add sslmode=require - Render PostgreSQL requires SSL
    export DATABASE_URL="${DATABASE_URL}${separator}sslmode=require"
    echo "   ✅ Added sslmode=require to DATABASE_URL (database requires SSL)"
  else
    # Ensure sslmode is set to 'require' (database requires SSL)
    export DATABASE_URL="${DATABASE_URL//sslmode=prefer/sslmode=require}"
    export DATABASE_URL="${DATABASE_URL//sslmode=prefer&/sslmode=require&}"
    export DATABASE_URL="${DATABASE_URL//&sslmode=prefer/&sslmode=require}"
    echo "   ✅ Ensured sslmode=require in DATABASE_URL"
  fi
  
  # Export DATABASE_URL so it's available to all child processes (including Rails)
  export DATABASE_URL
fi

# Start the server
echo ""
echo "Starting Puma server..."
exec bundle exec puma -C config/puma.rb

