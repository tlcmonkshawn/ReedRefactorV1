# Render Setup Complete ✅

**Date:** 2025-01-27  
**Status:** Services Created - Additional Configuration Needed  
**Note:** Services have been moved to a dedicated Render project for better organization and visibility

---

## ✅ What's Been Done

### 1. Google Cloud Storage
- ✅ **Bucket Created:** `gs://reed-refactor-v1-images`
- ✅ **Location:** `us-west1` (Oregon)
- ✅ **Public Access:** Configured for public image viewing
- ✅ **Service Account:** `reed-refactor-v1-storage@reed-bootie-hunter.iam.gserviceaccount.com`
- ✅ **Permissions:** Storage Object Admin role granted
- ✅ **Key File:** `service-account-key.json` (saved locally)

### 2. Render Services
- ✅ **Web Service:** `reed-refactor-v1-backend`
  - **URL:** https://reed-refactor-v1-backend.onrender.com
  - **Dashboard:** https://dashboard.render.com/web/srv-d48g7qchg0os73894stg
  - **Status:** Created, deployed in dedicated project
  - **Project:** Services organized in dedicated Render project for better visibility
  
- ✅ **Database:** `reed-refactor-v1-db`
  - **ID:** `dpg-d48g7n4hg0os73894qrg-a`
  - **Dashboard:** https://dashboard.render.com/d/dpg-d48g7n4hg0os73894qrg-a
  - **Plan:** basic_256mb
  - **Region:** Oregon
  - **Status:** Available, in same project as web service

### 3. Environment Variables Set
- ✅ `RAILS_ENV` = `production`
- ✅ `SECRET_KEY_BASE` = (generated, set)
- ✅ `JWT_SECRET_KEY` = (generated, set)
- ✅ `GOOGLE_CLOUD_PROJECT_ID` = `reed-bootie-hunter`
- ✅ `GOOGLE_CLOUD_STORAGE_BUCKET` = `reed-refactor-v1-images`
- ✅ `GOOGLE_APPLICATION_CREDENTIALS_JSON` = (full JSON, set)

---

## ⚠️ Still Need To Do

### 1. Set Additional Environment Variables

**GEMINI_API_KEY**
- Go to: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg/environment
- Add: `GEMINI_API_KEY` = (your Gemini API key)

**ADMIN_PASSWORD**
- Go to: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg/environment
- Add: `ADMIN_PASSWORD` = (choose a secure password)

### 2. Link Database to Web Service

1. Go to: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg/settings
2. Scroll to "Linked Databases"
3. Click "Link Database"
4. Select: `reed-refactor-v1-db`
5. `DATABASE_URL` will be auto-injected with SSL

### 3. Update Service Configuration (if needed)

The service was created but may need:
- **healthCheckPath:** Should be `/health` (check in Render Dashboard)

To update:
1. Go to: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg/settings
2. Update "Health Check Path" to: `/health`
3. Save changes

**Note:** Root Directory is no longer needed since Rails app is in project root.

### 4. Run Database Migrations

Once database is linked and service is running:

**Option 1: Via Render Dashboard**
1. Go to: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg
2. Click "Shell" tab
3. Run: `cd backend && bundle exec rails db:migrate`

**Option 2: Via Migrations Endpoint**
```bash
curl -X POST "https://reed-refactor-v1-backend.onrender.com/migrations/run?password=YOUR_ADMIN_PASSWORD" \
  -H "X-Migration-Password: YOUR_ADMIN_PASSWORD"
```

---

## 🔍 Verification Steps

### 1. Check Service Status
- Visit: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg
- Verify deployment is successful
- Check logs for any errors

### 2. Test Health Endpoint
```bash
curl https://reed-refactor-v1-backend.onrender.com/health
```

Expected response:
```json
{
  "status": "ok",
  "database": "connected",
  ...
}
```

### 3. Test Storage Configuration
Check logs for:
```
✅ Storage configuration validated successfully
   Project: reed-bootie-hunter
   Bucket: reed-refactor-v1-images
```

If you see errors, check:
- Environment variables are set correctly
- Service account JSON is valid
- Bucket exists and is accessible

### 4. Test Database Connection
Once database is linked:
```bash
curl https://reed-refactor-v1-backend.onrender.com/health
```

Should show: `"database": "connected"`

---

## 📋 Service Details

### Web Service
- **Name:** reed-refactor-v1-backend
- **ID:** srv-d48g7qchg0os73894stg
- **URL:** https://reed-refactor-v1-backend.onrender.com
- **Region:** Oregon
- **Plan:** Starter
- **Repo:** https://github.com/tlcmonkshawn/ReedRefactorV1
- **Branch:** main
- **Root Directory:** (not needed - Rails app is in root)

### Database
- **Name:** reed-refactor-v1-db
- **ID:** dpg-d48g7n4hg0os73894qrg-a
- **Plan:** basic_256mb
- **Region:** Oregon
- **Version:** PostgreSQL 16
- **Status:** Created

### Storage
- **Bucket:** gs://reed-refactor-v1-images
- **Project:** reed-bootie-hunter
- **Service Account:** reed-refactor-v1-storage@reed-bootie-hunter.iam.gserviceaccount.com
- **Public Access:** Enabled (allUsers can view objects)

---

## 🔐 Security Notes

1. **Service Account Key:** The key file `service-account-key.json` is saved locally. Keep it secure.
2. **Secrets:** All secrets are stored in Render environment variables (not in git).
3. **Database:** Will be auto-linked and `DATABASE_URL` will include SSL.
4. **Bucket:** Public read access is enabled for images. Consider using signed URLs for production.

---

## 📝 Next Steps

1. ✅ Set `GEMINI_API_KEY` in Render Dashboard
2. ✅ Set `ADMIN_PASSWORD` in Render Dashboard
3. ✅ Link database to web service
4. ✅ Verify `rootDir` is set to `backend`
5. ✅ Verify `healthCheckPath` is set to `/health`
6. ✅ Wait for deployment to complete
7. ✅ Run database migrations
8. ✅ Test health endpoint
9. ✅ Test storage upload

---

## 🆘 Troubleshooting

### Service Won't Start
- Check logs in Render Dashboard
- Verify all environment variables are set
- Check that `rootDir` is correct

### Database Connection Fails
- Verify database is linked
- Check `DATABASE_URL` includes `?sslmode=require`
- Verify database is running (check status in dashboard)

### Storage Validation Fails
- Check `GOOGLE_APPLICATION_CREDENTIALS_JSON` is valid JSON
- Verify bucket name is correct
- Check service account has permissions

---

**Last Updated:** 2025-01-27

