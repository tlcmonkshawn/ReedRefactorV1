# R.E.E.D. Bootie Hunter - Deployment Overview

**Status**: ✅ **LIVE**
**Live URL**: https://reed-bootie-hunter-v1-1.onrender.com
**Last Updated**: 2025-01-27

---

## Quick Status

- **Backend**: ✅ Live on Render.com
- **Health Check**: ✅ Responding
- **Database**: ✅ PostgreSQL connected
- **Auto-Deploy**: ✅ Enabled from GitHub `main` branch

**Quick Health Check**:
```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/health
```

---

## Deployment Configuration

### Render.com Services

#### Web Service (Rails Backend)
- **Service Name**: `REED_Bootie_Hunter_V1-1`
- **Service Type**: Web Service (Ruby)
- **Plan**: Free (spins down after inactivity)
- **Root Directory**: `backend`
- **Build Command**: `bundle install && bundle exec rails db:migrate`
- **Start Command**: `bundle exec puma -C config/puma.rb` (from Procfile)
- **Environment**: Production
- **Auto-Deploy**: ✅ Enabled (deploys on push to `main` branch)

#### PostgreSQL Database
- **Service Type**: PostgreSQL
- **Service Name**: `bootiehunter-db`
- **Connection**: Via `DATABASE_URL` environment variable (auto-provided by Render)
- **Status**: ✅ Connected and migrations run successfully

### Critical Files

#### Must Exist
- ✅ `backend/Procfile` - Server startup command
  ```
  web: bundle exec puma -C config/puma.rb
  ```
- ✅ `backend/config/storage.yml` - Active Storage configuration
- ✅ `backend/Gemfile` - Must include `puma` gem
- ✅ `backend/Gemfile.lock` - Must include `x86_64-linux` platform

#### Must NOT Exist in Git
- ❌ `INSTALL_HISTORY.md` - Contains real secrets (in `.gitignore`)
- ❌ `backend/config/service-account-key.json` - Google credentials (in `.gitignore`)
- ❌ `backend/.env` - Environment variables (in `.gitignore`)

---

## Environment Variables

All environment variables are configured in the Render Dashboard. See `render-env-vars.txt` (local only) for reference.

### Required Variables

#### Database
```
DATABASE_URL=postgresql://user:password@host:port/database?sslmode=require
```
- Provided automatically by Render when PostgreSQL service is created
- **⚠️ IMPORTANT**: Must include `?sslmode=require` (Render PostgreSQL requires SSL)
- The `render-start.sh` script automatically adds this if missing, but set it explicitly
- See [Database Connection Guide](../database/CONNECTION.md) for complete details

#### Rails Configuration
```
RAILS_ENV=production
SECRET_KEY_BASE=<128-character-hex-string>
JWT_SECRET_KEY=<64-character-hex-string>
```

#### Google Cloud Platform
```
GOOGLE_CLOUD_PROJECT_ID=bootiehunter-v1-ovunz1
GOOGLE_CLOUD_STORAGE_BUCKET=bootiehunter-v1-images
GEMINI_API_KEY=<your-gemini-api-key>
GOOGLE_APPLICATION_CREDENTIALS_JSON=<entire-json-content-as-single-line>
```

**Important**: `GOOGLE_APPLICATION_CREDENTIALS_JSON` must contain the entire service account JSON as a single line (no line breaks).

#### Admin
```
ADMIN_PASSWORD=<your-admin-password>
```

### Optional Variables

#### Performance Tuning
```
RAILS_MAX_THREADS=5
RAILS_MIN_THREADS=5
WEB_CONCURRENCY=2
```

#### Redis (if using Redis service)
```
REDIS_URL=redis://your-redis-url
```
- If not set, app uses memory store for caching (acceptable for initial deployment)

#### Optional Integrations
```
SQUARE_ACCESS_TOKEN=<optional>
SQUARE_APPLICATION_ID=<optional>
SQUARE_LOCATION_ID=<optional>
DISCOGS_USER_TOKEN=<optional>
```

---

## Production Configuration

### Production Environment (`backend/config/environments/production.rb`)

**Key Features**:
- **Caching**: Uses Redis if `REDIS_URL` is set, otherwise falls back to memory store
- **Logging**: Production-level logging (info level)
- **Static Files**: Served if `RAILS_SERVE_STATIC_FILES` is set
- **Asset Pipeline**: Rails 8 compatible (no asset pipeline by default)
- **Active Storage**: Configured for production service

### Database Configuration

The production database configuration automatically uses `DATABASE_URL` from environment variables:

```ruby
production:
  <<: *default
  database: <%= ENV["DATABASE_URL"].split("/").last if ENV["DATABASE_URL"] %>
  url: <%= ENV["DATABASE_URL"] %>
```

---

## Render MCP Integration

This project uses **Render MCP (Model Context Protocol)** to help manage deployments and services through AI assistants.

### What is Render MCP?

Render MCP provides AI assistants with tools to:
- List and manage Render services
- View deployment logs
- Update environment variables
- Query database metrics
- Monitor service health
- Manage deployments

### Using Render MCP

AI assistants (like Cursor AI) can use Render MCP tools to:
- **Check deployment status**: Query service status and health
- **View logs**: Access build and runtime logs programmatically
- **Update configuration**: Modify environment variables or service settings
- **Monitor metrics**: Check CPU, memory, and request metrics
- **Manage deployments**: Trigger manual deploys or check deploy status

### MCP Tools Available

