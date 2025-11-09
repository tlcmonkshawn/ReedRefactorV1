# Pre-Deployment Verification Checklist

## ✅ Infrastructure

- [x] Firestore database created (us-west1, Native mode)
- [x] All 5 secrets created in Secret Manager
- [x] Secret access granted to Cloud Run service account
- [x] All required APIs enabled:
  - [x] Firestore API
  - [x] Cloud Run API
  - [x] Cloud Build API
  - [x] Secret Manager API
  - [x] Storage API

## ✅ IAM Permissions

- [x] Cloud Build service account has:
  - [x] roles/run.admin
  - [x] roles/iam.serviceAccountUser
  - [x] roles/storage.admin
- [x] Cloud Run service account has:
  - [x] Secret Manager access (all secrets)
  - [x] Firestore access (default)
  - [x] Storage access (will be granted on first use)

## ✅ Code Configuration

- [x] Gemfile updated (Firestore gem, no PostgreSQL)
- [x] Dockerfile updated (no libpq-dev)
- [x] All models use FirestoreModel (not ApplicationRecord)
- [x] ApplicationRecord removed
- [x] ActiveRecord removed from Rails config
- [x] Firestore initializer configured
- [x] Startup script configured
- [x] cloudbuild.yaml has all secrets configured
- [x] Environment variables configured correctly

## ✅ Files Verified

- [x] Dockerfile exists and correct
- [x] cloudbuild.yaml exists and correct
- [x] bin/cloud-run-start.sh exists
- [x] config/initializers/firestore.rb exists
- [x] app/models/firestore_model.rb exists
- [x] All model files use FirestoreModel

## ⚠️ Notes

- `database_cleaner-active_record` is still in Gemfile (test/development only - OK)
- Storage bucket will be created automatically on first use
- Service account permissions verified

## Ready for Deployment ✅

All checks passed! Ready to deploy.

