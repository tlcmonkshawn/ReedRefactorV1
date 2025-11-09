#!/bin/bash
# Deploy frontend to Cloud Run

set -e

PROJECT_ID="reed-bootie-hunter"
REGION="us-west1"
SERVICE_NAME="reed-refactor-v1-frontend"

echo "=== Deploying Frontend to Cloud Run ==="
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    exit 1
fi

# Get backend URL for API_URL env var
BACKEND_URL=$(gcloud run services describe reed-refactor-v1-backend \
    --region=$REGION \
    --format="value(status.url)" \
    --project=$PROJECT_ID 2>/dev/null || echo "")

if [ -z "$BACKEND_URL" ]; then
    echo "⚠️  Warning: Could not get backend URL"
    echo "   Make sure backend is deployed first"
    BACKEND_URL="https://reed-refactor-v1-backend-XXX-uw.a.run.app"
fi

echo "Backend URL: $BACKEND_URL"
echo ""

# Submit build
echo "Submitting build to Cloud Build..."
cd frontend
gcloud builds submit \
    --config=cloudbuild.yaml \
    --project=$PROJECT_ID \
    --substitutions=_API_URL=$BACKEND_URL

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

