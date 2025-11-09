# Storage Reimplementation Plan

**Date:** 2025-01-27  
**Goal:** Reimplement storage system for fresh start on new Render.com project

---

## Current State

- **Current Storage:** Google Cloud Storage (GCS)
- **Issues:**
  - Complex credential handling (3 different methods)
  - No validation of credentials on startup
  - Hard to test/debug
  - Tightly coupled to GCS

---

## Proposed Approach

### Option 1: Simplified GCS (Recommended for Now)
**Pros:**
- Keep existing GCS implementation
- Simplify credential handling
- Add validation and better error messages
- Works well with Render

**Cons:**
- Still requires GCS setup
- Need new bucket for new project

### Option 2: Storage Abstraction Layer
**Pros:**
- Easy to switch providers later
- Better testability
- Cleaner code

**Cons:**
- More initial work
- Might be overkill for now

### Option 3: Start with Render Disk, Add Cloud Later
**Pros:**
- Simplest to start
- No external dependencies

**Cons:**
- Not ideal for public URLs
- Limited scalability
- Would need to migrate later

---

## Recommended Plan: Simplified GCS with Better Configuration

### Phase 1: Clean Up Storage Service (Today)

1. **Simplify ImageUploadService**
   - Single credential method (environment variable only)
   - Better error messages
   - Startup validation
   - Clear configuration requirements

2. **Update ImageProcessingService**
   - Use same simplified approach
   - Remove duplicate code

3. **Add Storage Configuration Validator**
   - Check credentials on startup
   - Test bucket access
   - Clear error messages if misconfigured

### Phase 2: New Render Project Setup

1. **Create New Render Web Service**
   - Name: `reed-refactor-v1-backend`
   - Region: Oregon
   - Plan: Starter (or your paid plan)

2. **Create New PostgreSQL Database**
   - Name: `reed-refactor-v1-db`
   - Link to web service

3. **Set Up New GCS Bucket**
   - Bucket name: `reed-refactor-v1-images` (or your choice)
   - Make it publicly readable for images
   - Get service account credentials

4. **Configure Environment Variables**
   - `GOOGLE_CLOUD_PROJECT_ID`
   - `GOOGLE_CLOUD_STORAGE_BUCKET`
   - `GOOGLE_APPLICATION_CREDENTIALS_JSON` (full JSON as string)

### Phase 3: Testing & Validation

1. **Test Storage Locally**
   - Verify credentials work
   - Test upload functionality
   - Verify public URLs work

2. **Deploy to Render**
   - Test storage on Render
   - Verify environment variables
   - Test end-to-end upload flow

---

## Implementation Steps

### Step 1: Refactor ImageUploadService

**Changes:**
- Remove file-based credential support (development only)
- Use only `GOOGLE_APPLICATION_CREDENTIALS_JSON` environment variable
- Add startup validation
- Better error messages

### Step 2: Create Storage Configuration Validator

**New File:** `backend/config/initializers/storage_validation.rb`

**Purpose:**
- Validate GCS credentials on startup
- Test bucket access
- Log clear error messages

### Step 3: Update render.yaml

**Changes:**
- Update service name
- Update database name
- Add storage validation notes

### Step 4: Create Setup Documentation

**New File:** `docs/storage/SETUP.md`

**Contents:**
- How to create GCS bucket
- How to get service account credentials
- How to configure environment variables
- Testing instructions

---

## Alternative: If You Want to Start Even Simpler

If you want to get running faster and add cloud storage later:

1. **Start with Local Storage (Development)**
   - Store images in `storage/` directory
   - Serve via Rails static files
   - Works for development/testing

2. **Add GCS Later**
   - When ready for production
   - Easy migration path

**This would let you:**
- Get the app running immediately
- Test everything except image uploads
- Add cloud storage when ready

---

## Recommendation

**Go with Simplified GCS** because:
1. You already have GCS experience
2. It's production-ready
3. We can simplify the implementation
4. Better for public image URLs
5. Scales well

**Timeline:**
- Today: Refactor storage service (1-2 hours)
- Today: Set up new Render project (30 min)
- Today: Configure GCS bucket (30 min)
- Today: Test and validate (30 min)

**Total: ~3-4 hours to get storage working on new project**

---

## Questions for You

1. **Do you already have a GCS project set up?** (We can use existing or create new)
2. **Do you want to start with local storage first, or go straight to GCS?**
3. **What should we name the new Render services?** (e.g., `reed-refactor-v1-backend`)
4. **Do you have the GCS service account credentials ready, or need to create them?**

---

## Next Steps

Once you confirm the approach, I'll:
1. Refactor the storage services
2. Create the configuration validator
3. Update documentation
4. Help you set up the new Render project
5. Guide you through GCS bucket setup

**Ready to proceed?** Let me know your preferences and I'll start implementing!

