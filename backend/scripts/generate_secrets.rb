#!/usr/bin/env ruby
# Script to generate secure secrets for Rails application
# Usage: ruby scripts/generate_secrets.rb

require 'securerandom'

puts "=" * 60
puts "BootieHunter V1 - Secret Generation"
puts "=" * 60
puts

# Generate Rails secret key base
rails_secret = SecureRandom.hex(64)
puts "SECRET_KEY_BASE=#{rails_secret}"
puts

# Generate JWT secret key (32+ characters)
jwt_secret = SecureRandom.hex(32)
puts "JWT_SECRET_KEY=#{jwt_secret}"
puts

puts "=" * 60
puts "Copy these values to your .env file"
puts "=" * 60
puts
puts "Note: You can also generate Rails secret with: rails secret"

