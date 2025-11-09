#!/bin/bash
# Render startup script - runs migrations then starts the server
# This ensures migrations run AFTER build but BEFORE server starts
# Database is guaranteed to be available at this point
# Based on working Bootie Hunter V1 implementation

set -e  # Exit immediately if any command fails

echo "=== Starting Render deployment ==="
echo "RAILS_ENV: ${RAILS_ENV:-production}"
echo "Working directory: $(pwd)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL is not set!"
  echo "   This usually means the database is not linked to the service."
  echo "   Please link the database in the Render dashboard:"
  echo "   1. Go to service settings"
  echo "   2. Navigate to 'Linked Databases' or 'Database' section"
  echo "   3. Link the database to this service"
  exit 1
else
  echo "✅ DATABASE_URL is set (length: ${#DATABASE_URL} chars)"
  echo "   First 30 chars: ${DATABASE_URL:0:30}..."
  
  # Ensure SSL mode is set for Render PostgreSQL (matches Bootie Hunter V1)
  # Database REQUIRES SSL - only set sslmode=require (no certificate parameters needed)
  if [[ "$DATABASE_URL" != *"sslmode"* ]]; then
    separator="?"
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      separator="&"
    fi
    # Add sslmode=require - Render PostgreSQL requires SSL
    export DATABASE_URL="${DATABASE_URL}${separator}sslmode=require"
    echo "   Added sslmode=require to DATABASE_URL (database requires SSL)"
  else
    # Ensure sslmode is set to 'require' (database requires SSL)
    export DATABASE_URL="${DATABASE_URL//sslmode=prefer/sslmode=require}"
    export DATABASE_URL="${DATABASE_URL//sslmode=prefer&/sslmode=require&}"
    export DATABASE_URL="${DATABASE_URL//&sslmode=prefer/&sslmode=require}"
    echo "   Ensured sslmode=require in DATABASE_URL"
  fi
  
  # Export DATABASE_URL so it's available to all child processes
  export DATABASE_URL
fi

# Test database connection before running migrations
echo ""
echo "Testing database connection..."
if RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" > /dev/null 2>&1; then
  echo "✅ Database connection successful"
else
  echo "❌ Database connection failed!"
  echo "   Attempting connection test with verbose output..."
  RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>&1 || true
  exit 1
fi

# Check current migration status
echo ""
echo "Checking current migration status..."
if RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.table_exists?('schema_migrations')" 2>/dev/null | grep -q "true"; then
  CURRENT_MIGRATIONS=$(RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.execute(\"SELECT COUNT(*) FROM schema_migrations\").first['count']" 2>/dev/null || echo "0")
  echo "   Current migrations in database: $CURRENT_MIGRATIONS"
else
  echo "   No schema_migrations table found - database is empty"
  CURRENT_MIGRATIONS=0
fi

# Count migration files
MIGRATION_FILES=$(find db/migrate -name "*.rb" 2>/dev/null | wc -l || echo "0")
echo "   Migration files found: $MIGRATION_FILES"

# Ensure we're in the Rails root
if [ ! -f "config/application.rb" ]; then
  echo "❌ Not in Rails root! Current directory: $(pwd)"
  exit 1
fi

echo "✅ In Rails root directory: $(pwd)"

# Run migrations - use rake db:migrate directly (more reliable than rails runner)
echo ""
echo "Running database migrations..."
echo "Using DATABASE_URL: ${DATABASE_URL:0:30}..."
echo "Full DATABASE_URL (masked): $(echo $DATABASE_URL | sed 's/:[^:@]*@/:****@/')"
set +e  # Temporarily disable exit on error to capture exit code

# Ensure DATABASE_URL is exported and available
export DATABASE_URL

# Run migrations directly using rake - explicitly pass DATABASE_URL in the environment
# This ensures the modified DATABASE_URL with SSL is used
env DATABASE_URL="$DATABASE_URL" RAILS_ENV=production timeout 120 bundle exec rake db:migrate 2>&1
MIGRATE_EXIT=$?

set -e  # Re-enable exit on error

# Check migration exit code
if [ $MIGRATE_EXIT -ne 0 ]; then
  echo ""
  echo "❌ Migration failed with exit code $MIGRATE_EXIT"
  echo "Attempting alternative: rails runner with migration script..."
  set +e
  RAILS_ENV=production DATABASE_URL="$DATABASE_URL" timeout 120 bundle exec rails runner "load Rails.root.join('lib', 'tasks', 'run_migrations.rb')" 2>&1
  MIGRATE_EXIT=$?
  set -e
  if [ $MIGRATE_EXIT -ne 0 ]; then
    echo ""
    echo "❌ Both migration methods failed with exit code $MIGRATE_EXIT"
    exit 1
  fi
fi

# Verify migrations ran
echo ""
echo "Verifying migrations..."
if RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.table_exists?('schema_migrations')" 2>/dev/null | grep -q "true"; then
  MIGRATION_COUNT=$(RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.execute(\"SELECT COUNT(*) FROM schema_migrations\").first['count']" 2>/dev/null || echo "0")
  echo "✅ Migrations in database: $MIGRATION_COUNT"
  
  if [ "$MIGRATION_COUNT" -gt "$CURRENT_MIGRATIONS" ]; then
    echo "✅ New migrations were applied ($CURRENT_MIGRATIONS -> $MIGRATION_COUNT)"
  elif [ "$MIGRATION_COUNT" -eq "$CURRENT_MIGRATIONS" ] && [ "$CURRENT_MIGRATIONS" -gt 0 ]; then
    echo "ℹ️  No new migrations to run (already at $MIGRATION_COUNT)"
  fi
else
  echo "❌ schema_migrations table does not exist after migration attempt"
  MIGRATION_COUNT=0
fi

# Check if users table exists
echo ""
echo "Checking critical tables..."
if RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.table_exists?('users')" 2>/dev/null | grep -q "true"; then
  echo "✅ Users table exists"
else
  echo "❌ Users table does NOT exist - migrations may have failed"
  echo "Migration count: $MIGRATION_COUNT"
  echo "Expected migrations: $MIGRATION_FILES"
  
  # List all tables that do exist
  echo ""
  echo "Tables that exist:"
  RAILS_ENV=production DATABASE_URL="$DATABASE_URL" bundle exec rails runner "puts ActiveRecord::Base.connection.tables.sort.join(', ')" 2>/dev/null || echo "Could not list tables"
  
  exit 1
fi

# Start the server
echo ""
echo "✅ All checks passed. Starting Puma server..."
exec bundle exec puma -C config/puma.rb

