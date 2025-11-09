# One-time migration controller
# WARNING: This should be disabled in production after migrations are run
# This is a workaround when shell access isn't available
require 'stringio'

class MigrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Simple password protection
  before_action :authenticate_migration_request

  def run
    begin
      # Check current migration status
      if ActiveRecord::Base.connection.table_exists?('schema_migrations')
        current_versions = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations").map { |r| r['version'] }
      else
        current_versions = []
      end

      # Run migrations using rake task directly
      output = []
      errors = []
      Dir.chdir(Rails.root) do
        # Load Rails tasks first
        Rails.application.load_tasks
        
        begin
          # Run the migrate task with better error handling
          Rake::Task['db:migrate'].invoke
          Rake::Task['db:migrate'].reenable
          output = ["Migrations completed via Rake task"]
        rescue => e
          errors << "#{e.class.name}: #{e.message}"
          output = ["Migration error: #{e.message}"]
        end
      end
      
      # Check which tables actually exist after migration
      existing_tables = ActiveRecord::Base.connection.tables.sort
      critical_tables = ['users', 'prompts', 'locations']
      missing_critical = critical_tables.reject { |t| existing_tables.include?(t) }

      # Get new migration status
      if ActiveRecord::Base.connection.table_exists?('schema_migrations')
        new_versions = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations").map { |r| r['version'] }
      else
        new_versions = []
      end

      render json: {
        status: errors.any? ? 'partial' : 'success',
        message: errors.any? ? 'Migrations completed with errors' : 'Migrations completed',
        migrations_before: current_versions.length,
        migrations_after: new_versions.length,
        new_migrations: new_versions - current_versions,
        errors: errors,
        tables_exist: existing_tables,
        missing_critical_tables: missing_critical,
        users_exists: existing_tables.include?('users'),
        prompts_exists: existing_tables.include?('prompts'),
        locations_exists: existing_tables.include?('locations'),
        output: output.last(20) # Last 20 lines of output
      }
    rescue => e
      render json: {
        status: 'error',
        error: e.class.name,
        message: e.message,
        backtrace: Rails.env.development? ? e.backtrace.first(10) : nil
      }, status: :internal_server_error
    end
  end

  def status
    begin
      migrations_path = Rails.root.join('db', 'migrate').to_s

      # Get tables using raw SQL - this is the truth
      begin
        raw_tables_query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name"
        raw_result = ActiveRecord::Base.connection.execute(raw_tables_query)
        # PostgreSQL returns results as PG::Result, convert to array of table names
        raw_tables = raw_result.values.flatten.sort
      rescue => e
        # Fallback to Rails method if SQL fails
        raw_tables = ActiveRecord::Base.connection.tables.sort
      end
      
      # Also get Rails' view of tables
      rails_tables = ActiveRecord::Base.connection.tables.sort

      if ActiveRecord::Base.connection.table_exists?('schema_migrations')
        versions = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version").map { |r| r['version'] }
        pending = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations(migrations_path), ActiveRecord::Base.connection.schema_migration).pending_migrations.map(&:version)
      else
        versions = []
        all_migrations = ActiveRecord::Migrator.migrations(migrations_path)
        pending = all_migrations.map(&:version)
      end

      expected_tables = ['users', 'locations', 'booties', 'research_logs', 'grounding_sources', 
                        'conversations', 'messages', 'leaderboards', 'scores', 'achievements', 
                        'user_achievements', 'game_sessions', 'prompts', 'schema_migrations', 'ar_internal_metadata']
      missing_tables = expected_tables - raw_tables

      render json: {
        status: 'ok',
        migrations_run: versions.length,
        migrations_pending: pending.length,
        versions: versions,
        pending_versions: pending.map(&:to_s),
        # Raw SQL query - this is what actually exists
        tables_from_sql: raw_tables,
        # Rails' view (might be wrong)
        tables_from_rails: rails_tables,
        expected_tables: expected_tables,
        missing_tables: missing_tables,
        users_table_exists: raw_tables.include?('users'),
        prompts_table_exists: raw_tables.include?('prompts'),
        locations_table_exists: raw_tables.include?('locations')
      }
    rescue => e
      render json: {
        status: 'error',
        error: e.class.name,
        message: e.message,
        backtrace: Rails.env.development? ? e.backtrace.first(10) : nil
      }, status: :internal_server_error
    end
  end

  def export_locations
    begin
      locations = Location.all.map do |loc|
        {
          name: loc.name,
          address: loc.address,
          city: loc.city,
          state: loc.state,
          zip_code: loc.zip_code,
          phone_number: loc.phone_number,
          email: loc.email,
          latitude: loc.latitude&.to_f,
          longitude: loc.longitude&.to_f,
          notes: loc.notes,
          active: loc.active
        }
      end
      
      # Return locations as an array for easier restoration
      render json: locations
    rescue => e
      render json: {
        status: 'error',
        error: e.class.name,
        message: e.message
      }, status: :internal_server_error
    end
  end

  def restore_locations
    begin
      # Handle both array and hash formats
      locations_data = if params[:locations].is_a?(Array)
                        params[:locations]
                      elsif params[:locations].is_a?(Hash) && params[:locations].has_key?('locations')
                        params[:locations]['locations']
                      else
                        []
                      end
      
      restored_count = 0
      errors = []
      
      locations_data.each do |loc_data|
        begin
          # Convert hash keys to symbols if needed, or use string keys
          loc_hash = loc_data.is_a?(Hash) ? loc_data : loc_data.to_h
          
          Location.create!(
            name: loc_hash['name'] || loc_hash[:name],
            address: loc_hash['address'] || loc_hash[:address],
            city: loc_hash['city'] || loc_hash[:city],
            state: loc_hash['state'] || loc_hash[:state],
            zip_code: loc_hash['zip_code'] || loc_hash[:zip_code],
            phone_number: loc_hash['phone_number'] || loc_hash[:phone_number],
            email: loc_hash['email'] || loc_hash[:email],
            latitude: loc_hash['latitude'] || loc_hash[:latitude],
            longitude: loc_hash['longitude'] || loc_hash[:longitude],
            notes: loc_hash['notes'] || loc_hash[:notes],
            active: (loc_hash['active'] || loc_hash[:active]) != false # default to true if not specified
          )
          restored_count += 1
        rescue => e
          errors << "Failed to restore #{loc_hash['name'] || loc_hash[:name] || 'unknown'}: #{e.message}"
        end
      end
      
      render json: {
        status: 'success',
        restored: restored_count,
        total: locations_data.length,
        errors: errors
      }
    rescue => e
      render json: {
        status: 'error',
        error: e.class.name,
        message: e.message
      }, status: :internal_server_error
    end
  end

  def schema_load
    begin
      # Load schema directly from schema.rb (destructive - drops all tables first)
      output = []
      errors = []
      
      Dir.chdir(Rails.root) do
        Rails.application.load_tasks
        
        begin
          # First, drop all tables if they exist (destructive!)
          ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
          
          # Get list of tables before dropping
          tables_before = ActiveRecord::Base.connection.tables.sort
          output << "Tables before drop: #{tables_before.join(', ')}"
          
          # Drop all tables including schema_migrations (so migrations will run fresh)
          ActiveRecord::Base.connection.tables.each do |table|
            next if table == 'ar_internal_metadata'
            begin
              ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS #{table} CASCADE")
              output << "Dropped table: #{table}"
            rescue => e
              errors << "Failed to drop #{table}: #{e.message}"
            end
          end
          
          # Verify tables are dropped
          tables_after_drop = ActiveRecord::Base.connection.tables.sort
          output << "Tables after drop: #{tables_after_drop.join(', ')}"
          
          # Now run all migrations from scratch with detailed output
          output << "Starting migrations..."
          
          # Capture migration output
          original_stdout = $stdout
          migration_output = StringIO.new
          $stdout = migration_output
          
          begin
            # Get list of migration files
            migrations_path = Rails.root.join('db', 'migrate')
            migration_files = Dir.glob(migrations_path.join('*.rb')).sort
            output << "Found #{migration_files.length} migration files"
            output << "Migration files: #{migration_files.map { |f| File.basename(f) }.join(', ')}"
            
            Rake::Task['db:migrate'].invoke
            Rake::Task['db:migrate'].reenable
            migration_output.rewind
            migration_lines = migration_output.read.split("\n")
            output.concat(migration_lines.reject(&:blank?))
            output << "Migrations completed"
            
            # Check what migrations actually ran
            if ActiveRecord::Base.connection.table_exists?('schema_migrations')
              ran_versions = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version").map { |r| r['version'] }
              output << "Migrations that ran: #{ran_versions.join(', ')}"
            end
            
            # If users table still doesn't exist, try to create it manually
            unless ActiveRecord::Base.connection.table_exists?('users')
              output << "WARNING: Users table still missing after migrations, attempting manual creation..."
              begin
                # Read and execute the users migration SQL manually
                users_migration_file = Rails.root.join('db', 'migrate', '20250101000001_create_users.rb')
                if File.exist?(users_migration_file)
                  load users_migration_file
                  CreateUsers.new.change
                  output << "Manually created users table from migration file"
                else
                  output << "Users migration file not found at #{users_migration_file}"
                end
              rescue => e
                errors << "Failed to manually create users table: #{e.message}"
                output << "Manual users table creation failed: #{e.message}"
              end
            end
          rescue => e
            migration_output.rewind
            migration_lines = migration_output.read.split("\n")
            output.concat(migration_lines.reject(&:blank?))
            errors << "Migration error: #{e.class.name}: #{e.message}"
            errors.concat(e.backtrace.first(5))
            raise
          ensure
            $stdout = original_stdout
          end
          
          # Verify tables were created
          tables_after_migrate = ActiveRecord::Base.connection.tables.sort
          output << "Tables after migrate: #{tables_after_migrate.join(', ')}"
          
          # Check if critical tables exist
          missing = ['users', 'prompts', 'locations'] - tables_after_migrate
          if missing.any?
            errors << "Missing tables after migration: #{missing.join(', ')}"
          end
          
        rescue => e
          errors << "Schema rebuild error: #{e.class.name}: #{e.message}"
          errors.concat(e.backtrace.first(10))
        ensure
          ENV.delete('DISABLE_DATABASE_ENVIRONMENT_CHECK')
        end
        
        # Seed prompts from AI_PROMPTS.json
        begin
          prompts_seed_file = Rails.root.join('db', 'seeds', 'prompts_seed.rb')
          prompts_json_file = Rails.root.join('..', 'AI_PROMPTS.json')
          
          if File.exist?(prompts_seed_file) && File.exist?(prompts_json_file)
            # Temporarily redefine the seed_prompts function to use correct path
            load prompts_seed_file
            seed_prompts
            output << "Prompts seeded from AI_PROMPTS.json"
          elsif !File.exist?(prompts_seed_file)
            errors << "Prompts seed file not found at #{prompts_seed_file}"
          elsif !File.exist?(prompts_json_file)
            errors << "AI_PROMPTS.json not found at #{prompts_json_file}"
          end
        rescue => e
          errors << "Prompt seeding error: #{e.message}"
          errors << e.backtrace.first(3).join("\n") if Rails.env.development?
        end
      end
      
      # Check which tables exist after schema load
      existing_tables = ActiveRecord::Base.connection.tables.sort
      critical_tables = ['users', 'prompts', 'locations']
      missing_critical = critical_tables.reject { |t| existing_tables.include?(t) }
      
      # Count prompts
      prompts_count = 0
      if existing_tables.include?('prompts')
        prompts_count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM prompts").first['count'].to_i
      end
      
      render json: {
        status: errors.any? ? 'partial' : 'success',
        message: errors.any? ? 'Schema loaded with some errors' : 'Schema loaded and prompts seeded',
        tables_exist: existing_tables,
        missing_critical_tables: missing_critical,
        users_exists: existing_tables.include?('users'),
        prompts_exists: existing_tables.include?('prompts'),
        prompts_count: prompts_count,
        locations_exists: existing_tables.include?('locations'),
        errors: errors,
        output: output
      }
    rescue => e
      render json: {
        status: 'error',
        error: e.class.name,
        message: e.message,
        backtrace: Rails.env.development? ? e.backtrace.first(10) : nil
      }, status: :internal_server_error
    end
  end

  private

  def authenticate_migration_request
    # Simple password check - use ADMIN_PASSWORD from env
    provided_password = request.headers['X-Migration-Password'] || params[:password]
    expected_password = ENV['ADMIN_PASSWORD'] || 'iamagoodgirl'

    unless provided_password == expected_password
      render json: {
        error: 'Unauthorized',
        message: 'Provide X-Migration-Password header or password param'
      }, status: :unauthorized
    end
  end
end
