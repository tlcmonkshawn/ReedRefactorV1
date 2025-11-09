source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.0.0'

# Rails framework
gem 'rails', '~> 8.1.0'

# Web Server
gem 'puma', '~> 6.4'

# Database
gem 'pg', '~> 1.5'
gem 'activerecord-postgres_enum', '~> 1.7'

# Authentication & Authorization
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.7'

# API
gem 'rack-cors'
gem 'active_model_serializers'

# Background Jobs
gem 'sidekiq', '~> 7.2'
gem 'redis', '~> 5.0'

# Image Processing
gem 'image_processing', '~> 1.12'
gem 'mini_magick'

# Cloud Storage
gem 'google-cloud-storage', '~> 1.45'

# AI Integration
# Note: Using HTTP client directly for Gemini API (no official gem for Gemini Live yet)
# gem 'google-generative-ai'

# HTTP Client
gem 'faraday', '~> 2.7'
gem 'faraday-retry'

# Environment Variables
gem 'dotenv-rails'

# Admin Interface
gem 'kaminari', '~> 1.2' # Pagination

# Logging & Monitoring
gem 'lograge'

group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 6.2'
  gem 'database_cleaner-active_record'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
end

group :development do
  gem 'listen', '~> 3.9'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1'
end


gem "httparty", "~> 0.23.2", groups: [:development, :test]
