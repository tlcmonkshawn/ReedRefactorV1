#!/usr/bin/env ruby
# Script to check if all required environment variables are set
# Usage: ruby scripts/setup_check.rb

require 'dotenv'

# Load .env file if it exists
Dotenv.load('.env') if File.exist?('.env')

puts "=" * 60
puts "BootieHunter V1 - Setup Verification"
puts "=" * 60
puts

# Phase 1: Essential
puts "PHASE 1: ESSENTIAL (Required to start development)"
puts "-" * 60

phase1_required = [
  { key: 'DB_HOST', description: 'Database host' },
  { key: 'DB_PORT', description: 'Database port' },
  { key: 'DB_USERNAME', description: 'Database username' },
  { key: 'DB_PASSWORD', description: 'Database password' },
  { key: 'SECRET_KEY_BASE', description: 'Rails secret key base' },
  { key: 'JWT_SECRET_KEY', description: 'JWT secret key' },
  { key: 'ADMIN_PASSWORD', description: 'Admin password' },
  { key: 'REDIS_URL', description: 'Redis URL' }
]

phase1_missing = []
phase1_required.each do |item|
  value = ENV[item[:key]]
  if value.nil? || value.empty? || value.include?('your_') || value.include?('here')
    puts "❌ #{item[:key]}: #{item[:description]} - NOT SET"
    phase1_missing << item[:key]
  else
    puts "✅ #{item[:key]}: #{item[:description]} - SET"
  end
end

puts
puts "PHASE 2: CORE FEATURES (Required for MVP)"
puts "-" * 60

phase2_required = [
  { key: 'GEMINI_API_KEY', description: 'Google Gemini API key', critical: true },
  { key: 'GOOGLE_CLOUD_PROJECT_ID', description: 'Google Cloud project ID' },
  { key: 'GOOGLE_CLOUD_STORAGE_BUCKET', description: 'Google Cloud Storage bucket' },
  { key: 'GOOGLE_CLOUD_CREDENTIALS_PATH', description: 'Google Cloud credentials path' },
  { key: 'SQUARE_ACCESS_TOKEN', description: 'Square access token (optional for MVP)' },
  { key: 'DISCOGS_USER_TOKEN', description: 'Discogs token (optional for MVP)' }
]

phase2_missing = []
phase2_required.each do |item|
  value = ENV[item[:key]]
  if value.nil? || value.empty? || value.include?('your_') || value.include?('here')
    status = item[:critical] ? "❌ CRITICAL" : "⚠️  OPTIONAL"
    puts "#{status} #{item[:key]}: #{item[:description]} - NOT SET"
    phase2_missing << item[:key] if item[:critical]
  else
    puts "✅ #{item[:key]}: #{item[:description]} - SET"
  end
end

puts
puts "=" * 60
puts "SUMMARY"
puts "=" * 60

if phase1_missing.empty?
  puts "✅ Phase 1 (Essential): READY"
  puts "   You can start development!"
else
  puts "❌ Phase 1 (Essential): #{phase1_missing.length} missing"
  puts "   Missing: #{phase1_missing.join(', ')}"
end

if phase2_missing.empty?
  puts "✅ Phase 2 (Core Features): READY"
else
  puts "⚠️  Phase 2 (Core Features): #{phase2_missing.length} critical missing"
  puts "   Critical missing: #{phase2_missing.join(', ')}"
end

puts
if phase1_missing.empty? && phase2_missing.empty?
  puts "🎉 All critical requirements are met! You can start development."
else
  puts "📝 Next steps:"
  puts "   1. Copy .env.example to .env"
  puts "   2. Run: ruby scripts/generate_secrets.rb"
  puts "   3. Fill in API keys and credentials"
  puts "   4. See SETUP_REQUIREMENTS.md for detailed instructions"
end
puts "=" * 60

