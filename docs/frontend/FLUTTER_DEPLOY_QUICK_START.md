# 🚀 Flutter Frontend - Quick Deployment Guide

## ✅ What's Been Done

1. ✅ **API URL Updated** - Automatically uses production URL when deployed
2. ✅ **Web Support Added** - Flutter web directory created
3. ✅ **Deployment Configs Created** - Netlify and Render options ready

---

## 🎯 Recommended: Deploy to Netlify (Easiest)

**Netlify has built-in Flutter support!**

### Steps:

1. **Go to**: https://app.netlify.com
2. **Sign up/Login** (free account)
3. **Click "Add new site" → "Import an existing project"**
4. **Connect to GitHub** → Select your repo
5. **Configure**:
   - **Base directory**: `frontend`
   - **Build command**: `flutter build web --release` (auto-detected from `netlify.toml`)
   - **Publish directory**: `frontend/build/web` (auto-detected)
6. **Click "Deploy site"**

**That's it!** Netlify will:
- Install Flutter automatically
- Build your app
- Deploy it
- Give you a URL like: `https://your-app-name.netlify.app`

---

## 🔄 Alternative: Build Locally & Deploy to Render

If you prefer to use Render:

1. **Build locally:**
   ```powershell
   cd frontend
   flutter build web --release
   ```

2. **Deploy to Render:**
   - Render Dashboard → New Static Site
   - Root Directory: `frontend/build/web`
   - Build Command: (leave empty)
   - Publish Directory: `.`

---

## 🧪 Test Before Deploying

**Build and test locally first:**

```powershell
cd frontend
flutter pub get
flutter build web --release
```

**Serve locally:**
```powershell
cd build/web
python -m http.server 8000
# Visit: http://localhost:8000
```

---

## 🔗 Your URLs

- **Backend API**: https://reed-bootie-hunter-v1-1.onrender.com
- **Frontend** (after deploy): Will be provided by Netlify/Render
- **Admin**: https://reed-bootie-hunter-v1-1.onrender.com/admin

---

## ✅ What to Verify After Deployment

1. ✅ Frontend loads without errors
2. ✅ Can access login/register page
3. ✅ API calls work (check browser console Network tab)
4. ✅ No CORS errors (backend is already configured)

---

## 📚 Full Documentation

See `FLUTTER_DEPLOYMENT.md` for detailed instructions and troubleshooting.

---

**Ready to deploy?** → Go to Netlify and follow the steps above! 🚀
