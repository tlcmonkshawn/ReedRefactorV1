# Database Connection Guide

**Last Updated:** 2025-01-27

---

## Critical: Render PostgreSQL Requires SSL

⚠️ **IMPORTANT**: Render PostgreSQL databases **REQUIRE SSL connections**. The `DATABASE_URL` must include `?sslmode=require` or the connection will fail.

---

## Connection Configuration

### Production (Render.com)

#### Required Format

The `DATABASE_URL` must include SSL mode:

```
postgresql://username:password@host:port/database?sslmode=require
```

#### Example (Correct)

```
postgresql://bootiehunter_user:password@dpg-xxxxx.oregon-postgres.render.com/bootiehunter_production?sslmode=require
```

#### Example (WRONG - Will Fail)

```
postgresql://bootiehunter_user:password@dpg-xxxxx.oregon-postgres.render.com/bootiehunter_production
```

**Missing `?sslmode=require` will cause connection failures!**

---

## Rails Configuration

### `backend/config/database.yml`

The production configuration correctly uses `DATABASE_URL`:

```yaml
production:
  <<: *default
  <% if ENV["DATABASE_URL"].present? %>
  # Use DATABASE_URL if provided (preferred for Render.com)
  # Render PostgreSQL REQUIRES SSL - sslmode must be in DATABASE_URL itself
  url: <%= ENV["DATABASE_URL"] %>
  <% else %>
  # Fallback configuration...
  <% end %>
```

**Key Points:**
- ✅ Uses `url:` when `DATABASE_URL` is present
- ✅ SSL mode must be in the URL itself (not in separate config)
- ✅ Rails ignores other SSL parameters when using `url:`

---

## Setting DATABASE_URL in Render

### Method 1: Render Dashboard (Recommended)

1. Go to Render Dashboard → Your Web Service → Environment
2. Add or edit `DATABASE_URL`:
   ```
   postgresql://username:password@host:port/database?sslmode=require
   ```
3. **Make sure `?sslmode=require` is included!**

**Note**: The `render-start.sh` script automatically adds `?sslmode=require` if missing, but it's better to set it explicitly to avoid confusion.

### Method 2: Auto-Injection (If Database is Linked)

If your PostgreSQL service is linked to your web service:
- Render auto-injects `DATABASE_URL`
- **The auto-injected URL may NOT include `?sslmode=require`**
- **The `render-start.sh` script automatically adds it**, but verify it's working
- If connection fails, manually add `?sslmode=require` to the auto-injected value

### Method 3: render.yaml

```yaml
envVars:
  - key: DATABASE_URL
    value: postgresql://username:password@host:port/database?sslmode=require
```

**Always include `?sslmode=require` in the URL!**

---

## Local Development

### Development Environment

For local development, SSL is typically not required:

```yaml
development:
  <<: *default
  database: bootiehunter_development
  username: <%= ENV.fetch("DB_USERNAME") { "postgres" } %>
  password: <%= ENV.fetch("DB_PASSWORD") { "" } %>
  host: <%= ENV.fetch("DB_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DB_PORT") { "5432" } %>
```

Or with `DATABASE_URL` (no SSL needed locally):

```
postgresql://postgres:password@localhost:5432/bootiehunter_development
```

---

## Testing the Connection

### Method 1: Health Endpoint

```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/health
```

Expected response:
```json
{
  "status": "ok",
  "database": "connected",
  "database_config": {
    "adapter": "postgresql",
    "database": "bootiehunter_production",
    "host": "dpg-xxxxx.oregon-postgres.render.com"
  }
}
```

### Method 2: Rails Console (Local)

```bash
cd backend
rails console

# Test connection
ActiveRecord::Base.connection.execute("SELECT 1")
# Should return: #<PG::Result:0x...>

# Check database name
ActiveRecord::Base.connection.current_database
# Should return: "bootiehunter_development" or "bootiehunter_production"
```

### Method 3: psql Command Line

