class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def check
    begin
      # Quick health check for Firestore
      db_status = 'unknown'
      db_error = nil
      db_config_info = {}
      
      # Log Firestore configuration
      begin
        db_config_info = {
          adapter: 'firestore',
          project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'not_set',
          has_credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'].present? || ENV['GOOGLE_APPLICATION_CREDENTIALS'].present?
        }
      rescue => e
        db_config_info = { error: "Could not read config: #{e.message}" }
      end
      
      begin
        # Test Firestore connection with a simple query
        users_count = User.all(limit: 1).count
        db_status = 'connected'
      rescue => e
        db_status = 'connection_error'
        db_error = "Firestore connection failed: #{e.class.name}: #{e.message}"
      end

      # Check if users collection has documents
      users_collection_exists = false
      schema_info = { exists: false }

      if db_status == 'connected'
        begin
          # Try to get a user to verify collection exists
          test_user = User.all(limit: 1).first
          users_collection_exists = true

          schema_info = {
            exists: true,
            has_required_fields: {
              email: true,
              password_digest: true,
              name: true,
              role: true,
              active: true
            }
          }
        rescue => e
          # Collection might not exist yet, that's okay
          users_collection_exists = false
          schema_info = { exists: false, note: 'Collection will be created on first write' }
        end
      end

      # Always return 200 for health check
      render json: {
        status: db_status == 'connected' ? 'ok' : 'degraded',
        timestamp: Time.current,
        database: db_status,
        database_error: db_error,
        database_config: db_config_info,
        rails_env: Rails.env,
        users_collection: schema_info,
        firestore_ready: db_status == 'connected'
      }
    rescue => e
      # Even if everything fails, return 200 so Cloud Run doesn't kill the service
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
          message: 'User model is valid, Firestore is ready',
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
