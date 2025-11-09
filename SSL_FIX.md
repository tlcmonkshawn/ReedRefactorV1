# SSL Connection Fix for Render PostgreSQL

**Issue:** Database connection failing with SSL error  
**Solution:** Ensure `DATABASE_URL` includes `?sslmode=require`

---

## Problem

Render PostgreSQL databases **REQUIRE SSL connections**. The health endpoint showed:
```
SSL connection has been closed unexpectedly
```

This happens when `DATABASE_URL` doesn't include SSL parameters.

---

## Solution

### Option 1: Update DATABASE_URL in Render Dashboard (Recommended)

1. Go to Render Dashboard → `reed-refactor-v1-backend` → Environment
2. Find `DATABASE_URL` environment variable
3. Ensure it ends with `?sslmode=require`

**Format:**
```
postgresql://user:pass@host:port/database?sslmode=require
```

**Example:**
```
postgresql://reed_refactor_v1_db_user:SxjuMqAwC8DOmmrwZ6Bm1lfMz2u6g9ZD@dpg-d48g7n4hg0os73894qrg-a.oregon-postgres.render.com:5432/reed_refactor_v1_db?sslmode=require
```

### Option 2: Use Startup Script (Automatic Fix)

✅ **Already implemented!** The `bin/render-start.sh` script automatically adds `?sslmode=require` if missing.

The `render.yaml` is configured to use this script:
```yaml
startCommand: bash bin/render-start.sh
```

---

## Render Documentation

According to Render's documentation:
- Use `?ssl=true` OR `?sslmode=require` in DATABASE_URL
- Both formats work, but `sslmode=require` is the PostgreSQL standard
- Render PostgreSQL **requires** SSL for all connections

**Source:** 
- Render Community: https://community.render.com/t/ssl-tls-required/1022
- Render Docs: https://render.com/docs/postgresql-creating-connecting

---

## PostgreSQL SSL Modes

From PostgreSQL documentation:
- `sslmode=require` - **Use this for Render** - Requires SSL, doesn't verify certificate
- `sslmode=prefer` - Tries SSL, falls back to non-SSL (won't work with Render)
- `sslmode=allow` - Allows non-SSL (won't work with Render)
- `sslmode=verify-full` - Requires SSL + verifies certificate (not needed for Render)

---

## Testing

After fixing, test the connection:

```powershell
Invoke-WebRequest -Uri https://reed-refactor-v1-backend.onrender.com/health -UseBasicParsing
```

**Expected:**
```json
{
  "status": "ok",
  "database": "connected",
  ...
}
```

---

## Next Steps

1. ✅ Startup script created (auto-fixes SSL)
2. ⏳ Update DATABASE_URL in Render Dashboard (if not already set)
3. ⏳ Service will auto-redeploy
4. ⏳ Test health endpoint
5. ⏳ Run migrations

---

**Status:** Fix implemented - service will auto-fix SSL on next deployment! 🎯

