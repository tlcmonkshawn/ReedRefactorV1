# Fix DATABASE_URL SSL configuration for Render PostgreSQL
# Render PostgreSQL REQUIRES SSL - this initializer ensures sslmode=require is present

if Rails.env.production? && ENV['DATABASE_URL'].present?
  db_url = ENV['DATABASE_URL']
  original_url = db_url.dup
  
  # Check if SSL mode is present
  has_ssl = db_url.include?('sslmode=') || db_url.include?('ssl=true')
  
  # Mask password for logging
  masked_url = db_url.gsub(/:[^:@]+@/, ':****@')
  
  Rails.logger.info "=" * 60
  Rails.logger.info "DATABASE_URL SSL Configuration:"
  Rails.logger.info "  Original URL (masked): #{masked_url}"
  Rails.logger.info "  Has sslmode or ssl=true: #{has_ssl}"
  
  # Fix: Add sslmode=require if missing
  unless has_ssl
    separator = db_url.include?('?') ? '&' : '?'
    db_url += "#{separator}sslmode=require"
    ENV['DATABASE_URL'] = db_url
    
    fixed_masked = db_url.gsub(/:[^:@]+@/, ':****@')
    Rails.logger.warn "  ⚠️  SSL mode was MISSING - FIXED!"
    Rails.logger.info "  Fixed URL (masked): #{fixed_masked}"
    Rails.logger.info "  ✅ Added ?sslmode=require to DATABASE_URL"
  else
    Rails.logger.info "  ✅ SSL mode already configured"
  end
  
  Rails.logger.info "=" * 60
end

