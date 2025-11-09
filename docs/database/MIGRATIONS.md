# Database Migrations Guide

**Last Updated:** 2025-01-27

---

## Overview

This project uses Rails migrations to manage the database schema. There are **13 migration files** that create all database tables.

---

## Migration Status

### Current Migrations

- ✅ `users` - User accounts
- ✅ `locations` - Store locations
- ✅ `booties` - Main items/inventory
- ✅ `research_logs` - Research tracking
- ✅ `grounding_sources` - Source citations
- ✅ `conversations` - Chat conversations
- ✅ `messages` - Chat messages
- ✅ `leaderboards` - Leaderboard data
- ✅ `scores` - User scores
- ✅ `achievements` - Achievement definitions
- ✅ `user_achievements` - User achievement tracking
- ✅ `game_sessions` - Game session tracking
- ✅ `prompts` - AI prompt templates

---

## Running Migrations

### Production (Render.com)

#### Automatic (Recommended)

Migrations run automatically on every deploy via `backend/bin/render-start.sh`:

1. **Trigger a deploy**:
   - Push to GitHub (auto-deploy)
   - Or manually trigger in Render Dashboard

2. **Check build logs**:
   - Render Dashboard → Service → Logs
   - Look for "Running database migrations..."
   - Verify "✅ Migrations in database: 13"

#### Manual via HTTP Endpoint

If migrations didn't run automatically:

```bash
# Check migration status
curl https://reed-bootie-hunter-v1-1.onrender.com/migrations/status

# Run migrations
curl -X POST "https://reed-bootie-hunter-v1-1.onrender.com/migrations/run?password=iamagoodgirl"
```

#### Manual via Render Shell

If Render provides shell access:

```bash
cd backend
RAILS_ENV=production bundle exec rails db:migrate
```

### Local Development

```bash
cd backend

# Create database (first time only)
rails db:create

# Run migrations
rails db:migrate

# Check migration status
rails db:migrate:status
```

---

## Verifying Migrations

### Method 1: Health Endpoint

```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/health
```

Expected response:
```json
{
  "status": "ok",
  "database": "connected",
  "users_table": {
    "exists": true,
    "columns": ["id", "email", "name", ...]
  },
  "migrations_run": 13
}
```

### Method 2: Migration Status Endpoint

```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/migrations/status
```

Expected response:
```json
{
  "status": "ok",
  "migrations_run": 13,
  "migrations_pending": 0
}
```

### Method 3: Rails Console

```bash
cd backend
rails console

# Check migration count
ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM schema_migrations").first['count']

# Check if users table exists
ActiveRecord::Base.connection.table_exists?('users')
```

---

## Troubleshooting

### Migrations Don't Run Automatically

**Possible Causes:**
1. Database connection not available during build
2. `DATABASE_URL` not set or incorrect
3. SSL connection issue (see [Connection Guide](./CONNECTION.md))

**Solutions:**
1. Use manual HTTP endpoint (runs after app starts)
2. Verify `DATABASE_URL` includes `?sslmode=require`
3. Check Render logs for connection errors

### "Table Already Exists" Errors

This means migrations already ran! Check status:
```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/migrations/status
```

### Migration Fails

**Check:**
1. Database connection is working
2. `DATABASE_URL` is correct
3. Database has proper permissions
4. Render logs for detailed error messages

---

## Rebuilding Database

⚠️ **WARNING**: This will DELETE ALL DATA!

Use the rebuild script: `scripts/rebuild_database.ps1`

**Note**: Rebuilding the database will delete all data. Make sure to backup important data first.

---

## Related Documentation

- [Connection Guide](./CONNECTION.md) - Database connection setup
- [Schema Documentation](../DATABASE.md) - Complete schema reference
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues

---

*Last Updated: 2025-01-27*

