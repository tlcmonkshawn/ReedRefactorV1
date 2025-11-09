# Quick Start Guide

## Immediate Next Steps

### 1. Install PostgreSQL ✅

**Windows:**
- Download: https://www.postgresql.org/download/windows/
- **Remember the password** you set during installation!
- Default port: 5432
- Default username: `postgres`

**Test installation:**
```bash
psql -U postgres
# Enter your password when prompted
```

### 2. Install Redis ✅

**Option 1: Memurai (Easiest for Windows)**
- Download: https://www.memurai.com/
- Install and start service
- Port: 6379

**Option 2: Docker**
```bash
docker run -d -p 6379:6379 redis
```

**Test installation:**
```bash
redis-cli ping
# Should return: PONG
```

### 3. Create Backend `.env` File

Navigate to `backend/` directory and create `.env` file:

```bash
# Rails app is now in root directory
copy .env.example .env
# Then edit .env with your PostgreSQL password
```

**Minimum required for now:**
```bash
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD  # From step 1
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=run_rails_secret_to_generate
JWT_SECRET_KEY=run_rails_secret_to_generate
```

**Note**: For production (Render), `DATABASE_URL` must include `?sslmode=require`. See [Database Connection Guide](docs/database/CONNECTION.md) for details.

**Generate secrets:**
```bash
# Rails app is now in root directory
rails secret
# Copy the output and use for SECRET_KEY_BASE and JWT_SECRET_KEY
```

### 4. Set Up Database

```bash
# Rails app is now in root directory
bundle install
rails db:create
rails db:migrate
```

**If you get errors:**
- Check PostgreSQL is running: `net start postgresql-x64-XX` (check Services for exact name)
- Verify `.env` file has correct password
- Try: `psql -U postgres -h localhost` to test connection manually

### 5. Test Backend

```bash
# Rails app is now in root directory
rails server
```

Visit: http://localhost:3000/health

Should see: `{"status":"ok","timestamp":"..."}`

### 6. Test Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## What's Working Now

✅ **Backend Structure:**
- All models, controllers, routes ready
- Database schema ready
- API endpoints defined

✅ **Frontend Structure:**
- All screens built
- Navigation working
- UI components ready

⏳ **Waiting for:**
- API keys (Gemini, Square, Discogs, Google Cloud)
- Backend service implementations (need API keys)

## After Installation Checklist

- [ ] PostgreSQL installed and running
- [ ] Redis/Memurai installed and running
- [ ] Backend `.env` file created with PostgreSQL password
- [ ] Database created (`rails db:create`)
- [ ] Migrations run (`rails db:migrate`)
- [ ] Backend server starts (`rails server`)
- [ ] Frontend runs (`flutter run`)

## Next Steps After Setup

1. Get API keys from the other agent
2. Add API keys to `.env` file
3. Test API integrations
4. Start building features!

