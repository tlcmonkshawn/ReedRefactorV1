require_relative "boot"

require "rails"
# Remove ActiveRecord since we're using Firestore
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BootieHunter
  class Application < Rails::Application
    config.load_defaults 7.1

    # API mode configuration
    config.api_only = false # Full Rails, not API-only (for admin interface)

    # CORS configuration is handled in config/initializers/cors.rb

    # Timezone
    config.time_zone = 'UTC'

    # Generators
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end
