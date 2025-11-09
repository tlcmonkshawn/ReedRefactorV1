# Selective Copy Plan - Bootie Hunter V1 → ReedRefactorV1

**Date:** 2025-01-27  
**Strategy:** Copy only essential code, skip junk, rebuild tests

---

## Copy Strategy

### ✅ What to Copy

#### Backend (Rails)
```
backend/
├── app/
│   ├── controllers/          ✅ ALL
│   ├── models/               ✅ ALL
│   ├── services/             ✅ ALL
│   └── views/                ✅ ALL (admin interface)
├── config/                   ✅ ALL
├── db/
│   ├── migrate/              ✅ ALL (13 migrations)
│   ├── schema.rb             ✅
│   └── seeds/                ✅
├── lib/                      ✅
├── Gemfile                   ✅
├── Gemfile.lock              ✅
├── Procfile                  ✅
├── Rakefile                  ✅
├── config.ru                 ✅
└── scripts/                  ✅ SELECTIVE (only essential)
    ├── setup_database.ps1
    ├── generate_secrets.ps1
    ├── generate_secrets.rb
    ├── create_env_file.ps1
    └── setup_check.rb
```

#### Frontend (Flutter)
```
frontend/
├── lib/                      ✅ ALL
├── web/                      ✅ ALL
├── pubspec.yaml              ✅
├── pubspec.lock              ✅
└── analysis_options.yaml     ✅
```

#### Documentation
```
✅ PRODUCT_PROFILE.md
✅ AGENTS.md
✅ README.md
✅ QUICK_START.md
✅ DEVELOPER_HANDOFF.md
✅ docs/
   ├── ARCHITECTURE.md
   ├── API.md
   ├── DATABASE.md
   ├── STATUS.md
   ├── CONTEXT.md
   ├── backend/
   │   └── GEMINI_LIVE_ARCHITECTURE.md
   └── database/
       └── (all files)
   └── deployment/
       └── (all files)
   └── frontend/
       └── (all files)
   └── getting-started/
       └── (all files)
```

#### Configuration
```
✅ render.yaml
✅ .gitignore (update)
✅ .gitattributes
```

### ❌ What to Skip

```
❌ docs/archive/              (old docs, fixes, verification)
❌ scripts/ (root level)      (old scripts)
❌ *.log files                (log files)
❌ *.code-workspace           (workspace files)
❌ netlify.toml               (old deployment)
❌ locations_backup.json      (backup file)
❌ spec/                      (tests - rebuild fresh)
❌ test/                      (tests - rebuild fresh)
❌ node_modules/              (if exists)
❌ vendor/                    (if exists)
```

---

## Copy Commands

### Step 1: Create Directory Structure
```powershell
cd c:\Code\ReedRefactorV1
mkdir backend
mkdir frontend
mkdir docs
```

### Step 2: Copy Backend
```powershell
# Copy app directory
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\backend\app" "c:\Code\ReedRefactorV1\backend\app"

# Copy config
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\backend\config" "c:\Code\ReedRefactorV1\backend\config"

# Copy db
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\backend\db" "c:\Code\ReedRefactorV1\backend\db"

# Copy lib
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\backend\lib" "c:\Code\ReedRefactorV1\backend\lib"

# Copy root files
copy "c:\Code\REED_Bootie_Hunter_V1\backend\Gemfile" "c:\Code\ReedRefactorV1\backend\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\Gemfile.lock" "c:\Code\ReedRefactorV1\backend\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\Procfile" "c:\Code\ReedRefactorV1\backend\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\Rakefile" "c:\Code\ReedRefactorV1\backend\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\config.ru" "c:\Code\ReedRefactorV1\backend\"

# Copy essential scripts
mkdir "c:\Code\ReedRefactorV1\backend\scripts"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\scripts\setup_database.ps1" "c:\Code\ReedRefactorV1\backend\scripts\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\scripts\generate_secrets.ps1" "c:\Code\ReedRefactorV1\backend\scripts\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\scripts\generate_secrets.rb" "c:\Code\ReedRefactorV1\backend\scripts\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\scripts\create_env_file.ps1" "c:\Code\ReedRefactorV1\backend\scripts\"
copy "c:\Code\REED_Bootie_Hunter_V1\backend\scripts\setup_check.rb" "c:\Code\ReedRefactorV1\backend\scripts\"
```

### Step 3: Copy Frontend
```powershell
# Copy lib
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\frontend\lib" "c:\Code\ReedRefactorV1\frontend\lib"

# Copy web
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\frontend\web" "c:\Code\ReedRefactorV1\frontend\web"

# Copy root files
copy "c:\Code\REED_Bootie_Hunter_V1\frontend\pubspec.yaml" "c:\Code\ReedRefactorV1\frontend\"
copy "c:\Code\REED_Bootie_Hunter_V1\frontend\pubspec.lock" "c:\Code\ReedRefactorV1\frontend\"
copy "c:\Code\REED_Bootie_Hunter_V1\frontend\analysis_options.yaml" "c:\Code\ReedRefactorV1\frontend\"
```

### Step 4: Copy Documentation
```powershell
# Copy root docs
copy "c:\Code\REED_Bootie_Hunter_V1\PRODUCT_PROFILE.md" "c:\Code\ReedRefactorV1\"
copy "c:\Code\REED_Bootie_Hunter_V1\AGENTS.md" "c:\Code\ReedRefactorV1\"
copy "c:\Code\REED_Bootie_Hunter_V1\QUICK_START.md" "c:\Code\ReedRefactorV1\"
copy "c:\Code\REED_Bootie_Hunter_V1\DEVELOPER_HANDOFF.md" "c:\Code\ReedRefactorV1\"

# Copy docs (excluding archive)
xcopy /E /I /Y "c:\Code\REED_Bootie_Hunter_V1\docs" "c:\Code\ReedRefactorV1\docs"
# Then delete archive folder
rmdir /S /Q "c:\Code\ReedRefactorV1\docs\archive"
```

### Step 5: Copy Configuration
```powershell
copy "c:\Code\REED_Bootie_Hunter_V1\render.yaml" "c:\Code\ReedRefactorV1\"
```

---

## Post-Copy Tasks

### 1. Update .gitignore
- Ensure it covers Rails and Flutter
- Add environment files
- Add build artifacts

### 2. Create .env.example
- Document all required environment variables
- Include placeholders

### 3. Review TODOs
- Square integration service
- Discogs integration service
- Document what needs completion

### 4. Rebuild Tests
- Create fresh test suite
- Focus on critical paths
- Integration tests for API

### 5. Verify Structure
- Check all files copied
- Verify no junk included
- Test build process

---

## Verification Checklist

After copying, verify:

- [ ] Backend structure complete
- [ ] Frontend structure complete
- [ ] All migrations present (13 files)
- [ ] All models present (13 files)
- [ ] All controllers present
- [ ] All services present
- [ ] Essential docs copied
- [ ] No archive folder
- [ ] No log files
- [ ] No workspace files
- [ ] render.yaml present
- [ ] Gemfile present
- [ ] pubspec.yaml present

---

**Ready to Execute** ✅

