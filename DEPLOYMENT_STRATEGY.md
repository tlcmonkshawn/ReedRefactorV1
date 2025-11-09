# Deployment Strategy

**Date:** 2025-01-27

---

## Current Setup

### Repository Structure
```
ReedRefactorV1/
├── app/              # Rails backend (deployed to Render)
├── config/           # Rails config
├── db/               # Database
├── frontend/         # Flutter app (deployed separately later)
└── ...
```

---

## Deployment Plan

### 1. Rails Backend (Now)
- **Service:** `reed-refactor-v1-backend`
- **Root Directory:** None (Rails app is in repo root)
- **Build Command:** `bundle install`
- **Start Command:** `bundle exec puma -C config/puma.rb`
- **Ignores:** `frontend/` directory (doesn't affect Rails build)

**How it works:**
- Render clones the repo
- Runs `bundle install` in root (finds `Gemfile` in root)
- Rails doesn't care about `frontend/` folder
- Frontend folder is just ignored during Rails build

### 2. Flutter Frontend (Later)
- **Service:** `reed-refactor-v1-frontend` (to be created)
- **Type:** Static Site or Web Service
- **Root Directory:** `frontend`
- **Build Command:** `flutter build web` (or similar)
- **Publish Path:** `frontend/build/web`

**How it works:**
- Render clones the same repo
- Sets `rootDir: frontend`
- Builds Flutter app from `frontend/` directory
- Rails files in root are ignored during Flutter build

---

## Answer to Your Question

**Yes, exactly!**

1. **Backend deployment (now):**
   - Render builds from root
   - `frontend/` directory is ignored (doesn't affect Rails)
   - Rails finds `Gemfile` in root and builds normally

2. **Frontend deployment (later):**
   - Create a new Render service
   - Set `rootDir: frontend`
   - Render builds Flutter from `frontend/` directory
   - Rails files in root are ignored (doesn't affect Flutter)

---

## Benefits

✅ **Same repo** - Everything in one place  
✅ **Independent deployments** - Deploy backend and frontend separately  
✅ **No conflicts** - Each service only builds what it needs  
✅ **Easy to manage** - One repo, two deployments  

---

## When to Deploy Frontend

**Phase 1 (Now):** Just backend
- Get Rails API working
- Test endpoints
- Run migrations

**Phase 2 (Later):** Add frontend
- Test Flutter locally
- Connect to backend API
- Deploy frontend as separate Render service

---

## Frontend Deployment Options

### Option 1: Static Site (Recommended for Flutter Web)
```yaml
- type: static_site
  name: reed-refactor-v1-frontend
  rootDir: frontend
  buildCommand: flutter build web
  publishPath: frontend/build/web
```

### Option 2: Web Service (If you need server-side rendering)
```yaml
- type: web
  name: reed-refactor-v1-frontend
  rootDir: frontend
  buildCommand: flutter build web
  startCommand: (serve static files)
```

---

## Current render.yaml

Right now, `render.yaml` only has the backend service. When we're ready to deploy frontend, we'll add a second service to the same file.

---

**TL;DR:** 
- Backend builds from root (ignores `frontend/`)
- Frontend will build from `frontend/` directory (ignores root Rails files)
- Both from same repo, separate Render services

