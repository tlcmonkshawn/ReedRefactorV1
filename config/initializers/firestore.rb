# Firestore Configuration
# Initialize Firestore client for the application

require 'google/cloud/firestore'

# Get project ID from environment or use default
project_id = ENV.fetch('GOOGLE_CLOUD_PROJECT_ID', 'reed-bootie-hunter')

# Initialize Firestore client
# Credentials will be loaded from:
# 1. GOOGLE_APPLICATION_CREDENTIALS_JSON environment variable (JSON string)
# 2. GOOGLE_APPLICATION_CREDENTIALS environment variable (file path)
# 3. Default credentials (gcloud auth application-default login)
firestore_config = {
  project_id: project_id
}

# If credentials are provided as JSON string, parse and use them
if ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'].present?
  require 'json'
  credentials_hash = JSON.parse(ENV['GOOGLE_APPLICATION_CREDENTIALS_JSON'])
  firestore_config[:credentials] = credentials_hash
end

# Initialize Firestore client
Firestore = Google::Cloud::Firestore.new(**firestore_config)

# Make Firestore available globally
Rails.application.config.firestore = Firestore

# Log Firestore initialization
Rails.logger.info "Firestore initialized for project: #{project_id}"

