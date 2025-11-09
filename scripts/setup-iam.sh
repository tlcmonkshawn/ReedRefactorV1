#!/bin/bash
# Setup IAM permissions for GCP deployment

set -e

PROJECT_ID="reed-bootie-hunter"

echo "=== Setting up IAM permissions ==="
echo "Project: $PROJECT_ID"
echo ""

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Error: Could not get project number"
    exit 1
fi

COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "Compute Service Account: $COMPUTE_SA"
echo "Build Service Account: $BUILD_SA"
echo ""

# Grant Cloud Build permissions
echo "Granting Cloud Build permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SA}" \
    --role="roles/run.admin" \
    --condition=None \
    --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SA}" \
    --role="roles/iam.serviceAccountUser" \
    --condition=None \
    --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SA}" \
    --role="roles/storage.admin" \
    --condition=None \
    --quiet

echo "✅ Cloud Build permissions granted"
echo ""

# Grant Cloud Run service account permissions
echo "Granting Cloud Run service account permissions..."

# Storage access
gsutil iam ch serviceAccount:${COMPUTE_SA}:objectAdmin gs://reed-refactor-v1-images 2>/dev/null || \
    echo "⚠️  Could not grant storage access (bucket may not exist yet)"

# Firestore access is usually granted by default, but verify
echo "✅ Cloud Run permissions granted"
echo ""

# Grant secret access (run the secret access script)
echo "Granting secret access..."
if [ -f "scripts/grant-secret-access.sh" ]; then
    bash scripts/grant-secret-access.sh
else
    echo "⚠️  grant-secret-access.sh not found, run it manually"
fi

echo ""
echo "=== IAM setup complete! ==="

