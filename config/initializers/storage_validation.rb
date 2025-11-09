# Storage Configuration Validator
#
# Validates Google Cloud Storage configuration on application startup.
# Logs clear error messages if configuration is missing or invalid.
#
# This runs after Rails initialization to ensure environment variables are loaded.

Rails.application.config.after_initialize do
  begin
    # Only validate in production or if explicitly enabled
    next unless Rails.env.production? || ENV['VALIDATE_STORAGE'] == 'true'

    bucket_name = ENV['GOOGLE_CLOUD_STORAGE_BUCKET']
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID']
    credentials_json = ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON']

    missing = []
    missing << 'GOOGLE_CLOUD_PROJECT_ID' if project_id.blank?
    missing << 'GOOGLE_CLOUD_STORAGE_BUCKET' if bucket_name.blank?
    missing << 'GOOGLE_APPLICATION_CREDENTIALS_JSON' if credentials_json.blank?

    if missing.any?
      Rails.logger.error "=" * 80
      Rails.logger.error "STORAGE CONFIGURATION ERROR"
      Rails.logger.error "=" * 80
      Rails.logger.error "Missing required environment variables: #{missing.join(', ')}"
      Rails.logger.error ""
      Rails.logger.error "Image upload functionality will not work without these variables."
      Rails.logger.error "See docs/storage/SETUP.md for configuration instructions."
      Rails.logger.error "=" * 80
      next
    end

    # Try to parse credentials JSON
    begin
      require 'json'
      credentials_hash = JSON.parse(credentials_json)
      
      # Validate required fields in credentials
      required_fields = ['type', 'project_id', 'private_key', 'client_email']
      missing_fields = required_fields - credentials_hash.keys
      
      if missing_fields.any?
        Rails.logger.error "=" * 80
        Rails.logger.error "STORAGE CREDENTIALS ERROR"
        Rails.logger.error "=" * 80
        Rails.logger.error "GOOGLE_APPLICATION_CREDENTIALS_JSON is missing required fields: #{missing_fields.join(', ')}"
        Rails.logger.error "This should be a complete service account JSON key."
        Rails.logger.error "=" * 80
        next
      end

      # Try to initialize storage client (this will validate credentials)
      require 'google/cloud/storage'
      storage = Google::Cloud::Storage.new(
        project_id: project_id,
        credentials: credentials_hash
      )

      # Try to access bucket (this will validate bucket exists and is accessible)
      bucket = storage.bucket(bucket_name)
      
      if bucket.nil?
        Rails.logger.error "=" * 80
        Rails.logger.error "STORAGE BUCKET ERROR"
        Rails.logger.error "=" * 80
        Rails.logger.error "Bucket '#{bucket_name}' not found or not accessible."
        Rails.logger.error "Please verify:"
        Rails.logger.error "  1. Bucket name is correct"
        Rails.logger.error "  2. Service account has access to the bucket"
        Rails.logger.error "  3. Bucket exists in project '#{project_id}'"
        Rails.logger.error "=" * 80
        next
      end

      Rails.logger.info "✅ Storage configuration validated successfully"
      Rails.logger.info "   Project: #{project_id}"
      Rails.logger.info "   Bucket: #{bucket_name}"
    rescue JSON::ParserError => e
      Rails.logger.error "=" * 80
      Rails.logger.error "STORAGE CREDENTIALS ERROR"
      Rails.logger.error "=" * 80
      Rails.logger.error "GOOGLE_APPLICATION_CREDENTIALS_JSON contains invalid JSON: #{e.message}"
      Rails.logger.error "Please verify the JSON is properly formatted."
      Rails.logger.error "=" * 80
    rescue Google::Cloud::Error => e
      Rails.logger.error "=" * 80
      Rails.logger.error "STORAGE CONNECTION ERROR"
      Rails.logger.error "=" * 80
      Rails.logger.error "Failed to connect to Google Cloud Storage: #{e.message}"
      Rails.logger.error "Please verify:"
      Rails.logger.error "  1. Credentials are correct"
      Rails.logger.error "  2. Service account has proper permissions"
      Rails.logger.error "  3. Network connectivity to Google Cloud"
      Rails.logger.error "=" * 80
    rescue StandardError => e
      Rails.logger.error "=" * 80
      Rails.logger.error "STORAGE VALIDATION ERROR"
      Rails.logger.error "=" * 80
      Rails.logger.error "Unexpected error during storage validation: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      Rails.logger.error "=" * 80
    end
  rescue => e
    # Don't fail startup if validation fails
    Rails.logger.error "Storage validation failed: #{e.message}"
  end
end

