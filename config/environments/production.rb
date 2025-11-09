require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  # Note: Rails 8 removed asset pipeline by default, so config.assets is not available
  # If you need asset compilation, add sprockets-rails gem and configure it
  config.active_storage.variant_processor = :mini_magick
  config.active_storage.service = :production
  config.action_controller.perform_caching = true
  # Use Redis cache if available, otherwise fall back to memory store
  if ENV["REDIS_URL"].present?
    config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
  else
    config.cache_store = :memory_store, { size: 64 * 1024 * 1024 } # 64 MB in bytes
  end
  config.action_mailer.perform_caching = false
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.log_tags = [ :request_id ]
  config.action_mailer.perform_deliveries = true
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
end
