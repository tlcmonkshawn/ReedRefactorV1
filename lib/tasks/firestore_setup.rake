# Firestore Setup Tasks
# Replaces ActiveRecord migrations with Firestore collection initialization

namespace :firestore do
  desc "Initialize Firestore collections and indexes"
  task setup: :environment do
    puts "Setting up Firestore collections..."
    
    # Collections will be created automatically when first document is written
    # This task is mainly for documentation and index creation
    
    puts "Firestore collections will be created automatically on first write."
    puts "To create indexes, use the Firestore console or gcloud commands."
    puts ""
    puts "Required indexes:"
    puts "  - users: email (unique), role, active"
    puts "  - booties: user_id, location_id, status, category"
    puts "  - conversations: user_id, last_message_at"
    puts "  - messages: conversation_id, read"
    puts "  - scores: user_id, bootie_id, game_session_id"
    puts "  - game_sessions: user_id, game_type, status"
    puts "  - leaderboards: period_type, period_date, points"
    puts "  - prompts: category, name, active"
    puts ""
    puts "Setup complete!"
  end

  desc "Seed initial data (prompts, achievements, etc.)"
  task seed: :environment do
    puts "Seeding Firestore with initial data..."
    
    # Seed prompts if seeds file exists
    if File.exist?(Rails.root.join('db', 'seeds', 'prompts_seed.rb'))
      load Rails.root.join('db', 'seeds', 'prompts_seed.rb')
      puts "Prompts seeded."
    end
    
    puts "Seeding complete!"
  end

  desc "Create Firestore indexes (requires gcloud CLI)"
  task create_indexes: :environment do
    puts "Creating Firestore indexes..."
    puts "Note: This requires gcloud CLI and index configuration files."
    puts "See docs/deployment/firestore-indexes.md for manual index creation."
  end
end

