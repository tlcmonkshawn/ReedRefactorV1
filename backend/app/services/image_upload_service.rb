require 'google/cloud/storage'
require 'securerandom'

# ImageUploadService
#
# Handles uploading images to Google Cloud Storage
#
# Usage:
#   service = ImageUploadService.new(user: user, image_file: uploaded_file)
#   result = service.upload
#   if result.success?
#     url = result.data[:url]
#   end
class ImageUploadService < ApplicationService
  BUCKET_NAME = ENV['GOOGLE_CLOUD_STORAGE_BUCKET'] || 'bootiehunter-v1-images'
  SERVICE_ACCOUNT_KEY_PATH = Rails.root.join('config', 'service-account-key.json')

  def initialize(user:, image_file:)
    @user = user
    @image_file = image_file
  end

  def upload
    return failure("No image file provided") unless @image_file
    return failure("Google Cloud Storage not configured") unless storage_configured?

    begin
      # Initialize storage client
      storage = initialize_storage

      # Generate unique filename
      filename = generate_filename

      # Upload file
      bucket = storage.bucket(BUCKET_NAME)
      file = bucket.create_file(
        @image_file.path || StringIO.new(@image_file.read),
        filename,
        content_type: @image_file.content_type || 'image/jpeg'
      )

      # Make file publicly readable
      file.acl.public!

      # Return public URL
      url = "https://storage.googleapis.com/#{BUCKET_NAME}/#{filename}"
      success(url: url, filename: filename)
    rescue StandardError => e
      Rails.logger.error("ImageUploadService.upload error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure("Image upload failed: #{e.message}", 'UPLOAD_ERROR')
    end
  end

  private

  def storage_configured?
    ENV['GOOGLE_CLOUD_STORAGE_BUCKET'].present? ||
      (ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'].present? && ENV['GOOGLE_CLOUD_PROJECT_ID'].present?) ||
      (File.exist?(SERVICE_ACCOUNT_KEY_PATH) && ENV['GOOGLE_CLOUD_PROJECT_ID'].present?) ||
      ENV['GOOGLE_CLOUD_PROJECT_ID'].present? # For IAM role-based auth
  end

  def initialize_storage
    # Priority 1: Service account JSON from environment variable (preferred for production)
    if ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'].present?
      require 'json'
      credentials_hash = JSON.parse(ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'])
      Google::Cloud::Storage.new(
        project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
        credentials: credentials_hash
      )
    # Priority 2: Service account key file (for local development)
    elsif File.exist?(SERVICE_ACCOUNT_KEY_PATH)
      Google::Cloud::Storage.new(
        project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'],
        credentials: SERVICE_ACCOUNT_KEY_PATH
      )
    # Priority 3: Default credentials (for GKE/GCE with IAM roles)
    elsif ENV['GOOGLE_CLOUD_PROJECT_ID'].present?
      Google::Cloud::Storage.new(project_id: ENV['GOOGLE_CLOUD_PROJECT_ID'])
    else
      raise "Google Cloud Storage credentials not configured"
    end
  end

  def generate_filename
    # Generate unique filename: user_id/timestamp_random.extension
    extension = File.extname(@image_file.original_filename || 'image.jpg')
    timestamp = Time.current.to_i
    random = SecureRandom.hex(8)
    "booties/#{@user.id}/#{timestamp}_#{random}#{extension}"
  end
end
