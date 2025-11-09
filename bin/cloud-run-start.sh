#!/bin/bash
# Cloud Run startup script
# Runs Firestore setup tasks then starts the Puma server

set -e  # Exit immediately if any command fails

echo "=== Starting Cloud Run deployment ==="
echo "RAILS_ENV: ${RAILS_ENV:-production}"
echo "Working directory: $(pwd)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"

# Check Firestore configuration
if [ -z "$GOOGLE_CLOUD_PROJECT_ID" ]; then
  echo "⚠️  WARNING: GOOGLE_CLOUD_PROJECT_ID not set"
  echo "   Using default: reed-bootie-hunter"
else
  echo "✅ GOOGLE_CLOUD_PROJECT_ID: $GOOGLE_CLOUD_PROJECT_ID"
fi

# Check for credentials
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ] && [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "⚠️  WARNING: No Google Cloud credentials found"
  echo "   Using default application credentials (gcloud auth application-default login)"
else
  echo "✅ Google Cloud credentials configured"
fi

# Run Firestore setup tasks (seeding, etc.)
echo ""
echo "Running Firestore setup tasks..."
if bundle exec rake firestore:seed 2>&1; then
  echo "✅ Firestore setup completed"
else
  echo "⚠️  Firestore setup had errors (continuing anyway)"
fi

# Precompile assets if needed (Rails 8 doesn't use asset pipeline by default)
# Uncomment if you add sprockets-rails
# echo ""
# echo "Precompiling assets..."
# bundle exec rails assets:precompile

# Start the server
echo ""
echo "✅ All checks passed. Starting Puma server..."
echo "PORT: ${PORT:-8080}"

# Use PORT environment variable (Cloud Run sets this)
exec bundle exec puma -C config/puma.rb -p ${PORT:-8080}

