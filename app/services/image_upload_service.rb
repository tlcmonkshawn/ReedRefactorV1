require 'google/cloud/storage'
require 'securerandom'
require 'json'

# ImageUploadService
#
# Handles uploading images to Google Cloud Storage
#
# Configuration:
#   - GOOGLE_CLOUD_PROJECT_ID: Your GCS project ID (required)
#   - GOOGLE_CLOUD_STORAGE_BUCKET: Bucket name (required)
#   - GOOGLE_APPLICATION_CREDENTIALS_JSON: Service account JSON as string (required)
#
# Usage:
#   service = ImageUploadService.new(user: user, image_file: uploaded_file)
#   result = service.upload
#   if result.success?
#     url = result.data[:url]
#   end
class ImageUploadService < ApplicationService
  def initialize(user:, image_file:)
    @user = user
    @image_file = image_file
    @bucket_name = ENV['GOOGLE_CLOUD_STORAGE_BUCKET']
    @project_id = ENV['GOOGLE_CLOUD_PROJECT_ID']
    @credentials_json = ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON']
  end

  def upload
    return failure("No image file provided") unless @image_file
    
    config_result = validate_configuration
    return config_result if config_result.failure?

    begin
      # Initialize storage client
      storage = initialize_storage
      return failure("Failed to initialize storage client", 'STORAGE_INIT_ERROR') unless storage

      # Generate unique filename
      filename = generate_filename

      # Get bucket
      bucket = storage.bucket(@bucket_name)
      return failure("Bucket '#{@bucket_name}' not found or not accessible", 'BUCKET_ERROR') unless bucket

      # Upload file
      file = bucket.create_file(
        @image_file.path || StringIO.new(@image_file.read),
        filename,
        content_type: @image_file.content_type || 'image/jpeg'
      )

      # Make file publicly readable
      file.acl.public!

      # Return public URL
      url = "https://storage.googleapis.com/#{@bucket_name}/#{filename}"
      success(url: url, filename: filename)
    rescue JSON::ParserError => e
      Rails.logger.error("ImageUploadService: Invalid JSON in GOOGLE_APPLICATION_CREDENTIALS_JSON")
      failure("Invalid credentials JSON: #{e.message}", 'CREDENTIALS_ERROR')
    rescue Google::Cloud::Error => e
      Rails.logger.error("ImageUploadService: Google Cloud error: #{e.message}")
      failure("Google Cloud Storage error: #{e.message}", 'GCS_ERROR')
    rescue StandardError => e
      Rails.logger.error("ImageUploadService.upload error: #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Image upload failed: #{e.message}", 'UPLOAD_ERROR')
    end
  end

  private

  def validate_configuration
    missing = []
    missing << 'GOOGLE_CLOUD_PROJECT_ID' if @project_id.blank?
    missing << 'GOOGLE_CLOUD_STORAGE_BUCKET' if @bucket_name.blank?
    missing << 'GOOGLE_APPLICATION_CREDENTIALS_JSON' if @credentials_json.blank?

    if missing.any?
      return failure(
        "Missing required environment variables: #{missing.join(', ')}. " \
        "See docs/storage/SETUP.md for configuration instructions.",
        'CONFIG_ERROR'
      )
    end

    success
  end

  def initialize_storage
    # Parse credentials JSON
    credentials_hash = JSON.parse(@credentials_json)
    
    # Initialize GCS client
    Google::Cloud::Storage.new(
      project_id: @project_id,
      credentials: credentials_hash
    )
  rescue JSON::ParserError => e
    Rails.logger.error("ImageUploadService: Failed to parse GOOGLE_APPLICATION_CREDENTIALS_JSON")
    raise
  rescue StandardError => e
    Rails.logger.error("ImageUploadService: Failed to initialize storage: #{e.message}")
    raise
  end

  def generate_filename
    # Generate unique filename: user_id/timestamp_random.extension
    extension = File.extname(@image_file.original_filename || 'image.jpg')
    timestamp = Time.current.to_i
    random = SecureRandom.hex(8)
    "booties/#{@user.id}/#{timestamp}_#{random}#{extension}"
  end
end