The Render MCP server provides tools for:
- `list_services` - List all services in your Render account
- `get_service` - Get details about a specific service
- `list_deploys` - View deployment history
- `get_deploy` - Get details about a specific deployment
- `list_logs` - Query service logs with filters
- `update_environment_variables` - Update service environment variables
- `get_metrics` - Get performance metrics for services
- `query_render_postgres` - Run read-only SQL queries on Render databases

### Configuration

Render MCP requires:
- Render API token (configured in MCP server settings)
- Workspace selection (if multiple workspaces exist)

**Note**: MCP tools are used by AI assistants during development and deployment operations. Manual operations can still be performed via the Render Dashboard.

---

## Deployment Process

### Initial Deployment (Completed)

1. ✅ Code pushed to GitHub
2. ✅ Repository connected to Render
3. ✅ Render services created (Web Service + PostgreSQL)
4. ✅ Environment variables configured in Render Dashboard
5. ✅ Auto-deploy enabled on `main` branch
6. ✅ Build process completed successfully
7. ✅ Database migrations ran automatically
8. ✅ Server started successfully

### Ongoing Deployments

**Auto-Deploy**: Enabled - pushes to `main` branch automatically trigger deployment

**Manual Deploy**:
- Render Dashboard → Service → Manual Deploy
- Or trigger via Render API
- Or use Render MCP tools (via AI assistant)

---

## Post-Deployment Verification

### Health Check
```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/health
```
Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-01-27T12:00:00Z"
}
```

### API Endpoint Test
```bash
curl https://reed-bootie-hunter-v1-1.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123","name":"Test User"}}'
```

### Database Connection
- ✅ Migrations ran successfully
- ✅ All tables created
- ✅ Prompts seeded (if seed script configured)

---

## Troubleshooting

### Viewing Logs

#### Method 1: Render Dashboard (Easiest)
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your web service
3. Click on **"Logs"** tab
4. View:
   - **Build Logs** - Issues during `bundle install` and build
   - **Runtime Logs** - Issues after deployment (server errors, crashes)

#### Method 2: Render MCP (Via AI Assistant)
AI assistants can query logs using Render MCP tools:
- Filter by time range, log level, resource, or text search
- Query logs across multiple services
- Programmatic access for debugging

#### Method 3: Render CLI
```bash
# Install Render CLI
npm install -g render-cli

# Login
render login

# View logs
render logs --service your-service-name
```

### Common Issues

#### Build Failures

**Issue**: Build fails during `bundle install`
- **Check**: Gemfile.lock is committed
- **Check**: Ruby version matches Render's Ruby version
- **Check**: Build logs for specific gem errors
- **Fix**: Add `.ruby-version` file to `backend/` directory if needed

**Issue**: Build fails during migrations
- **Check**: `DATABASE_URL` is set correctly
- **Check**: Database service is running
- **Check**: Migration files are valid

#### Runtime Errors

**Issue**: Server won't start
- **Check**: Procfile syntax is correct
- **Check**: All required environment variables are set
- **Check**: Port binding (Render uses `$PORT` environment variable)

**Issue**: Database connection errors
- **Check**: `DATABASE_URL` is correct
- **Check**: Database service is running
- **Check**: Network connectivity between services

**Issue**: Google Cloud authentication errors
- **Check**: `GOOGLE_APPLICATION_CREDENTIALS_JSON` is set correctly
- **Check**: JSON is on a single line (no line breaks)
- **Check**: Service account has correct permissions

#### Service Account Key Format
The service account key must be a single-line JSON string in the `GOOGLE_APPLICATION_CREDENTIALS_JSON` environment variable. Remove all line breaks and escape quotes properly.

#### Redis Optional
If Redis is not configured, the app will use memory store for caching. This is acceptable for initial deployment.

#### Database Migrations
Migrations run automatically during build if configured in Render's build command. They can also be run manually via Render's shell.

### Common Issues Fixed

1. ✅ Platform mismatch (added Linux to Gemfile.lock)
2. ✅ Missing puma gem (added to Gemfile)
3. ✅ Production config errors (fixed megabytes, removed assets)
4. ✅ Missing storage.yml (created Active Storage config)

---

## Monitoring

### Health Monitoring
- **Endpoint**: `/health`
- **Expected Response**: `{"status":"ok","timestamp":"..."}`
- **Use**: Monitor service availability

### Error Tracking
Review logs for:
- Database connection errors
- API key authentication errors
- Missing environment variables
- Runtime exceptions

### Performance
- Free tier services spin down after 15 minutes of inactivity
- First request after spin-down may take 30-60 seconds (cold start)
- Consider upgrading to paid tier for always-on service

---

## Secrets Management

### Production Secrets
- **Location**: Render Dashboard → Environment Variables
- **Never commit**: Secrets should never be in git
- **Reference**: `render-env-vars.txt` (local only, contains real values - DO NOT COMMIT)

### Local Development
- **Location**: `backend/.env` (not in git)
- **Template**: Copy from `.env.example` if available

---

## Deployment History

### 2025-11-05: Initial Deployment
- **Status**: ✅ Live
- **Commit**: `7261dcc` - "fix: add storage.yml for Active Storage, configure for production"
- **Actions**:
  - Created Procfile
  - Added storage.yml
  - Fixed Gemfile.lock platform
  - Configured environment variables
  - Deployed to Render

---

## Related Documentation

- [Project Status](../STATUS.md) - Current project status and deployment info
- [Troubleshooting](./troubleshooting.md) - Detailed troubleshooting guide
- [Viewing Logs](./viewing-logs.md) - How to view and analyze Render logs
- [Architecture](../ARCHITECTURE.md) - System architecture

---

*Last Updated: 2025-01-27*
