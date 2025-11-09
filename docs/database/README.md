# Database Documentation

**Last Updated:** 2025-01-27

---

## Quick Links

- **[Connection Guide](./CONNECTION.md)** ⚠️ **START HERE** - How to connect to the database (includes SSL requirement)
- **[Schema Documentation](../DATABASE.md)** - Complete database schema and tables
- **[Migrations Guide](./MIGRATIONS.md)** - Running and managing migrations
- **[Troubleshooting](./TROUBLESHOOTING.md)** - Common database issues and solutions

---

## Critical: SSL Requirement

⚠️ **IMPORTANT**: Render PostgreSQL databases **REQUIRE SSL connections**.

Your `DATABASE_URL` must include `?sslmode=require`:

```
postgresql://user:pass@host/db?sslmode=require
```

**See [Connection Guide](./CONNECTION.md) for complete details.**

---

## Database Overview

- **Type**: PostgreSQL
- **Production**: Render.com PostgreSQL (requires SSL)
- **Local Development**: Local PostgreSQL instance
- **Tables**: 13 core tables
- **Migrations**: 13 migration files

---

## Quick Start

### Production (Render)

1. **Verify `DATABASE_URL` includes SSL**:
   ```
   postgresql://user:pass@host/db?sslmode=require
   ```

2. **Check connection**:
   ```bash
   curl https://reed-bootie-hunter-v1-1.onrender.com/health
   ```

3. **Run migrations** (if needed):
   - Automatic via `render-start.sh` on deploy
   - Or manual via HTTP endpoint (see [Migrations Guide](./MIGRATIONS.md))

### Local Development

1. **Set up `.env` file**:
   ```bash
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   ```

2. **Create database**:
   ```bash
   rails db:create
   rails db:migrate
   ```

---

## Related Documentation

- [Deployment Guide](../deployment/overview.md) - Deployment configuration
- [Getting Started](../getting-started/installation.md) - Complete setup guide

---

*For connection issues, see [Connection Guide](./CONNECTION.md) first!*

