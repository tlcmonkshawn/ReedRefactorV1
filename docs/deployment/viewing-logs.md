# How to View Render Logs

## Where to Find Logs

### Step-by-Step:

1. **Go to Render Dashboard**: https://dashboard.render.com

2. **Click on your web service** (the one that's running Ruby - "REED Bootie Hunter V1-1" or similar)

3. **Click on "Logs" tab** (usually at the top of the service page)

4. **View real-time logs** - You'll see:
   - Build logs (when deploying)
   - Runtime logs (when the app is running)
   - Error messages
   - Stack traces

---

## What to Look For

### For the 500 Error:

Look for lines that contain:
- `Login error:` (from the error handling we added)
- `JwtService`
- `secret_key_base`
- `NoMethodError`
- `ArgumentError`
- `ActiveRecord::` errors
- Stack traces (lines starting with `from` or `#`)

### Example of what you might see:

```
[timestamp] Login error: ArgumentError: Missing `secret_key_base`
[timestamp] from /opt/render/project/src/backend/app/services/jwt_service.rb:9:in `encode'
[timestamp] from /opt/render/project/src/backend/app/controllers/api/v1/auth_controller.rb:40:in `login'
```

---

## Log Types

### 1. **Build Logs**
- Shown during deployment
- Shows `bundle install`, migrations, etc.
- Access: Service → Logs (during build)

### 2. **Runtime Logs**
- Shown when app is running
- Shows HTTP requests, errors, Rails logs
- Access: Service → Logs (when running)

### 3. **Live Logs**
- Real-time streaming
- Updates as requests come in
- Best for debugging current issues

---

## Tips

1. **Filter logs**: Use the search/filter box to find specific errors
2. **Scroll to bottom**: Most recent logs are at the bottom
3. **Look for timestamps**: Match them to when you tried to login
4. **Copy error messages**: You can copy/paste the full error for debugging

---

## Alternative: Check via Render API

You can also view logs programmatically, but the dashboard is easiest.

---

**Quick Path**: Render Dashboard → Your Web Service → "Logs" tab
