# Database Troubleshooting Guide

**Last Updated:** 2025-01-27

---

## Quick Diagnosis

### Can't Connect to Database?

1. **Check SSL requirement** - See [Connection Guide](./CONNECTION.md)
2. **Verify `DATABASE_URL`** - Must include `?sslmode=require`
3. **Check database service status** - Render Dashboard → Database Service
4. **Review error messages** - Check Render logs

---

## Common Errors

### Error: "SSL connection required"

**Problem**: `DATABASE_URL` is missing `?sslmode=require`

**Solution**:
1. Go to Render Dashboard → Environment Variables
2. Find `DATABASE_URL`
3. Add `?sslmode=require` to the end:
   ```
   # Wrong
   postgresql://user:pass@host/db
   
   # Correct
   postgresql://user:pass@host/db?sslmode=require
   ```
4. Save and redeploy

**Note**: The `render-start.sh` script automatically adds this, but it's better to set it explicitly.

---

### Error: "Connection refused" or "Could not connect"

**Possible Causes:**
1. Database service is not running
2. Hostname is incorrect
3. Port is incorrect
4. Network/firewall issue

**Solutions:**

1. **Check database service status**:
   - Render Dashboard → Database Service
   - Status should be "Available"
   - If not, wait for it to start or check for errors

2. **Verify hostname**:
   - Must be full Render hostname: `dpg-xxxxx.oregon-postgres.render.com`
   - Check in Render Dashboard → Database → Connection Info

3. **Verify port**:
   - Render uses default PostgreSQL port: `5432`
   - Usually included in `DATABASE_URL` automatically

4. **Check network**:
   - Ensure web service and database are in same region
   - Verify database is linked to web service

---

### Error: "Authentication failed"

**Possible Causes:**
1. Username is incorrect
2. Password is incorrect
3. User doesn't have access

**Solutions:**

1. **Verify credentials**:
   - Render Dashboard → Database → Connection Info
   - Copy exact username and password
   - Update `DATABASE_URL` if needed

2. **Reset password**:
   - Render Dashboard → Database → Settings
   - Reset password
   - Update `DATABASE_URL` with new password
   - Redeploy web service

---

### Error: "Database does not exist"

**Possible Causes:**
1. Database name is incorrect
2. Database hasn't been created

**Solutions:**

1. **Verify database name**:
   - Render Dashboard → Database → Connection Info
   - Default is usually `postgres` or service name
   - Check what database name is in `DATABASE_URL`

2. **Create database** (if needed):
   - Usually created automatically by Render
   - If not, may need to create manually via psql

---

### Error: "Migrations failed" or "Table does not exist"

**Possible Causes:**
1. Migrations didn't run
2. Database connection failed during migration
3. Migration files have errors

**Solutions:**

1. **Check migration status**:
   ```bash
   curl https://reed-bootie-hunter-v1-1.onrender.com/migrations/status
   ```

2. **Run migrations manually**:
   ```bash
   curl -X POST "https://reed-bootie-hunter-v1-1.onrender.com/migrations/run?password=iamagoodgirl"
   ```

3. **Check Render logs**:
   - Look for migration errors
   - Check database connection during migration

4. **Verify database connection**:
   - Test connection first (see [Connection Guide](./CONNECTION.md))
   - Fix connection issues before running migrations

---

## Diagnostic Steps

### Step 1: Check Database Service

1. Go to Render Dashboard → Database Service
2. Verify status is "Available"
3. Note connection info (hostname, database name)

### Step 2: Check Environment Variables

1. Go to Render Dashboard → Web Service → Environment
2. Verify `DATABASE_URL` exists
3. Verify it includes `?sslmode=require`
4. Verify hostname matches database service

### Step 3: Test Connection

```bash
# Health endpoint
curl https://reed-bootie-hunter-v1-1.onrender.com/health

# Should show:
# {
#   "status": "ok",
#   "database": "connected"
# }
```

### Step 4: Check Logs

1. Render Dashboard → Web Service → Logs
2. Look for:
   - Database connection errors
   - SSL-related errors
   - Migration errors
   - Connection success messages

---

## Prevention

### Best Practices

1. **Always include SSL in `DATABASE_URL`**:
   ```
   postgresql://user:pass@host/db?sslmode=require
   ```

2. **Link database to web service**:
   - Render Dashboard → Web Service → Settings
   - Link database (auto-injects `DATABASE_URL`)

3. **Verify before deploying**:
   - Test connection locally first
   - Check environment variables are set
   - Verify database service is running

4. **Monitor logs**:
   - Check build logs for migration errors
   - Check runtime logs for connection errors

---

## Getting Help

If issues persist:

1. **Check all documentation**:
   - [Connection Guide](./CONNECTION.md)
   - [Migrations Guide](./MIGRATIONS.md)
   - [Schema Documentation](../DATABASE.md)

2. **Review Render logs**:
   - Build logs for migration issues
   - Runtime logs for connection issues

3. **Verify configuration**:
   - `DATABASE_URL` format
   - Database service status
   - Environment variables

---

## Related Documentation

- [Connection Guide](./CONNECTION.md) - Complete connection setup
- [Migrations Guide](./MIGRATIONS.md) - Running migrations
- [Schema Documentation](../DATABASE.md) - Database schema

---

*Last Updated: 2025-01-27*

