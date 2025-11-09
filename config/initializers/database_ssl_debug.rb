# Debug initializer to verify DATABASE_URL SSL configuration
# This will log the actual DATABASE_URL being used (with sensitive parts masked)

if Rails.env.production? && ENV['DATABASE_URL'].present?
  db_url = ENV['DATABASE_URL']
  
  # Check if SSL mode is present
  has_ssl = db_url.include?('sslmode=') || db_url.include?('ssl=true')
  
  # Mask password for logging
  masked_url = db_url.gsub(/:[^:@]+@/, ':****@')
  
  Rails.logger.info "=" * 60
  Rails.logger.info "DATABASE_URL SSL Configuration Check:"
  Rails.logger.info "  Has sslmode or ssl=true: #{has_ssl}"
  Rails.logger.info "  URL (masked): #{masked_url}"
  
  if has_ssl
    Rails.logger.info "  ✅ SSL mode is configured"
  else
    Rails.logger.warn "  ⚠️  SSL mode is MISSING - this will cause connection failures!"
    Rails.logger.warn "  Expected: DATABASE_URL should include ?sslmode=require"
  end
  
  # Also check what Rails actually sees in the connection config
  begin
    db_config = ActiveRecord::Base.connection_db_config
    if db_config.url
      config_url = db_config.url
      config_masked = config_url.gsub(/:[^:@]+@/, ':****@')
      Rails.logger.info "  Rails connection URL (masked): #{config_masked}"
      Rails.logger.info "  Rails URL has sslmode: #{config_url.include?('sslmode=') || config_url.include?('ssl=true')}"
    end
  rescue => e
    Rails.logger.warn "  Could not read Rails connection config: #{e.message}"
  end
  
  Rails.logger.info "=" * 60
end

