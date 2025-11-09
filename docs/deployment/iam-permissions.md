# IAM Permissions Setup

This document outlines the IAM permissions required for the GCP deployment.

## Service Accounts

### Cloud Run Service Account (Default Compute Service Account)

**Account:** `{PROJECT_NUMBER}-compute@developer.gserviceaccount.com`

**Required Roles:**
- `roles/secretmanager.secretAccessor` - Access secrets from Secret Manager
- `roles/storage.objectAdmin` - Read/write to Cloud Storage bucket (for images)
- `roles/datastore.user` - Read/write to Firestore

**Grant Permissions:**
```bash
PROJECT_ID="reed-bootie-hunter"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Secret Manager access (handled by grant-secret-access.sh)
gcloud secrets add-iam-policy-binding SECRET_NAME \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor" \
    --project=$PROJECT_ID

# Cloud Storage access
gsutil iam ch serviceAccount:${SERVICE_ACCOUNT}:objectAdmin gs://reed-refactor-v1-images

# Firestore access (usually granted by default for compute service account)
```

### Cloud Build Service Account

**Account:** `{PROJECT_NUMBER}@cloudbuild.gserviceaccount.com`

**Required Roles:**
- `roles/run.admin` - Deploy to Cloud Run
- `roles/iam.serviceAccountUser` - Use Cloud Run service account
- `roles/storage.admin` - Push images to Container Registry
- `roles/secretmanager.secretAccessor` - Access secrets during build (if needed)

**Grant Permissions:**
```bash
PROJECT_ID="reed-bootie-hunter"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Cloud Run deployment
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SERVICE_ACCOUNT}" \
    --role="roles/run.admin"

# Service account user
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SERVICE_ACCOUNT}" \
    --role="roles/iam.serviceAccountUser"

# Container Registry
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${BUILD_SERVICE_ACCOUNT}" \
    --role="roles/storage.admin"
```

## User Permissions

### Deployment User (Your Account)

**Required Roles:**
- `roles/owner` or `roles/editor` - Full project access (for initial setup)
- `roles/secretmanager.admin` - Manage secrets
- `roles/cloudbuild.builds.editor` - Trigger builds
- `roles/run.admin` - Deploy to Cloud Run
- `roles/storage.admin` - Manage Cloud Storage
- `roles/datastore.user` - Access Firestore

**Grant Permissions:**
```bash
PROJECT_ID="reed-bootie-hunter"
YOUR_EMAIL="tlcmonkshawn@gmail.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:${YOUR_EMAIL}" \
    --role="roles/editor"
```

## Automated Setup Script

Run the setup script to grant all required permissions:

```bash
./scripts/setup-iam.sh
```

Or manually grant permissions using the commands above.

## Verification

Verify permissions are set correctly:

```bash
# Check service account permissions
gcloud projects get-iam-policy reed-bootie-hunter \
    --flatten="bindings[].members" \
    --filter="bindings.members:*compute@developer.gserviceaccount.com"

# Check secret access
gcloud secrets get-iam-policy SECRET_KEY_BASE --project=reed-bootie-hunter
```

## Troubleshooting

### Permission Denied Errors

If you see permission denied errors:

1. Verify your account has the required roles
2. Check service account has access to secrets
3. Ensure Cloud Build service account can deploy to Cloud Run
4. Verify Firestore API is enabled

### Common Issues

- **Secret access denied**: Run `scripts/grant-secret-access.sh`
- **Storage access denied**: Grant `objectAdmin` role to service account
- **Deployment fails**: Check Cloud Build service account has `run.admin` role