```bash
# For Render database (requires SSL)
psql "postgresql://username:password@host:port/database?sslmode=require"

# For local database
psql -U postgres -d bootiehunter_development
```

---

## Common Connection Errors

### Error: "SSL connection required"

**Problem**: `DATABASE_URL` is missing `?sslmode=require`

**Solution**: Add `?sslmode=require` to the end of your `DATABASE_URL`

```
# Wrong
postgresql://user:pass@host/db

# Correct
postgresql://user:pass@host/db?sslmode=require
```

### Error: "Connection refused" or "Could not connect"

**Possible Causes:**
1. Database service is not running (check Render Dashboard)
2. Hostname is incorrect
3. Port is incorrect (Render uses default 5432)
4. Firewall/network issue

**Solution:**
- Verify database service status in Render Dashboard
- Check hostname matches Render dashboard exactly
- Verify `DATABASE_URL` format is correct

### Error: "Authentication failed"

**Possible Causes:**
1. Username is incorrect
2. Password is incorrect
3. User doesn't have access to the database

**Solution:**
- Verify credentials in Render Dashboard → Database → Connection Info
- Reset password if needed
- Ensure user has proper permissions

### Error: "Database does not exist"

**Possible Causes:**
1. Database name is incorrect
2. Database hasn't been created

**Solution:**
- Verify database name in Render Dashboard
- Check that database service is fully provisioned
- Run migrations to create tables

---

## Environment Variables Checklist

### Required for Production (Render)

- [ ] `DATABASE_URL` is set
- [ ] `DATABASE_URL` includes `?sslmode=require`
- [ ] `DATABASE_URL` has correct hostname (full Render hostname)
- [ ] `DATABASE_URL` has correct database name
- [ ] `DATABASE_URL` has correct username and password
- [ ] `RAILS_ENV=production` is set

### Required for Local Development

- [ ] `DB_HOST` is set (or defaults to `localhost`)
- [ ] `DB_PORT` is set (or defaults to `5432`)
- [ ] `DB_USERNAME` is set (or defaults to `postgres`)
- [ ] `DB_PASSWORD` is set (your PostgreSQL password)
- [ ] PostgreSQL service is running locally

---

## Verification Steps

### 1. Check Environment Variable

In Render Dashboard → Your Web Service → Environment:
- Verify `DATABASE_URL` exists
- Verify it includes `?sslmode=require`
- Copy the value and verify format

### 2. Check Database Service

In Render Dashboard → Your Database Service:
- Status should be "Available"
- Note the connection info (hostname, database name)
- Verify it matches your `DATABASE_URL`

### 3. Test Connection

Use the health endpoint or Rails console to test:
```bash
curl https://your-service.onrender.com/health
```

### 4. Check Logs

In Render Dashboard → Your Web Service → Logs:
- Look for database connection errors
- Check for SSL-related errors
- Verify connection success messages

---

## Quick Fixes

### Fix 1: Add SSL Mode to DATABASE_URL

If your `DATABASE_URL` is missing SSL:

1. Go to Render Dashboard → Environment Variables
2. Find `DATABASE_URL`
3. Add `?sslmode=require` to the end:
   ```
   # Before
   postgresql://user:pass@host/db
   
   # After
   postgresql://user:pass@host/db?sslmode=require
   ```
4. Save and redeploy

### Fix 2: Verify Database Service is Running

1. Go to Render Dashboard → Database Service
2. Check status is "Available"
3. If not, wait for it to start or check for errors

### Fix 3: Reset Database Password

1. Go to Render Dashboard → Database Service → Settings
2. Reset password
3. Update `DATABASE_URL` with new password
4. Redeploy web service

---

## Related Documentation

- [Database Schema](./SCHEMA.md) - Complete database schema documentation
- [Migrations](./MIGRATIONS.md) - Running and managing migrations
- [Troubleshooting](./TROUBLESHOOTING.md) - Common database issues

---

*Last Updated: 2025-01-27 - Fixed SSL requirement documentation*

