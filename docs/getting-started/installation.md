# Installation Guide - R.E.E.D. Bootie Hunter

**Status**: ✅ Complete setup guide
**Last Updated**: 2025-01-27

---

## Quick Start

If you just want to get running quickly, see [QUICK_START.md](../../QUICK_START.md) for the fastest path.

This guide provides comprehensive installation instructions for all components.

---

## Prerequisites

### Required Tools

1. **PostgreSQL 12+** - Database
2. **Redis** - Background jobs and caching
3. **Ruby 3.0+** - Backend runtime
4. **Rails 7.1+** - Backend framework
5. **Flutter 3.16+** - Frontend framework
6. **Git** - Version control

### Optional Tools

- **Docker** - Alternative Redis installation
- **Postman/Insomnia** - API testing
- **VS Code/Cursor** - Code editor

---

## Step 1: Install PostgreSQL

### Windows

1. **Download**: https://www.postgresql.org/download/windows/
2. **Run installer** and follow prompts
3. **Important**: Remember the password you set during installation!
4. **Default settings**:
   - Port: `5432`
   - Username: `postgres`
   - Service name: `postgresql-x64-XX` (version number)

### Verify Installation

```bash
psql -U postgres
# Enter your password when prompted
# Type \q to exit
```

### Start Service (if not running)

```powershell
# Check Services app or run:
net start postgresql-x64-XX  # Replace XX with your version
```

---

## Step 2: Install Redis

### Option 1: Memurai (Recommended for Windows)

1. **Download**: https://www.memurai.com/
2. **Install** and start the service
3. **Default port**: `6379`

### Option 2: Docker

```bash
docker run -d -p 6379:6379 redis
```

### Verify Installation

```bash
redis-cli ping
# Should return: PONG
```

---

## Step 3: Install Ruby

### Windows

1. **Download Ruby+Devkit**: https://rubyinstaller.org/downloads/
2. **Use Ruby 3.0 or higher** (3.4.7 recommended)
3. **During installation**: Make sure to install MSYS2 development toolchain
4. **Verify**:
   ```bash
   ruby --version
   # Should show Ruby 3.0.x or higher
   ```

---

## Step 4: Install Rails

```bash
gem install rails
```

**Verify**:
```bash
rails --version
# Should show Rails 7.1.x or higher
```

---

## Step 5: Install Flutter

### Windows

1. **Download**: https://docs.flutter.dev/get-started/install/windows
2. **Extract** to a location (e.g., `C:\flutter`)
3. **Add to PATH**: Add Flutter `bin` directory to your system PATH
4. **Verify**:
   ```bash
   flutter doctor
   # Fix any issues reported
   ```

**Verify Installation**:
```bash
flutter --version
# Should show Flutter 3.16.x or higher
```

---

## Step 6: Configure Backend

### Create `.env` File

Navigate to `backend/` directory:

```bash
cd backend
```

Create `.env` file (copy from `.env.example` if available):

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD  # From Step 1

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Rails Secrets (generate these)
SECRET_KEY_BASE=run_rails_secret_to_generate
JWT_SECRET_KEY=run_rails_secret_to_generate

# Admin Password
ADMIN_PASSWORD=your_admin_password_here

# Google Cloud Platform (required for production)
GOOGLE_CLOUD_PROJECT_ID=your_project_id
GOOGLE_CLOUD_STORAGE_BUCKET=your_bucket_name
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_APPLICATION_CREDENTIALS_PATH=config/service-account-key.json

# Optional Integrations
SQUARE_ACCESS_TOKEN=
SQUARE_APPLICATION_ID=
SQUARE_LOCATION_ID=
DISCOGS_USER_TOKEN=
```

### Generate Rails Secrets

```bash
cd backend
rails secret
# Copy the output and use for SECRET_KEY_BASE
rails secret
# Copy the output and use for JWT_SECRET_KEY
```

### Install Dependencies

```bash
cd backend
bundle install
```

---

## Step 7: Set Up Database

```bash
cd backend
rails db:create
rails db:migrate
```

**If you get errors**:
- Check PostgreSQL is running: `net start postgresql-x64-XX`
- Verify `.env` file has correct password
- Try: `psql -U postgres -h localhost` to test connection manually

---

## Step 8: Configure Frontend

### Install Dependencies

```bash
cd frontend
flutter pub get
```

### Configure API Base URL

The frontend automatically uses:
- **Production**: `https://reed-bootie-hunter-v1-1.onrender.com/api/v1` (when running on web)
- **Development**: `http://localhost:3000/api/v1` (when running locally)

No configuration needed unless you want to override.

---

## Step 9: Test Installation

### Test Backend

```bash
cd backend
rails server
```

Visit: http://localhost:3000/health

Should see: `{"status":"ok","timestamp":"..."}`

### Test Frontend

```bash
cd frontend
flutter run -d chrome
```

The app should launch in your browser.

---

## Google Cloud Platform Setup

### Required for Production Features

1. **Create Project**: https://console.cloud.google.com/
2. **Enable APIs**:
   - Generative Language API (Gemini)
   - Cloud Storage API
3. **Create Storage Bucket**:
   - Name: `bootiehunter-v1-images` (or your choice)
   - Region: `us-central1` (or your preference)
4. **Create Service Account**:
   - Role: Storage Admin
   - Download JSON key
   - Save to `backend/config/service-account-key.json`
5. **Get Gemini API Key**:
   - Google AI Studio: https://makersuite.google.com/app/apikey
   - Add to `.env` as `GEMINI_API_KEY`

---

## Troubleshooting

### PostgreSQL Connection Issues

**Error**: `could not connect to server`
- **Fix**: Start PostgreSQL service
  ```powershell
  net start postgresql-x64-XX
  ```

**Error**: `password authentication failed`
- **Fix**: Verify password in `.env` matches PostgreSQL password
- **Test**: `psql -U postgres -h localhost`

### Redis Connection Issues

**Error**: `Connection refused`
- **Fix**: Start Redis/Memurai service
- **Test**: `redis-cli ping` should return `PONG`

### Rails Issues

**Error**: `bundle install` fails
- **Fix**: Make sure Ruby DevKit is installed
- **Fix**: Run `ridk install` if on Windows

**Error**: `rails db:create` fails
- **Fix**: Check PostgreSQL is running
- **Fix**: Verify `.env` file has correct database credentials

### Flutter Issues

**Error**: `flutter doctor` shows issues
- **Fix**: Follow the suggestions from `flutter doctor`
- **Common**: Install Android Studio or VS Code extensions

**Error**: `flutter pub get` fails
- **Fix**: Check internet connection
- **Fix**: Try `flutter pub cache repair`

---

## Next Steps

After installation is complete:

1. **Read**: [QUICK_START.md](../../QUICK_START.md) for immediate next steps
2. **Review**: [DEVELOPMENT_GUIDE.md](../DEVELOPMENT_GUIDE.md) for development workflow
3. **Check**: [LAUNCH_READINESS.md](../../LAUNCH_READINESS.md) for current project status

---

## Related Documentation

- [QUICK_START.md](../../QUICK_START.md) - Fast setup guide
- [SETUP_REQUIREMENTS.md](../../SETUP_REQUIREMENTS.md) - API keys and requirements
- [DEVELOPMENT_GUIDE.md](../DEVELOPMENT_GUIDE.md) - Development workflow
- [ARCHITECTURE.md](../ARCHITECTURE.md) - System architecture

---

*Last Updated: 2025-01-27*
