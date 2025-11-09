# What We Are Building - Simple Explanation

**Date:** 2025-01-27

---

## The Project

**ReedRefactorV1** - A gamified inventory management system for Reedsport Records & Resale store.

---

## Current Structure

```
ReedRefactorV1/
├── app/              # Rails API backend (the server)
├── config/           # Rails configuration
├── db/               # Database (PostgreSQL)
├── frontend/         # Flutter app (the mobile/web client)
└── docs/             # Documentation
```

**Right now:** Both Rails backend AND Flutter frontend are in the same repository.

---

## What We're Building

### 1. **Rails Backend (API Server)**
- **Location:** Root of this repo (was `backend/`, now moved to root)
- **Purpose:** Provides API endpoints for the Flutter app
- **Deployed:** Render.com (https://reed-refactor-v1-backend.onrender.com)
- **Database:** PostgreSQL on Render
- **Storage:** Google Cloud Storage for images

**What it does:**
- User authentication (login/register)
- Bootie (item) management
- AI-powered price research
- Image upload/processing
- Square integration (e-commerce)
- Discogs integration (music database)

### 2. **Flutter Frontend (Mobile/Web App)**
- **Location:** `frontend/` directory in this repo
- **Purpose:** User interface (what users see and interact with)
- **Deployed:** (Not yet deployed - that's Phase 1)

**What it does:**
- Camera interface for capturing items
- Real-time AI conversation (Gemini Live)
- Item browsing and management
- Research results display
- Finalization workflow

---

## Development Plan (Simplified)

### Phase 1: Get Backend Working ✅ (In Progress)
- ✅ Storage reimplemented
- ✅ Render services created
- ✅ Database configured
- ⏳ Deploy and test backend
- ⏳ Run migrations
- ⏳ Test API endpoints

### Phase 2: Get Frontend Working
- Test Flutter app locally
- Connect to backend API
- Test full workflow
- Deploy frontend (separate service or same repo?)

### Phase 3: Add Features
- Image editing/voting
- Interface restreaming
- Extra game modes

---

## Options for Frontend

### Option 1: Keep in Same Repo (Current)
**Pros:**
- Everything in one place
- Easy to manage
- Single deployment pipeline

**Cons:**
- Larger repo
- Frontend and backend deploy together (might not want that)

### Option 2: Separate Repo
**Pros:**
- Cleaner separation
- Independent deployments
- Different teams can work separately

**Cons:**
- Two repos to manage
- Need to coordinate versions

### Option 3: Keep Code Together, Deploy Separately
**Pros:**
- Code in one place
- Deploy separately when needed
- Best of both worlds

**Cons:**
- Slightly more complex deployment

---

## Recommendation

**For now:** Keep frontend in `frontend/` directory (same repo)

**Why:**
- Easier to develop and test together
- Can deploy separately later if needed
- Simpler for Phase 1 validation

**Later:** If you want to separate them, we can:
- Create a new repo for frontend
- Move `frontend/` directory
- Update API URLs
- Deploy separately

---

## What We Just Did

1. ✅ **Moved Rails app to root** - No more `backend/` directory
2. ✅ **Simplified structure** - Rails app is now the main thing in root
3. ✅ **Updated Render config** - No `rootDir` needed anymore
4. ✅ **Ready to deploy** - Once we push, Render will build from root

---

## Next Steps

1. **Push to GitHub** (fix the secret issue first)
2. **Render auto-deploys** (should work now - Gemfile is in root)
3. **Test backend** (health endpoint, migrations)
4. **Then work on frontend** (test locally, connect to backend)

---

## TL;DR

- **This repo:** Rails backend (root) + Flutter frontend (`frontend/` folder)
- **Deploying:** Rails backend to Render.com first
- **Frontend:** Test locally, deploy later (can be same repo or separate)
- **Goal:** Get backend working, then connect frontend

**Simple answer:** Yes, this is the Rails program. Frontend is here too (for now), but we can separate it later if you want.

