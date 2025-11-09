#!/bin/bash
# Deploy backend to Cloud Run

set -e

PROJECT_ID="reed-bootie-hunter"
REGION="us-west1"
SERVICE_NAME="reed-refactor-v1-backend"

echo "=== Deploying Backend to Cloud Run ==="
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    exit 1
fi

# Submit build
echo "Submitting build to Cloud Build..."
gcloud builds submit \
    --config=cloudbuild.yaml \
    --project=$PROJECT_ID

echo ""
echo "✅ Build submitted successfully!"
echo ""
echo "Service URL:"
gcloud run services describe $SERVICE_NAME \
    --region=$REGION \
    --format="value(status.url)" \
    --project=$PROJECT_ID

echo ""
echo "To view logs:"
echo "  gcloud run services logs read $SERVICE_NAME --region=$REGION --project=$PROJECT_ID"

