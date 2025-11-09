# Render Deployment Troubleshooting Guide

## 🔍 How to Check Render Logs

### Method 1: Render Dashboard (Easiest)
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your web service
3. Click on **"Logs"** tab
4. You'll see:
   - **Build Logs** - Issues during `bundle install` and build
   - **Runtime Logs** - Issues after deployment (server errors, crashes)

### Method 2: Render CLI (Advanced)
```bash
# Install Render CLI
npm install -g render-cli

# Login
render login

# View logs
render logs --service your-service-name
```

---

## 🚨 Common Render Deployment Issues

### Issue 1: Build Failures

**Symptoms:**
- Build fails during `bundle install`
- Error messages about missing gems or dependencies

**Common Causes & Fixes:**

1. **Ruby version mismatch**
   - **Fix:** Add `.ruby-version` file to `backend/` directory
   ```bash
   # backend/.ruby-version
   3.4.7
   ```

2. **Missing system dependencies**
   - **Fix:** Add `aptfile` or use buildpacks
   - Image processing gems (ImageMagick) may need system libraries

3. **Bundler version issues**
   - **Fix:** Add `BUNDLER_VERSION` environment variable in Render
   ```
   BUNDLER_VERSION=2.5.0
   ```

### Issue 2: Database Connection Errors

**Symptoms:**
- "Database connection refused"
- "FATAL: database does not exist"
- "password authentication failed"

**Common Causes & Fixes:**

1. **DATABASE_URL not set**
   - **Fix:** Ensure `DATABASE_URL` is set in Render environment variables
   - Get it from your PostgreSQL service → "Info" tab → "Connection String"

2. **Database not created**
   - **Fix:** Run migrations manually or configure auto-migration
   - Add to build command: `bundle install && bundle exec rails db:migrate`

3. **SSL required**
   - **Fix:** Add `?sslmode=require` to `DATABASE_URL` if needed
   - Or set `RAILS_ENV=production` which may require SSL

### Issue 3: Application Won't Start

**Symptoms:**
- "Application failed to respond"
- Health check timeouts
- 502 Bad Gateway errors

**Common Causes & Fixes:**

1. **Port configuration**
   - **Fix:** Ensure Puma uses `ENV['PORT']` (already configured ✅)
   - Verify `config/puma.rb` uses `ENV.fetch("PORT")`

2. **Missing environment variables**
   - **Fix:** Check all required env vars are set
   - Common missing: `SECRET_KEY_BASE`, `RAILS_ENV`, `DATABASE_URL`

3. **Application crashes on startup**
   - **Check logs** for specific error messages
   - Common: Missing service account key, invalid API keys

### Issue 4: Google Cloud Storage Errors

**Symptoms:**
- "Google Cloud Storage credentials not configured"
- "Permission denied" errors
- Image upload failures

**Common Causes & Fixes:**

1. **Service account JSON format**
   - **Fix:** Ensure `GOOGLE_APPLICATION_CREDENTIALS_JSON` is set correctly
   - Must be single-line JSON (no line breaks)
   - Copy entire JSON from `backend/config/service-account-key.json`
   - Remove all line breaks before pasting into Render

2. **Invalid JSON**
   - **Fix:** Validate JSON before pasting
   - Use online JSON validator if needed

3. **Missing project ID or bucket**
   - **Fix:** Ensure these are set:
     - `GOOGLE_CLOUD_PROJECT_ID`
     - `GOOGLE_CLOUD_STORAGE_BUCKET`

### Issue 5: Migration Errors

**Symptoms:**
- "Migration failed"
- "Table already exists" errors
- Database schema errors

**Common Causes & Fixes:**

1. **Migrations not running**
   - **Fix:** Add to build command in Render:
     ```
     bundle install && bundle exec rails db:migrate
     ```
   - Or run manually after first deployment

2. **Schema version mismatch**
   - **Fix:** Check `db/schema.rb` is committed
   - Run `rails db:schema:load` if needed (destructive!)

---

## 🔧 Step-by-Step Troubleshooting

### Step 1: Check Build Logs
1. Go to Render Dashboard → Your Service → Logs
2. Look for **Build Logs** section
3. Check for:
   - ✅ "Bundle install completed successfully"
   - ✅ "Build completed successfully"
   - ❌ Any error messages

### Step 2: Check Runtime Logs
1. Scroll to **Runtime Logs** section
2. Look for:
   - Server startup messages
   - Error stack traces
   - Database connection attempts
   - Application crashes

