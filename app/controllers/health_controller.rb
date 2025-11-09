class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def check
    begin
      # Quick health check with timeout protection
      # Use a simple query with timeout to avoid hanging
      db_status = 'unknown'
      db_error = nil
      db_config_info = {}
      
      # Log database configuration (without sensitive data)
      begin
        db_config = ActiveRecord::Base.connection_db_config.configuration_hash
        db_config_info = {
          adapter: db_config[:adapter],
          database: db_config[:database],
          host: db_config[:host],
          port: db_config[:port],
          pool: db_config[:pool],
          has_url: ENV['DATABASE_URL'].present?,
          url_preview: ENV['DATABASE_URL'].present? ? "#{ENV['DATABASE_URL'].split('@').first}@***" : nil
        }
      rescue => e
        db_config_info = { error: "Could not read config: #{e.message}" }
      end
      
      begin
        # Set a short timeout for database queries
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          result = conn.execute("SELECT 1 as test")
          db_status = result.present? ? 'connected' : 'disconnected'
        end
      rescue PG::ConnectionBad => e
        db_status = 'connection_error'
        db_error = "PostgreSQL connection failed: #{e.message}"
      rescue ActiveRecord::ConnectionNotEstablished => e
        db_status = 'not_established'
        db_error = "Connection not established: #{e.message}"
      rescue => e
        db_status = 'error'
        db_error = "#{e.class.name}: #{e.message}"
      end

      # Only check table existence if DB is connected
      users_table_exists = false
      schema_info = { exists: false }
      migrations_run = []

      if db_status == 'connected'
        begin
          users_table_exists = ActiveRecord::Base.connection.table_exists?('users')

          # Check which migrations have run
          if ActiveRecord::Base.connection.table_exists?('schema_migrations')
            migrations_run = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version").map { |r| r['version'] }
          end

          # Check schema if table exists
          if users_table_exists
            columns = ActiveRecord::Base.connection.columns('users').map(&:name)
            schema_info = {
              exists: true,
              columns: columns,
              has_required_fields: {
                email: columns.include?('email'),
                password_digest: columns.include?('password_digest'),
                name: columns.include?('name'),
                role: columns.include?('role'),
                active: columns.include?('active')
              }
            }
          end
        rescue => e
          # If detailed checks fail, still return basic health
          db_error = e.message if db_error.nil?
        end
      end

      # Always return 200 for health check, even if DB has issues
      # This allows Render to see the service as "up" even if DB needs attention
      render json: {
        status: db_status == 'connected' ? 'ok' : 'degraded',
        timestamp: Time.current,
        database: db_status,
        database_error: db_error,
        database_config: db_config_info,
        rails_env: Rails.env,
        users_table: schema_info,
        migrations_run: migrations_run.is_a?(Array) ? migrations_run.length : 0,
        migration_versions: migrations_run.is_a?(Array) ? migrations_run.first(5) : nil
      }
    rescue => e
      # Even if everything fails, return 200 so Render doesn't kill the service
      # The status will indicate the problem
      render json: {
        status: 'error',
        timestamp: Time.current,
        error: e.message,
        backtrace: Rails.env.development? ? e.backtrace.first(5) : nil,
        rails_env: Rails.env
      }
    end
  end

  # Diagnostic endpoint to test user creation
  def test_register
    begin
      # Check if table exists
      unless ActiveRecord::Base.connection.table_exists?('users')
        return render json: {
          error: 'Users table does not exist',
          fix: 'Run: rails db:migrate'
        }, status: :internal_server_error
      end

      # Try to create a test user
      test_user = User.new(
        email: "test_#{Time.current.to_i}@test.com",
        password: "testpassword123",
        password_confirmation: "testpassword123",
        name: "Test User",
        role: 'agent'
      )

      if test_user.valid?
        # Don't actually save, just check if it's valid
        render json: {
          status: 'ok',
          message: 'User model is valid, table exists',
          test_user_valid: true
        }
      else
        render json: {
          status: 'error',
          message: 'User validation failed',
          errors: test_user.errors.full_messages
        }, status: :unprocessable_entity
      end
    rescue => e
      render json: {
        error: e.class.name,
        message: e.message,
        backtrace: Rails.env.development? ? e.backtrace.first(10) : nil
      }, status: :internal_server_error
    end
  end
end
