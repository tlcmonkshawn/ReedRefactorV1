# GCP Deployment Setup Guide

This guide covers deploying the ReedRefactorV1 application to Google Cloud Platform.

## Overview

The application consists of:
- **Backend**: Rails API on Cloud Run (Firestore database)
- **Frontend**: Flutter web app on Cloud Run
- **Storage**: Google Cloud Storage (images)
- **Database**: Firestore (Native mode)

## Prerequisites

1. Google Cloud SDK (`gcloud`) installed and authenticated
2. Docker installed (for local testing)
3. Project: `reed-bootie-hunter`
4. Region: `us-west1` (Oregon)

## Phase 1: Infrastructure Setup

### 1.1 Enable Required APIs

```bash
gcloud services enable \
  firestore.googleapis.com \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  --project=reed-bootie-hunter
```

### 1.2 Create Firestore Database

```bash
gcloud firestore databases create \
  --location=us-west1 \
  --type=firestore-native \
  --project=reed-bootie-hunter
```

### 1.3 Set Up Secret Manager

Create secrets for sensitive configuration:

```bash
# Generate a secure secret key base
SECRET_KEY_BASE=$(openssl rand -hex 64)

# Create secrets
echo -n "$SECRET_KEY_BASE" | gcloud secrets create SECRET_KEY_BASE \
  --data-file=- \
  --project=reed-bootie-hunter

echo -n "$SECRET_KEY_BASE" | gcloud secrets create JWT_SECRET_KEY \
  --data-file=- \
  --project=reed-bootie-hunter

# Set other secrets (replace with actual values)
echo -n "your-gemini-api-key" | gcloud secrets create GEMINI_API_KEY \
  --data-file=- \
  --project=reed-bootie-hunter

echo -n "iamagoodgirl" | gcloud secrets create ADMIN_PASSWORD \
  --data-file=- \
  --project=reed-bootie-hunter

# Service account JSON (get from GCS setup)
cat service-account-key.json | gcloud secrets create GOOGLE_APPLICATION_CREDENTIALS_JSON \
  --data-file=- \
  --project=reed-bootie-hunter
```

### 1.4 Grant Cloud Run Access to Secrets

```bash
PROJECT_NUMBER=$(gcloud projects describe reed-bootie-hunter --format="value(projectNumber)")

gcloud secrets add-iam-policy-binding SECRET_KEY_BASE \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor" \
  --project=reed-bootie-hunter

# Repeat for other secrets
```

## Phase 2: Backend Deployment

### 2.1 Build and Deploy Backend

```bash
cd ReedRefactorV1

# Submit build to Cloud Build
gcloud builds submit \
  --config=cloudbuild.yaml \
  --project=reed-bootie-hunter
```

### 2.2 Verify Backend Deployment

```bash
# Get the service URL
BACKEND_URL=$(gcloud run services describe reed-refactor-v1-backend \
  --region=us-west1 \
  --format="value(status.url)" \
  --project=reed-bootie-hunter)

# Test health endpoint
curl $BACKEND_URL/health
```

## Phase 3: Frontend Deployment

### 3.1 Update Frontend API URL

Update `frontend/cloudbuild.yaml` with the actual backend URL after backend deployment.

### 3.2 Build and Deploy Frontend

```bash
cd frontend

# Submit build to Cloud Build
gcloud builds submit \
  --config=cloudbuild.yaml \
  --project=reed-bootie-hunter
```

## Phase 4: Initial Setup

### 4.1 Seed Firestore Data

```bash
# Run seed task via Cloud Run
gcloud run jobs create firestore-seed \
  --image=gcr.io/reed-bootie-hunter/reed-refactor-v1-backend:latest \
  --region=us-west1 \
  --command="bundle,exec,rake,firestore:seed" \
  --project=reed-bootie-hunter
```

Or manually via Rails console:

```bash
# Connect to Cloud Run service
gcloud run services proxy reed-refactor-v1-backend \
  --region=us-west1 \
  --port=8080

# In another terminal, run seed
curl -X POST http://localhost:8080/migrations/run \
  -H "X-Migration-Password: iamagoodgirl"
```

## Phase 5: CI/CD Setup

### 5.1 Create Cloud Build Triggers

```bash
# Backend trigger
gcloud builds triggers create github \
  --name="deploy-backend" \
  --repo-name="ReedRefactorV1" \
  --repo-owner="tlcmonkshawn" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --project=reed-bootie-hunter

# Frontend trigger
gcloud builds triggers create github \
  --name="deploy-frontend" \
  --repo-name="ReedRefactorV1" \
  --repo-owner="tlcmonkshawn" \
  --branch-pattern="^main$" \
  --build-config="frontend/cloudbuild.yaml" \
  --project=reed-bootie-hunter
```

## Environment Variables

### Backend (Cloud Run)

- `RAILS_ENV=production`
- `GOOGLE_CLOUD_PROJECT_ID=reed-bootie-hunter`
- `GOOGLE_CLOUD_STORAGE_BUCKET=reed-refactor-v1-images`
- Secrets (from Secret Manager):
  - `SECRET_KEY_BASE`
  - `JWT_SECRET_KEY`
  - `GEMINI_API_KEY`
  - `ADMIN_PASSWORD`
  - `GOOGLE_APPLICATION_CREDENTIALS_JSON`

### Frontend (Cloud Run)

- `API_URL` (set automatically in cloudbuild.yaml)

## Troubleshooting

### Check Logs

```bash
# Backend logs
gcloud run services logs read reed-refactor-v1-backend \
  --region=us-west1 \
  --project=reed-bootie-hunter

# Frontend logs
gcloud run services logs read reed-refactor-v1-frontend \
  --region=us-west1 \
  --project=reed-bootie-hunter
```

### Verify Firestore

```bash
# List collections
gcloud firestore collections list \
  --project=reed-bootie-hunter
```

## Next Steps

1. Set up custom domains (optional)
2. Configure monitoring and alerts
3. Set up backup strategy for Firestore
4. Configure auto-scaling policies

