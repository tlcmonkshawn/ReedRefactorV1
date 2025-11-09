# Remaining Tasks Plan

This document outlines the plan for completing the remaining operational tasks for GCP deployment.

## Completed ✅

1. ✅ **Secret Manager Setup Scripts** - Created `scripts/setup-secrets.sh` and `scripts/grant-secret-access.sh`
2. ✅ **Deployment Scripts** - Created `scripts/deploy-backend.sh` and `scripts/deploy-frontend.sh`
3. ✅ **IAM Permissions Documentation** - Created `docs/deployment/iam-permissions.md` and `scripts/setup-iam.sh`
4. ✅ **Cloud Build Triggers** - Created `cloudbuild-triggers.yaml` and `scripts/create-triggers.sh`

## Tasks to Execute

### Task 1: Create Firestore Database
**Status:** In Progress

```bash
gcloud firestore databases create \
  --location=us-west1 \
  --type=firestore-native \
  --project=reed-bootie-hunter
```

**Note:** This may take a few minutes. The API was already enabled earlier.

### Task 2: Set Up Secrets in Secret Manager
**Script:** `scripts/setup-secrets.sh`

**Required Secrets:**
- `SECRET_KEY_BASE` - Will be auto-generated
- `JWT_SECRET_KEY` - Uses SECRET_KEY_BASE
- `GEMINI_API_KEY` - Needs to be provided
- `ADMIN_PASSWORD` - Default: "iamagoodgirl"
- `GOOGLE_APPLICATION_CREDENTIALS_JSON` - Needs service account JSON

**Execution:**
```bash
# Set GEMINI_API_KEY if you have it
export GEMINI_API_KEY="your-key-here"

# Run setup script
bash scripts/setup-secrets.sh
```

**Manual Steps if Needed:**
- If GEMINI_API_KEY not set, create manually:
  ```bash
  echo -n "your-key" | gcloud secrets create GEMINI_API_KEY --data-file=- --project=reed-bootie-hunter
  ```
- If service account JSON exists, it will be used automatically
- Otherwise, create service account and download key:
  ```bash
  gcloud iam service-accounts create reed-refactor-v1-sa \
    --display-name="Reed Refactor V1 Service Account" \
    --project=reed-bootie-hunter
  
  gcloud iam service-accounts keys create service-account-key.json \
    --iam-account=reed-refactor-v1-sa@reed-bootie-hunter.iam.gserviceaccount.com \
    --project=reed-bootie-hunter
  ```

### Task 3: Grant Secret Access
**Script:** `scripts/grant-secret-access.sh`

**Execution:**
```bash
bash scripts/grant-secret-access.sh
```

This grants the Cloud Run service account access to all secrets.

### Task 4: Set Up IAM Permissions
**Script:** `scripts/setup-iam.sh`

**Execution:**
```bash
bash scripts/setup-iam.sh
```

This grants:
- Cloud Build service account permissions to deploy
- Cloud Run service account permissions for storage and Firestore
- Secret access (calls grant-secret-access.sh)

### Task 5: Create Cloud Build Triggers
**Script:** `scripts/create-triggers.sh`

**Prerequisites:**
- GitHub repository connected to Cloud Build
- Repository must be accessible

**Execution:**
```bash
bash scripts/create-triggers.sh
```

**Manual Alternative:**
1. Go to Cloud Console → Cloud Build → Triggers
2. Create trigger for backend (uses `cloudbuild.yaml`)
3. Create trigger for frontend (uses `frontend/cloudbuild.yaml`)

### Task 6: Initial Deployment

**Backend:**
```bash
bash scripts/deploy-backend.sh
```

**Frontend (after backend is deployed):**
```bash
bash scripts/deploy-frontend.sh
```

### Task 7: Seed Firestore Data

After backend is deployed, seed initial data:

```bash
# Via migration endpoint
curl -X POST https://YOUR-BACKEND-URL/migrations/run \
  -H "X-Migration-Password: iamagoodgirl"

# Or via Cloud Run job
gcloud run jobs create firestore-seed \
  --image=gcr.io/reed-bootie-hunter/reed-refactor-v1-backend:latest \
  --region=us-west1 \
  --command="bundle,exec,rake,firestore:seed" \
  --project=reed-bootie-hunter

gcloud run jobs execute firestore-seed \
  --region=us-west1 \
  --project=reed-bootie-hunter
```

## Execution Order

1. ✅ Create Firestore database
2. Set up secrets (`scripts/setup-secrets.sh`)
3. Grant secret access (`scripts/grant-secret-access.sh`)
4. Set up IAM permissions (`scripts/setup-iam.sh`)
5. Deploy backend (`scripts/deploy-backend.sh`)
6. Seed Firestore data
7. Deploy frontend (`scripts/deploy-frontend.sh`)
8. Create Cloud Build triggers (`scripts/create-triggers.sh`)

## Verification

After deployment, verify:

```bash
# Check backend health
curl https://YOUR-BACKEND-URL/health

# Check frontend
curl https://YOUR-FRONTEND-URL

# List secrets
gcloud secrets list --project=reed-bootie-hunter

# Check Cloud Run services
gcloud run services list --region=us-west1 --project=reed-bootie-hunter

# Check Firestore
gcloud firestore collections list --project=reed-bootie-hunter
```

## Troubleshooting

See `docs/deployment/gcp-setup.md` and `GCP_MIGRATION_CHECKLIST.md` for detailed troubleshooting steps.

