#!/bin/bash
# Setup Secret Manager secrets for GCP deployment
# This script creates all required secrets in Google Secret Manager

set -e

PROJECT_ID="reed-bootie-hunter"
REGION="us-west1"

echo "=== Setting up Secret Manager secrets for $PROJECT_ID ==="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "   Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if project exists
if ! gcloud projects describe $PROJECT_ID &> /dev/null; then
    echo "❌ Error: Project $PROJECT_ID not found or not accessible"
    exit 1
fi

echo "✅ Project $PROJECT_ID found"
echo ""

# Generate SECRET_KEY_BASE if not provided
if [ -z "$SECRET_KEY_BASE" ]; then
    echo "Generating SECRET_KEY_BASE..."
    SECRET_KEY_BASE=$(openssl rand -hex 64)
    echo "Generated SECRET_KEY_BASE (saving to .secret_key_base for reference)"
    echo "$SECRET_KEY_BASE" > .secret_key_base
    echo "⚠️  IMPORTANT: Save this value! It's needed for session encryption."
    echo ""
fi

# Create or update secrets
create_secret() {
    local secret_name=$1
    local secret_value=$2
    local description=$3
    
    echo "Creating/updating secret: $secret_name"
    
    # Check if secret exists
    if gcloud secrets describe $secret_name --project=$PROJECT_ID &> /dev/null; then
        echo "  Secret exists, adding new version..."
        echo -n "$secret_value" | gcloud secrets versions add $secret_name \
            --data-file=- \
            --project=$PROJECT_ID
    else
        echo "  Creating new secret..."
        echo -n "$secret_value" | gcloud secrets create $secret_name \
            --data-file=- \
            --replication-policy="automatic" \
            --project=$PROJECT_ID
    fi
    
    # Add description if provided
    if [ -n "$description" ]; then
        gcloud secrets update $secret_name \
            --update-labels="description=$description" \
            --project=$PROJECT_ID &> /dev/null || true
    fi
    
    echo "  ✅ Secret $secret_name created/updated"
    echo ""
}

# 1. SECRET_KEY_BASE
create_secret "SECRET_KEY_BASE" "$SECRET_KEY_BASE" "Rails secret key base for session encryption"

# 2. JWT_SECRET_KEY (use same as SECRET_KEY_BASE or generate new)
if [ -z "$JWT_SECRET_KEY" ]; then
    JWT_SECRET_KEY="$SECRET_KEY_BASE"
fi
create_secret "JWT_SECRET_KEY" "$JWT_SECRET_KEY" "JWT secret key for token signing"

# 3. GEMINI_API_KEY (prompt if not set)
if [ -z "$GEMINI_API_KEY" ]; then
    echo "⚠️  GEMINI_API_KEY not set in environment"
    echo "   Please set it: export GEMINI_API_KEY='your-key-here'"
    echo "   Or create it manually:"
    echo "   echo -n 'your-key' | gcloud secrets create GEMINI_API_KEY --data-file=- --project=$PROJECT_ID"
    echo ""
else
    create_secret "GEMINI_API_KEY" "$GEMINI_API_KEY" "Google Gemini API key for AI features"
fi

# 4. ADMIN_PASSWORD
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="iamagoodgirl"
    echo "⚠️  Using default ADMIN_PASSWORD. Consider changing it!"
fi
create_secret "ADMIN_PASSWORD" "$ADMIN_PASSWORD" "Admin password for migration endpoints"

# 5. GOOGLE_APPLICATION_CREDENTIALS_JSON (check for file)
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ]; then
    if [ -f "service-account-key.json" ]; then
        echo "Found service-account-key.json, using it for GOOGLE_APPLICATION_CREDENTIALS_JSON"
        GOOGLE_APPLICATION_CREDENTIALS_JSON=$(cat service-account-key.json)
        create_secret "GOOGLE_APPLICATION_CREDENTIALS_JSON" "$GOOGLE_APPLICATION_CREDENTIALS_JSON" "Google Cloud service account JSON credentials"
    else
        echo "⚠️  GOOGLE_APPLICATION_CREDENTIALS_JSON not set and service-account-key.json not found"
        echo "   Create a service account and download the key, then:"
        echo "   cat service-account-key.json | gcloud secrets create GOOGLE_APPLICATION_CREDENTIALS_JSON --data-file=- --project=$PROJECT_ID"
        echo ""
    fi
else
    create_secret "GOOGLE_APPLICATION_CREDENTIALS_JSON" "$GOOGLE_APPLICATION_CREDENTIALS_JSON" "Google Cloud service account JSON credentials"
fi

echo "=== Secret setup complete! ==="
echo ""
echo "Next steps:"
echo "1. Grant Cloud Run service account access to secrets (run scripts/grant-secret-access.sh)"
echo "2. Verify secrets: gcloud secrets list --project=$PROJECT_ID"
echo ""