### Step 3: Verify Environment Variables
1. Go to Render Dashboard → Your Service → Environment
2. Verify all required variables are set:
   - [ ] `RAILS_ENV=production`
   - [ ] `SECRET_KEY_BASE` (set)
   - [ ] `JWT_SECRET_KEY` (set)
   - [ ] `DATABASE_URL` (from PostgreSQL service)
   - [ ] `GEMINI_API_KEY` (set)
   - [ ] `GOOGLE_CLOUD_PROJECT_ID` (set)
   - [ ] `GOOGLE_CLOUD_STORAGE_BUCKET` (set)
   - [ ] `GOOGLE_APPLICATION_CREDENTIALS_JSON` (set - full JSON)

### Step 4: Test Health Endpoint
1. Get your Render service URL (e.g., `https://your-app.onrender.com`)
2. Test health endpoint:
   ```bash
   curl https://your-app.onrender.com/health
   ```
   Should return: `{"status":"ok"}`

3. Test API health:
   ```bash
   curl https://your-app.onrender.com/api/v1/health
   ```
   Should return: `{"status":"ok"}`

### Step 5: Check Database Connection
1. Go to Render Dashboard → PostgreSQL service
2. Check "Metrics" tab for connection status
3. Verify database is accessible
4. Check if migrations ran successfully

---

## 🐛 Common Error Messages & Solutions

### Error: "No such file or directory - /app/config/master.key"
**Solution:**
- Not needed if using environment variables
- Add `RAILS_MASTER_KEY` env var if using encrypted credentials

### Error: "NameError: uninitialized constant"
**Solution:**
- Missing gem in Gemfile
- Run `bundle install` locally to verify
- Check Gemfile.lock is committed

### Error: "PG::ConnectionBad: could not connect to server"
**Solution:**
- Check `DATABASE_URL` is correct
- Verify PostgreSQL service is running
- Check SSL requirements

### Error: "Google::Cloud::Storage::Error: Access Denied"
**Solution:**
- Verify service account JSON is correct
- Check bucket name is correct
- Verify service account has Storage Admin role

### Error: "Puma starting in single mode..."
**Solution:**
- This is normal - Puma uses Render's PORT env var
- Check if it's listening on correct port

---

## 📋 Quick Diagnostic Checklist

Run through these checks:

- [ ] Build logs show successful bundle install
- [ ] Build logs show successful build completion
- [ ] Runtime logs show "Puma starting"
- [ ] Runtime logs show "Listening on tcp://0.0.0.0:XXXX"
- [ ] No error stack traces in runtime logs
- [ ] All environment variables are set
- [ ] DATABASE_URL is correct
- [ ] Health endpoint responds
- [ ] Database migrations completed
- [ ] No "Access Denied" or "Permission" errors

---

## 🆘 If Still Having Issues

1. **Copy the error message** from Render logs
2. **Check the specific error** in this guide
3. **Verify environment variables** one by one
4. **Test locally** with production-like settings:
   ```bash
   RAILS_ENV=production rails server
   ```

---

## 📝 Render-Specific Configuration

### Build Command
```
bundle install && bundle exec rails db:migrate
```

### Start Command
(From Procfile - auto-detected)
```
web: bundle exec puma -C config/puma.rb
```

### Environment Variables Priority
1. **Critical:** Must be set
   - `RAILS_ENV=production`
   - `DATABASE_URL`
   - `SECRET_KEY_BASE`
   - `GEMINI_API_KEY`

2. **Important:** Should be set
   - `JWT_SECRET_KEY`
   - `GOOGLE_CLOUD_PROJECT_ID`
   - `GOOGLE_CLOUD_STORAGE_BUCKET`
   - `GOOGLE_APPLICATION_CREDENTIALS_JSON`

3. **Optional:** Nice to have
   - `REDIS_URL`
   - `ADMIN_PASSWORD`
   - `RAILS_MAX_THREADS`

---

## 🔗 Useful Links

- [Render Logs Documentation](https://render.com/docs/log-streams)
- [Render Rails Deployment](https://render.com/docs/deploy-rails)
- [Render Environment Variables](https://render.com/docs/environment-variables)
- [Render PostgreSQL](https://render.com/docs/databases)

---

## 💡 Pro Tips

1. **Always check logs first** - Most issues are visible in logs
2. **Start with build logs** - If build fails, nothing else matters
3. **Check environment variables** - Most runtime issues are missing/env vars
4. **Test health endpoint** - Quick way to verify app is running
5. **Use Render's built-in terminal** - Access shell to debug directly
