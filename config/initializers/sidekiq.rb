# Sidekiq configuration
# Only configure if REDIS_URL is present (optional for production)
if ENV['REDIS_URL'].present?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end
else
  Rails.logger.warn "Sidekiq: REDIS_URL not set, Sidekiq will not be available"
end
