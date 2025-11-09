# PromptCacheService
#
# Manages caching of prompts in memory to avoid database queries at runtime.
# Prompts are loaded at application startup and reloaded only when changes are detected.
#
# Usage:
#   PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
#   PromptCacheService.all_for_category('image_processing')
#   PromptCacheService.check_for_updates  # Returns true if prompts changed
#   PromptCacheService.reload  # Force reload from database
class PromptCacheService
  @@cache = {}
  @@last_updated_at = nil
  @@mutex = Mutex.new

  # Load all active prompts into cache
  # Called at application startup
  def self.load!
    @@mutex.synchronize do
      @@cache.clear
      prompts = Prompt.active
      
      prompts.each do |prompt|
        key = "#{prompt.category}:#{prompt.name}"
        @@cache[key] = prompt
      end
      
      # Track the most recent update time
      @@last_updated_at = prompts.map(&:updated_at).compact.max || Time.current
      
      Rails.logger.info "PromptCacheService: Loaded #{prompts.count} prompts into cache"
    end
  end

  # Get a prompt by category and name
  def self.get(category:, name:)
    key = "#{category}:#{name}"
    @@cache[key]
  end

  # Get all prompts for a category
  def self.all_for_category(category)
    @@cache.values.select { |p| p.category == category }
  end

  # Get all prompts
  def self.all
    @@cache.values
  end

  # Get prompts for a specific model
  def self.all_for_model(model)
    @@cache.values.select { |p| p.model == model }
  end

  # Check if prompts have been updated since last cache load
  # Returns true if updates are needed, false otherwise
  def self.check_for_updates
    prompts = Prompt.active
    current_max_updated_at = prompts.map(&:updated_at).compact.max
    
    if current_max_updated_at.nil?
      return false
    end
    
    if @@last_updated_at.nil?
      return true  # Cache not initialized
    end
    
    current_max_updated_at > @@last_updated_at
  end

  # Reload prompts from database if they've changed
  # Returns true if reloaded, false if up to date
  def self.reload_if_changed
    if check_for_updates
      reload
      true
    else
      false
    end
  end

  # Force reload all prompts from database
  def self.reload
    load!
  end

  # Get cache statistics
  def self.stats
    {
      cached_count: @@cache.size,
      last_updated_at: @@last_updated_at,
      categories: @@cache.values.map(&:category).uniq.sort
    }
  end

  # Clear the cache (useful for testing)
  def self.clear
    @@mutex.synchronize do
      @@cache.clear
      @@last_updated_at = nil
    end
  end
end

