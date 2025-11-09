#!/bin/bash
# Grant Cloud Run service account access to Secret Manager secrets

set -e

PROJECT_ID="reed-bootie-hunter"

echo "=== Granting Cloud Run access to secrets ==="
echo ""

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Error: Could not get project number for $PROJECT_ID"
    exit 1
fi

SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Project: $PROJECT_ID"
echo "Project Number: $PROJECT_NUMBER"
echo "Service Account: $SERVICE_ACCOUNT"
echo ""

# List of secrets
SECRETS=(
    "SECRET_KEY_BASE"
    "JWT_SECRET_KEY"
    "GEMINI_API_KEY"
    "ADMIN_PASSWORD"
    "GOOGLE_APPLICATION_CREDENTIALS_JSON"
)

# Grant access to each secret
for secret in "${SECRETS[@]}"; do
    echo "Granting access to $secret..."
    
    # Check if secret exists
    if ! gcloud secrets describe $secret --project=$PROJECT_ID &> /dev/null; then
        echo "  ⚠️  Secret $secret does not exist, skipping..."
        continue
    fi
    
    # Grant access
    gcloud secrets add-iam-policy-binding $secret \
        --member="serviceAccount:${SERVICE_ACCOUNT}" \
        --role="roles/secretmanager.secretAccessor" \
        --project=$PROJECT_ID \
        --quiet
    
    echo "  ✅ Access granted to $secret"
done

echo ""
echo "=== Secret access setup complete! ==="
echo ""
echo "Cloud Run services can now access secrets via:"
echo "  --update-secrets SECRET_NAME=SECRET_NAME:latest"

