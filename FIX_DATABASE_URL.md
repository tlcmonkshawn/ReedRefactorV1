# Fix DATABASE_URL - Direct Solution

**The simplest fix:** Update the `DATABASE_URL` environment variable in Render to include `?sslmode=require`

---

## Current Issue

The `DATABASE_URL` in Render doesn't have `?sslmode=require`, causing SSL connection failures.

---

## Solution: Update DATABASE_URL in Render Dashboard

1. Go to Render Dashboard: https://dashboard.render.com/web/srv-d48g7qchg0os73894stg
2. Click on "Environment" tab
3. Find `DATABASE_URL` environment variable
4. Edit it to add `?sslmode=require` at the end

**Current format (probably):**
```
postgresql://reed_refactor_v1_db_user:SxjuMqAwC8DOmmrwZ6Bm1lfMz2u6g9ZD@dpg-d48g7n4hg0os73894qrg-a.oregon-postgres.render.com:5432/reed_refactor_v1_db
```

**Should be:**
```
postgresql://reed_refactor_v1_db_user:SxjuMqAwC8DOmmrwZ6Bm1lfMz2u6g9ZD@dpg-d48g7n4hg0os73894qrg-a.oregon-postgres.render.com:5432/reed_refactor_v1_db?sslmode=require
```

5. Save the change
6. Service will auto-redeploy

---

## Why This Works

- Direct fix - no code changes needed
- Render will use the updated DATABASE_URL immediately
- No need for initializers or ERB workarounds
- This is the standard way to configure it

---

## Alternative: Use Render MCP

We can also update it programmatically using Render MCP if you prefer.

---

**This is the simplest and most direct solution!** 🎯

