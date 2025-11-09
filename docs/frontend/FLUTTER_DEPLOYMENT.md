# Flutter Frontend Deployment Guide

## Overview

This guide covers deploying the Flutter web frontend to Render.com as a static site.

**Backend URL**: https://reed-bootie-hunter-v1-1.onrender.com
**Frontend will be deployed to**: Render Static Site (separate service)

---

## ✅ Pre-Deployment Checklist

- [x] API URL updated to production in `main.dart`
- [x] Flutter web support enabled
- [ ] Test Flutter web build locally
- [ ] Deploy to Render

---

## 🧪 Step 1: Test Flutter Web Build Locally

Before deploying, test the web build locally:

```powershell
cd frontend
flutter pub get
flutter build web
```

This creates `frontend/build/web/` with the compiled web app.

**Test locally:**
```powershell
# Serve the built web app
cd build/web
# Use any static file server, or:
python -m http.server 8000
# Then visit: http://localhost:8000
```

---

## 🚀 Step 2: Deploy to Render (Static Site)

### ⚠️ Important: Render Static Sites Limitation

**Render's static site builder does NOT have Flutter installed by default.**

You have two options:

### Option A: Build Locally, Deploy Built Files (Recommended)

1. **Build Flutter web locally:**
   ```powershell
   cd frontend
   flutter build web --release
   ```

2. **Create a separate branch or directory for built files:**
   - Option 1: Commit `build/web` to a `gh-pages` branch
   - Option 2: Use a different hosting service (see Option C below)

3. **Deploy the built files:**
   - Render Dashboard → New Static Site
   - Root Directory: `frontend/build/web`
   - Build Command: (leave empty or `echo "Pre-built"`)
   - Publish Directory: `.` (current directory)

### Option B: Use Custom Docker Build (Advanced)

Create a `Dockerfile` in `frontend/`:
```dockerfile
FROM ubuntu:22.04

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .
RUN flutter pub get && flutter build web --release

# Output is in /app/build/web
```

Then use Render's Docker deployment instead of static site.

### Option C: Alternative Hosting (Easier)

**Recommended alternatives:**
- **Netlify** - Has Flutter support
- **Vercel** - Can build Flutter with custom build command
- **Firebase Hosting** - Good Flutter support
- **GitHub Pages** - Free, simple

**For Netlify:**
1. Create `netlify.toml` in `frontend/`:
   ```toml
   [build]
     command = "flutter build web --release"
     publish = "build/web"
   ```

2. Connect repo to Netlify
3. Deploy automatically

### Option B: Using render.yaml (Infrastructure as Code)

Add this to your `render.yaml`:

```yaml
services:
  # ... existing backend service ...

  - type: static
    name: bootiehunter-frontend
    rootDir: frontend
    buildCommand: flutter build web --release
    publishPath: frontend/build/web
    headers:
      - path: /*
        name: X-Content-Type-Options
        value: nosniff
      - path: /*
        name: X-Frame-Options
        value: DENY
      - path: /*
        name: X-XSS-Protection
        value: 1; mode=block
```

Then deploy via Render Dashboard → "New" → "Blueprint" → Select your repo.

---

## ⚙️ Step 3: Configure Build Settings

### Build Command
```bash
flutter build web --release
```

### Publish Directory
```
frontend/build/web
```

### Environment Variables (if needed)
- None required for static site
- API URL is hardcoded in `main.dart` for production

---

## 🔧 Step 4: Update API URL (If Needed)

The API URL is automatically set in `main.dart`:
- **Web (Production)**: `https://reed-bootie-hunter-v1-1.onrender.com/api/v1`
- **Local Development**: `http://localhost:3000/api/v1`

To change the production URL, edit `frontend/lib/main.dart`:

```dart
String getApiBaseUrl() {
  if (kIsWeb) {
    return 'https://your-backend-url.onrender.com/api/v1';
  } else {
    return 'http://localhost:3000/api/v1';
  }
}
```

---

## 📋 Step 5: Verify Deployment

After deployment:

1. **Visit your frontend URL** (provided by Render)
2. **Check browser console** for errors
3. **Test login/registration** - should connect to backend
4. **Verify API calls** - check Network tab in DevTools

---

## 🐛 Troubleshooting

### Build Fails

**Error**: `flutter: command not found`
- **Solution**: Render needs Flutter installed. You may need to use a custom build image or install Flutter in the build command.

**Error**: `No pubspec.yaml found`
- **Solution**: Verify `rootDir` is set to `frontend`

### API Connection Issues

**Error**: CORS errors in browser console
- **Solution**: Backend CORS is already configured to allow all origins (`*`)

**Error**: 404 on API calls
- **Solution**: Verify API URL in `main.dart` matches your backend URL

### Assets Not Loading

**Error**: Images/icons not showing
- **Solution**: Check `pubspec.yaml` assets section and ensure files exist

---

## 🔄 Continuous Deployment

Render will automatically redeploy when you push to your connected branch (usually `main`).

**To trigger manual deploy:**
1. Render Dashboard → Your Static Site
2. Click "Manual Deploy" → "Deploy latest commit"

---

## 📊 Deployment Status

After deployment, you'll have:

- **Backend**: https://reed-bootie-hunter-v1-1.onrender.com
- **Frontend**: https://your-frontend-name.onrender.com
- **Admin**: https://reed-bootie-hunter-v1-1.onrender.com/admin

---

## 🎯 Next Steps After Deployment

1. ✅ Test all features in production
2. ✅ Set up custom domain (optional)
3. ✅ Configure SSL (automatic with Render)
4. ✅ Set up monitoring/analytics (optional)

---

## 📚 Related Documentation

- `WHAT_NEXT.md` - General next steps
- `DEPLOYMENT_COMPLETE.md` - Backend deployment status
- `frontend/README.md` - Frontend development guide

---

**Last Updated**: November 6, 2025
