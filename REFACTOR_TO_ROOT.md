# Refactoring to Root Directory

**Date:** 2025-01-27  
**Goal:** Move Rails app from `backend/` to project root for simpler structure

---

## Plan

1. Move all files from `backend/` to root
2. Update `render.yaml` to remove `rootDir: backend`
3. Update documentation references
4. Keep `frontend/` as is (separate concern)

---

## Files to Move

- `backend/app/` → `app/`
- `backend/config/` → `config/`
- `backend/db/` → `db/`
- `backend/lib/` → `lib/`
- `backend/scripts/` → `scripts/`
- `backend/Gemfile` → `Gemfile`
- `backend/Gemfile.lock` → `Gemfile.lock`
- `backend/Procfile` → `Procfile`
- `backend/Rakefile` → `Rakefile`
- `backend/config.ru` → `config.ru`
- `backend/docs/` → merge with `docs/` (or keep separate)

---

## Files to Update

- `render.yaml` - Remove `rootDir: backend`
- Documentation files that reference `backend/`
- Scripts that reference `backend/`

---

## After Refactor

New structure:
```
ReedRefactorV1/
├── app/              # Rails app
├── config/           # Rails config
├── db/               # Database
├── lib/              # Rails lib
├── scripts/          # Utility scripts
├── frontend/         # Flutter app (separate)
├── docs/             # Documentation
├── Gemfile           # Rails dependencies
├── Procfile          # Process file
├── render.yaml       # Render config
└── ...
```

