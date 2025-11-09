# Rails Database Configuration - Official Documentation Reference

**Last Updated:** 2025-11-09

---

## Official Rails Documentation

### Database Configuration
- **Rails Guides - Database Configuration:** https://guides.rubyonrails.org/configuring.html#configuring-a-database
- **Rails Guides - Active Record:** https://guides.rubyonrails.org/active_record_basics.html
- **Rails API - ActiveRecord::Base:** https://api.rubyonrails.org/classes/ActiveRecord/Base.html

### Environment Variables
- **Rails Guides - Environment Variables:** https://guides.rubyonrails.org/configuring.html#environment-variables
- **Rails Guides - Rails on Rack:** https://guides.rubyonrails.org/rails_on_rack.html

---

## DATABASE_URL Configuration

### How Rails Uses DATABASE_URL

Rails automatically uses the `DATABASE_URL` environment variable if present. This is the standard way to configure database connections in production environments.

**Official Rails Behavior:**
1. Rails checks for `DATABASE_URL` environment variable
2. If present, Rails uses it directly (ignoring other database.yml settings)
3. The URL format: `postgresql://username:password@host:port/database`
4. Additional parameters can be added as query strings: `?sslmode=require`

### Our Implementation

In `config/database.yml`, we use ERB to automatically add SSL mode:

```yaml
production:
  <% if ENV["DATABASE_URL"].present? %>
  <% 
    db_url = ENV["DATABASE_URL"]
    # Add sslmode=require if not already present (Render PostgreSQL requires SSL)
    unless db_url.include?('sslmode=') || db_url.include?('ssl=true')
      db_url += (db_url.include?('?') ? '&' : '?') + 'sslmode=require'
    end
  %>
  url: <%= db_url %>
  <% end %>
```

**Why This Works:**
- ERB is evaluated when Rails loads `database.yml`
- This happens at application boot time
- The modified URL is used for all database connections
- This is the **Rails way** - configuration in `database.yml`, not shell scripts

---

## PostgreSQL SSL Configuration

### PostgreSQL SSL Modes

From PostgreSQL official documentation: https://www.postgresql.org/docs/current/libpq-ssl.html

**SSL Modes:**
- `sslmode=disable` - No SSL
- `sslmode=allow` - Try non-SSL first, fallback to SSL
- `sslmode=prefer` - Try SSL first, fallback to non-SSL
- `sslmode=require` - **Require SSL** (use this for Render)
- `sslmode=verify-ca` - Require SSL + verify CA
- `sslmode=verify-full` - Require SSL + verify CA + hostname

**For Render PostgreSQL:**
- Render **requires** SSL connections
- Use `sslmode=require` (no certificate verification needed)
- Can also use `ssl=true` (Render-specific format)

---

## Rails Database Configuration Best Practices

### 1. Use DATABASE_URL in Production

**Official Rails Recommendation:**
- Use `DATABASE_URL` for production deployments
- Keeps credentials out of version control
- Standard across hosting platforms (Heroku, Render, etc.)

### 2. Use ERB in database.yml

**Rails allows ERB in database.yml:**
- Process environment variables
- Modify connection strings
- Add conditional logic
- This is evaluated at boot time

### 3. Fallback Configuration

Always provide fallback configuration:

```yaml
production:
  <% if ENV["DATABASE_URL"].present? %>
  url: <%= ENV["DATABASE_URL"] %>
  <% else %>
  # Fallback to individual parameters
  host: <%= ENV["DATABASE_HOST"] %>
  database: <%= ENV["DATABASE_NAME"] %>
  # ...
  <% end %>
```

---

## Render.com Specific Configuration

### Render PostgreSQL Requirements

**Render Documentation:**
- https://render.com/docs/postgresql-creating-connecting
- Render PostgreSQL **requires SSL** for all connections
- `DATABASE_URL` is auto-injected when database is linked
- Must include `?sslmode=require` or `?ssl=true`

### Our Solution

We automatically add `sslmode=require` in `database.yml` ERB:

```ruby
unless db_url.include?('sslmode=') || db_url.include?('ssl=true')
  db_url += (db_url.include?('?') ? '&' : '?') + 'sslmode=require'
end
```

**Benefits:**
- Works even if Render doesn't include SSL in DATABASE_URL
- No manual configuration needed
- Follows Rails best practices
- Handles both `sslmode=require` and `ssl=true` formats

---

## References

### Rails Official Documentation
- **Rails Guides:** https://guides.rubyonrails.org/
- **Rails API:** https://api.rubyonrails.org/
- **Database Configuration:** https://guides.rubyonrails.org/configuring.html#configuring-a-database

### PostgreSQL Documentation
- **PostgreSQL SSL:** https://www.postgresql.org/docs/current/libpq-ssl.html
- **Connection Strings:** https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING

### Render Documentation
- **PostgreSQL:** https://render.com/docs/postgresql-creating-connecting
- **Environment Variables:** https://render.com/docs/environment-variables

---

## Related Files

- `config/database.yml` - Database configuration with ERB
- `docs/database/CONNECTION.md` - Connection troubleshooting
- `docs/database/TROUBLESHOOTING.md` - Common issues and solutions

---

**Key Takeaway:** Rails evaluates `database.yml` ERB at boot time, making it the perfect place to modify `DATABASE_URL` for SSL requirements. This is the official Rails way to handle environment-specific database configuration.

