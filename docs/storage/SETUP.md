# Google Cloud Storage Setup Guide

**Last Updated:** 2025-01-27

This guide walks you through setting up Google Cloud Storage for the ReedRefactorV1 project.

---

## Prerequisites

- Google Cloud Platform account
- Access to create projects and service accounts
- Render.com account (for deployment)

---

## Step 1: Create GCS Bucket

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/storage
   - Select your project (or create a new one)

2. **Create a New Bucket**
   - Click "Create Bucket"
   - **Bucket name:** `reed-refactor-v1-images` (or your preferred name)
   - **Location type:** Region
   - **Region:** `us-west1` (Oregon) - matches Render region
   - **Storage class:** Standard
   - **Access control:** Uniform
   - Click "Create"

3. **Configure Bucket Permissions**
   - Go to bucket → Permissions tab
   - Click "Grant Access"
   - Add `allUsers` with role `Storage Object Viewer` (for public image access)
   - Or use fine-grained access control (recommended for production)

---

## Step 2: Create Service Account

1. **Go to Service Accounts**
   - Visit: https://console.cloud.google.com/iam-admin/serviceaccounts
   - Select your project

2. **Create Service Account**
   - Click "Create Service Account"
   - **Name:** `reed-refactor-v1-storage`
   - **Description:** `Service account for ReedRefactorV1 image storage`
   - Click "Create and Continue"

3. **Grant Permissions**
   - **Role:** `Storage Object Admin` (allows upload, delete, manage)
   - Click "Continue" → "Done"

4. **Create Key**
   - Click on the service account you just created
   - Go to "Keys" tab
   - Click "Add Key" → "Create new key"
   - **Key type:** JSON
   - Click "Create"
   - **Save the JSON file** - you'll need it for the next step

---

## Step 3: Configure Render Environment Variables

1. **Go to Render Dashboard**
   - Navigate to your web service: `reed-refactor-v1-backend`
   - Go to "Environment" tab

2. **Add Environment Variables**

   **GOOGLE_CLOUD_PROJECT_ID**
   ```
   your-gcp-project-id
   ```
   *Find this in Google Cloud Console → Project Settings*

   **GOOGLE_CLOUD_STORAGE_BUCKET**
   ```
   reed-refactor-v1-images
   ```
   *The bucket name you created in Step 1*

   **GOOGLE_APPLICATION_CREDENTIALS_JSON**
   ```
   {"type":"service_account","project_id":"your-project-id",...}
   ```
   *Paste the ENTIRE contents of the JSON key file from Step 2*
   *Important: Paste as a single line, or use Render's multi-line support*

3. **Save Changes**
   - Click "Save Changes"
   - Service will automatically redeploy

---

## Step 4: Verify Configuration

1. **Check Render Logs**
   - Go to Render Dashboard → Your Service → Logs
   - Look for: `✅ Storage configuration validated successfully`
   - If you see errors, check the error messages and fix configuration

2. **Test Upload (via API)**
   ```bash
   # Get your auth token first
   curl -X POST https://your-service.onrender.com/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"your@email.com","password":"yourpassword"}'
   
   # Use the token to upload an image
   curl -X POST https://your-service.onrender.com/api/v1/images/upload \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -F "image=@/path/to/image.jpg"
   ```

3. **Verify Image is Publicly Accessible**
   - The response will include an `image_url`
   - Open that URL in a browser
   - Image should be visible

---

## Local Development Setup

For local development, you can use the same environment variables:

1. **Create `.env` file** (or use your existing setup)
   ```bash
   GOOGLE_CLOUD_PROJECT_ID=your-project-id
   GOOGLE_CLOUD_STORAGE_BUCKET=reed-refactor-v1-images
   GOOGLE_APPLICATION_CREDENTIALS_JSON='{"type":"service_account",...}'
   ```

2. **Or use service account file** (alternative)
   - Place the JSON key file at: `backend/config/service-account-key.json`
   - Update `.env` to point to it (not recommended for production)

3. **Test Locally**
   ```bash
   cd backend
   rails console
   
   # Test storage initialization
   require 'google/cloud/storage'
   storage = Google::Cloud::Storage.new(
     project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
     credentials: JSON.parse(ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'])
   )
   bucket = storage.bucket(ENV['GOOGLE_CLOUD_STORAGE_BUCKET'])
   puts "Bucket accessible: #{bucket.present?}"
   ```

---

## Troubleshooting

### Error: "Missing required environment variables"

**Problem:** One or more environment variables are not set.

**Solution:**
- Check Render Dashboard → Environment tab
- Verify all three variables are set:
  - `GOOGLE_CLOUD_PROJECT_ID`
  - `GOOGLE_CLOUD_STORAGE_BUCKET`
  - `GOOGLE_APPLICATION_CREDENTIALS_JSON`

### Error: "Invalid JSON in GOOGLE_APPLICATION_CREDENTIALS_JSON"

**Problem:** The JSON is malformed or incomplete.

**Solution:**
- Copy the ENTIRE contents of the service account JSON file
- Make sure it's valid JSON (use a JSON validator)
- In Render, you may need to escape quotes or use multi-line format

### Error: "Bucket not found or not accessible"

**Problem:** Service account doesn't have access to the bucket.

**Solution:**
- Verify bucket name is correct
- Check service account has `Storage Object Admin` role
- Verify bucket exists in the correct project

### Error: "Google Cloud Storage error: Permission denied"

**Problem:** Service account lacks necessary permissions.

**Solution:**
- Grant `Storage Object Admin` role to service account
- Or grant more specific permissions:
  - `storage.objects.create`
  - `storage.objects.get`
  - `storage.objects.delete`
  - `storage.buckets.get`

### Images Not Publicly Accessible

**Problem:** Images upload but can't be viewed publicly.

**Solution:**
- Check bucket permissions (Step 1.3)
- Verify `allUsers` has `Storage Object Viewer` role
- Or use signed URLs for private images

---

## Security Best Practices

1. **Use Fine-Grained Access Control**
   - Instead of making bucket public, use IAM conditions
   - Grant public read access only to specific paths

2. **Rotate Service Account Keys**
   - Regularly rotate service account keys
   - Update `GOOGLE_APPLICATION_CREDENTIALS_JSON` in Render

3. **Limit Service Account Permissions**
   - Only grant necessary permissions
   - Use principle of least privilege

4. **Monitor Usage**
   - Set up billing alerts
   - Monitor storage usage in GCP Console

---

## Cost Considerations

- **Storage:** ~$0.020 per GB/month (Standard storage)
- **Operations:** 
  - Class A (uploads): $0.05 per 10,000 operations
  - Class B (downloads): $0.004 per 10,000 operations
- **Network egress:** Free within same region

**Estimated costs for typical usage:**
- 1000 images/month (~5MB each) = ~$0.10/month storage
- 1000 uploads/month = ~$0.005/month operations
- **Total: ~$0.11/month** for light usage

---

## Related Documentation

- [Storage Reimplementation Plan](../../STORAGE_REIMPLEMENTATION_PLAN.md)
- [CODE_REVIEW.md](../../CODE_REVIEW.md) - Storage configuration issues
- [Google Cloud Storage Documentation](https://cloud.google.com/storage/docs)

---

**Last Updated:** 2025-01-27

