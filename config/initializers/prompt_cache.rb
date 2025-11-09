# Initialize Prompt Cache
# Load all prompts into memory at application startup

Rails.application.config.after_initialize do
  begin
    # Load prompts from Firestore
    # Firestore collections are created automatically on first write
    PromptCacheService.load!
    Rails.logger.info "PromptCacheService initialized successfully"
  rescue => e
    Rails.logger.error "PromptCacheService initialization failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Don't fail startup if prompts can't be loaded
  end
end

