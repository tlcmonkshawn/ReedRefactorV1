# Initialize Prompt Cache
# Load all prompts into memory at application startup

Rails.application.config.after_initialize do
  begin
    # Only load if database is available and prompts table exists
    if ActiveRecord::Base.connection.table_exists?('prompts')
      PromptCacheService.load!
      Rails.logger.info "PromptCacheService initialized successfully"
    else
      Rails.logger.warn "PromptCacheService: prompts table does not exist, skipping cache load"
    end
  rescue => e
    Rails.logger.error "PromptCacheService initialization failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Don't fail startup if prompts can't be loaded
  end
end

