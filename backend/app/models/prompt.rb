# Prompt Model
#
# Stores AI prompts and system instructions for the R.E.E.D. application.
# Supports multiple categories: system_instructions, image_processing, research, chat, game_modes, tool_functions
#
# @see AI_PROMPTS.json for the source of initial prompts
class Prompt < ApplicationRecord
  # Validations
  validates :category, presence: true
  validates :name, presence: true, uniqueness: { scope: :category }
  validates :model, presence: true
  validates :prompt_text, presence: true
  validates :category, inclusion: { 
    in: %w[system_instructions image_processing research chat game_modes tool_functions],
    message: "must be one of: system_instructions, image_processing, research, chat, game_modes, tool_functions"
  }
  validates :prompt_type, inclusion: { 
    in: %w[system_instruction prompt_template tool_function],
    allow_blank: true
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_model, ->(model) { where(model: model) }
  scope :ordered, -> { order(:sort_order, :name) }

  # Class method to get prompt by category and name
  def self.get(category:, name:)
    active.find_by(category: category, name: name)
  end

  # Class method to get all prompts for a category
  def self.for_category(category)
    active.where(category: category).ordered
  end

  # Check if this is a system instruction
  def system_instruction?
    prompt_type == 'system_instruction' || category == 'system_instructions'
  end

  # Check if this is a prompt template
  def prompt_template?
    prompt_type == 'prompt_template'
  end

  # Check if this is a tool function
  def tool_function?
    prompt_type == 'tool_function' || category == 'tool_functions'
  end

  # Get metadata as hash (handles JSON column)
  def metadata_hash
    metadata.is_a?(Hash) ? metadata : (metadata || {})
  end

  # Increment version when updated
  before_update :increment_version, if: :prompt_text_changed?
  
  # Reload cache after save/destroy
  after_save :reload_cache
  after_destroy :reload_cache

  private

  def increment_version
    self.version += 1
  end

  def reload_cache
    # Reload cache in background to avoid blocking the request
    Thread.new do
      begin
        PromptCacheService.reload
      rescue => e
        Rails.logger.error "Failed to reload prompt cache: #{e.message}"
      end
    end
  end
end

