#!/bin/bash
# Render startup script - fixes SSL connection and starts the server
# Render PostgreSQL REQUIRES SSL - this script ensures DATABASE_URL has sslmode=require

set -e  # Exit immediately if any command fails

echo "=== Starting Render deployment ==="
echo "RAILS_ENV: ${RAILS_ENV:-production}"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL is not set!"
  echo "   Please set DATABASE_URL in Render Dashboard -> Environment Variables"
  exit 1
else
  echo "✅ DATABASE_URL is set"
  
  # Render PostgreSQL REQUIRES SSL
  # According to Render docs: use ?ssl=true or ?sslmode=require
  # We'll use sslmode=require (PostgreSQL standard)
  if [[ "$DATABASE_URL" != *"sslmode"* ]] && [[ "$DATABASE_URL" != *"ssl=true"* ]]; then
    separator="?"
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      separator="&"
    fi
    # Add sslmode=require - Render PostgreSQL requires SSL
    export DATABASE_URL="${DATABASE_URL}${separator}sslmode=require"
    echo "✅ Added sslmode=require to DATABASE_URL (Render PostgreSQL requires SSL)"
  elif [[ "$DATABASE_URL" == *"ssl=true"* ]]; then
    echo "✅ DATABASE_URL already has ssl=true (Render format - will work)"
  else
    # Ensure sslmode is set to 'require' (not 'prefer' or 'allow')
    export DATABASE_URL="${DATABASE_URL//sslmode=prefer/sslmode=require}"
    export DATABASE_URL="${DATABASE_URL//sslmode=allow/sslmode=require}"
    echo "✅ Ensured sslmode=require in DATABASE_URL"
  fi
  
  # Export DATABASE_URL so it's available to Rails
  export DATABASE_URL
fi

# Start the server
echo ""
echo "Starting Puma server..."
exec bundle exec puma -C config/puma.rb

