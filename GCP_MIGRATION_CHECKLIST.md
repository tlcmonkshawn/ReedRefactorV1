# GCP Migration Checklist

This checklist covers the complete migration from Render.com to Google Cloud Platform.

## Pre-Migration

- [ ] Review current Render.com deployment and note all environment variables
- [ ] Backup any critical data (if needed - we're starting fresh)
- [ ] Verify GCP project `reed-bootie-hunter` exists and is accessible
- [ ] Ensure gcloud CLI is installed and authenticated

## Phase 1: Infrastructure Setup

- [ ] Enable required GCP APIs (Firestore, Cloud Run, Cloud Build, Secret Manager, Storage)
- [ ] Create Firestore database in `us-west1` region
- [ ] Create GCS bucket `reed-refactor-v1-images` (if not already exists)
- [ ] Create service account for GCS access
- [ ] Create all secrets in Secret Manager:
  - [ ] `SECRET_KEY_BASE`
  - [ ] `JWT_SECRET_KEY`
  - [ ] `GEMINI_API_KEY`
  - [ ] `ADMIN_PASSWORD`
  - [ ] `GOOGLE_APPLICATION_CREDENTIALS_JSON`
- [ ] Grant Cloud Run service account access to secrets

## Phase 2: Backend Deployment

- [ ] Verify Dockerfile builds successfully locally
- [ ] Test `bin/cloud-run-start.sh` script
- [ ] Submit backend build to Cloud Build
- [ ] Verify backend deployment on Cloud Run
- [ ] Test health endpoint: `GET /health`
- [ ] Verify Firestore connection
- [ ] Run Firestore seed task
- [ ] Test API endpoints (register, login)

## Phase 3: Frontend Deployment

- [ ] Update `frontend/cloudbuild.yaml` with actual backend URL
- [ ] Verify Flutter web build works locally
- [ ] Submit frontend build to Cloud Build
- [ ] Verify frontend deployment on Cloud Run
- [ ] Test frontend can connect to backend
- [ ] Verify CORS configuration

## Phase 4: Initial Setup

- [ ] Seed Firestore with initial data (prompts, locations, admin user)
- [ ] Create default admin user
- [ ] Verify all collections are created
- [ ] Test user registration and login
- [ ] Test image upload to GCS
- [ ] Test Bootie creation workflow

## Phase 5: CI/CD Setup

- [ ] Connect GitHub repository to Cloud Build
- [ ] Create Cloud Build trigger for backend
- [ ] Create Cloud Build trigger for frontend
- [ ] Test automatic deployment on push to main
- [ ] Verify build notifications

## Phase 6: Verification

- [ ] All API endpoints responding correctly
- [ ] Frontend can communicate with backend
- [ ] File uploads to GCS working
- [ ] Health checks passing
- [ ] Firestore queries working
- [ ] Authentication working (JWT)
- [ ] Admin interface accessible
- [ ] Error handling working

## Phase 7: Cleanup

- [ ] Update documentation (README, deployment guides)
- [ ] Remove Render.com resources (after verification)
- [ ] Cancel Render.com subscription (if applicable)
- [ ] Update any external references to old URLs
- [ ] Set up monitoring and alerts on GCP

## Rollback Plan

If issues occur:

1. Keep Render.com deployment running until GCP is fully verified
2. Update DNS/URLs to point back to Render.com if needed
3. Review Cloud Run logs for errors
4. Check Secret Manager for missing/invalid secrets
5. Verify Firestore database is accessible
6. Check IAM permissions for service accounts

## Post-Migration

- [ ] Monitor Cloud Run metrics for first 24-48 hours
- [ ] Set up Cloud Monitoring alerts
- [ ] Configure Cloud Logging retention
- [ ] Document any issues encountered
- [ ] Update team on new deployment process

