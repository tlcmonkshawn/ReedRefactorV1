# Firestore Setup Controller
# Replaces migrations controller - Firestore doesn't need migrations
# This controller helps with initial setup and seeding

class MigrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Simple password protection
  before_action :authenticate_migration_request

  # POST /migrations/run
  # Run Firestore setup tasks (seeding, etc.)
  def run
    begin
      output = []
      errors = []

      # Run Firestore seed task
      begin
        Rake::Task['firestore:seed'].invoke
        Rake::Task['firestore:seed'].reenable
        output << "Firestore seeding completed"
      rescue => e
        errors << "Seed error: #{e.message}"
        output << "Seed error: #{e.message}"
      end

      # Check collections
      collections_status = {}
      begin
        collections_status[:users] = User.all(limit: 1).count > 0
        collections_status[:locations] = Location.all(limit: 1).count > 0
        collections_status[:prompts] = Prompt.all(limit: 1).count > 0
      rescue => e
        errors << "Collection check error: #{e.message}"
      end

      render json: {
        status: errors.any? ? 'partial' : 'success',
        message: errors.any? ? 'Setup completed with errors' : 'Setup completed',
        errors: errors,
        collections_status: collections_status,
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

  # GET /migrations/status
  # Get Firestore setup status
  def status
    begin
      collections_info = {}
      
      begin
        collections_info[:users] = { count: User.count, exists: true }
      rescue => e
        collections_info[:users] = { exists: false, error: e.message }
      end

      begin
        collections_info[:locations] = { count: Location.count, exists: true }
      rescue => e
        collections_info[:locations] = { exists: false, error: e.message }
      end

      begin
        collections_info[:prompts] = { count: Prompt.count, exists: true }
      rescue => e
        collections_info[:prompts] = { exists: false, error: e.message }
      end

      render json: {
        status: 'ok',
        firestore_ready: true,
        collections: collections_info,
        note: 'Firestore collections are created automatically on first write'
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
