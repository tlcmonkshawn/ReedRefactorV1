# Storage Quick Start Guide

**For:** Setting up storage on new Render project

---

## Quick Checklist

1. ✅ **Storage code refactored** - Done!
2. ⏳ **Create GCS bucket** - You need to do this
3. ⏳ **Create service account** - You need to do this
4. ⏳ **Create Render project** - You need to do this
5. ⏳ **Configure environment variables** - You need to do this
6. ⏳ **Test storage** - You need to do this

---

## Step-by-Step (30 minutes)

### Step 1: Create GCS Bucket (5 min)

1. Go to: https://console.cloud.google.com/storage
2. Click "Create Bucket"
3. Name: `reed-refactor-v1-images`
4. Region: `us-west1` (Oregon)
5. Click "Create"
6. Go to Permissions → Grant `allUsers` → `Storage Object Viewer` (for public images)

### Step 2: Create Service Account (10 min)

1. Go to: https://console.cloud.google.com/iam-admin/serviceaccounts
2. Click "Create Service Account"
3. Name: `reed-refactor-v1-storage`
4. Grant role: `Storage Object Admin`
5. Create JSON key → **Save the file!**

### Step 3: Create Render Project (5 min)

1. Go to: https://dashboard.render.com
2. Click "New" → "Blueprint"
3. Connect your GitHub repo (ReedRefactorV1)
4. Render will detect `render.yaml`
5. Click "Apply" to create services

### Step 4: Configure Environment Variables (10 min)

In Render Dashboard → `reed-refactor-v1-backend` → Environment:

**GOOGLE_CLOUD_PROJECT_ID**
```
your-project-id-here
```

**GOOGLE_CLOUD_STORAGE_BUCKET**
```
reed-refactor-v1-images
```

**GOOGLE_APPLICATION_CREDENTIALS_JSON**
```
{"type":"service_account","project_id":"...","private_key":"...","client_email":"..."}
```
*Paste the ENTIRE JSON file contents here (as a single line)*

**Also set:**
- `SECRET_KEY_BASE` (generate with: `rails secret`)
- `JWT_SECRET_KEY` (generate with: `rails secret`)
- `GEMINI_API_KEY` (your Gemini API key)
- `ADMIN_PASSWORD` (your admin password)

### Step 5: Link Database

1. In Render Dashboard → `reed-refactor-v1-backend` → Settings
2. Click "Link Database"
3. Select `reed-refactor-v1-db`
4. `DATABASE_URL` will be auto-injected

### Step 6: Deploy & Test

1. Render will auto-deploy
2. Check logs for: `✅ Storage configuration validated successfully`
3. Test upload:
   ```bash
   curl -X POST https://your-service.onrender.com/api/v1/images/upload \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -F "image=@test.jpg"
   ```

---

## Troubleshooting

**Storage validation fails?**
- Check all 3 environment variables are set
- Verify JSON is valid (use JSON validator)
- Check service account has `Storage Object Admin` role

**Bucket not found?**
- Verify bucket name matches exactly
- Check bucket exists in correct project
- Verify service account has access

**Images not public?**
- Check bucket permissions
- Verify `allUsers` has `Storage Object Viewer` role

---

## Full Documentation

See `docs/storage/SETUP.md` for detailed instructions.

---

**Ready to go!** Follow the steps above and you'll have storage working in ~30 minutes.

