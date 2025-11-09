#!/bin/bash
# Create Cloud Build triggers for automatic deployment

set -e

PROJECT_ID="reed-bootie-hunter"
REPO_OWNER="tlcmonkshawn"
REPO_NAME="ReedRefactorV1"

echo "=== Creating Cloud Build Triggers ==="
echo "Project: $PROJECT_ID"
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Check if repository is connected
echo "Checking repository connection..."
if ! gcloud source repos list --project=$PROJECT_ID | grep -q "$REPO_NAME"; then
    echo "⚠️  Repository not found in Cloud Source Repositories"
    echo "   Connecting GitHub repository..."
    
    # Connect GitHub repository (requires OAuth)
    echo "   Please connect the repository manually in Cloud Console:"
    echo "   https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID"
    echo ""
    echo "   Or use:"
    echo "   gcloud source repos create $REPO_NAME --project=$PROJECT_ID"
    echo "   Then connect GitHub in Cloud Console"
    echo ""
    read -p "Press Enter after repository is connected..."
fi

# Create backend trigger
echo "Creating backend trigger..."
gcloud builds triggers create github \
    --name="deploy-backend" \
    --description="Deploy backend on push to main" \
    --repo-name="$REPO_NAME" \
    --repo-owner="$REPO_OWNER" \
    --branch-pattern="^main$" \
    --build-config="cloudbuild.yaml" \
    --project=$PROJECT_ID \
    --region=us-west1 \
    || echo "⚠️  Backend trigger may already exist"

echo "✅ Backend trigger created"
echo ""

# Create frontend trigger
echo "Creating frontend trigger..."
gcloud builds triggers create github \
    --name="deploy-frontend" \
    --description="Deploy frontend on push to main" \
    --repo-name="$REPO_NAME" \
    --repo-owner="$REPO_OWNER" \
    --branch-pattern="^main$" \
    --build-config="frontend/cloudbuild.yaml" \
    --project=$PROJECT_ID \
    --region=us-west1 \
    || echo "⚠️  Frontend trigger may already exist"

echo "✅ Frontend trigger created"
echo ""

echo "=== Triggers created! ==="
echo ""
echo "List triggers:"
echo "  gcloud builds triggers list --project=$PROJECT_ID"
echo ""
echo "Test trigger manually:"
echo "  gcloud builds triggers run deploy-backend --branch=main --project=$PROJECT_ID"

