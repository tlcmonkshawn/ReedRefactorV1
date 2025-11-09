# Prompt Model
#
# Stores AI prompts and system instructions for the R.E.E.D. application.
# Supports multiple categories: system_instructions, image_processing, research, chat, game_modes, tool_functions
#
# @see AI_PROMPTS.json for the source of initial prompts
class Prompt < FirestoreModel
  attribute :category, :string
  attribute :name, :string
  attribute :model, :string
  attribute :prompt_text, :string
  attribute :prompt_type, :string
  attribute :description, :string
  attribute :active, :boolean, default: true
  attribute :sort_order, :integer, default: 0
  attribute :version, :integer, default: 1
  attribute :metadata, default: {}
  attribute :use_case, :string

  validates :category, presence: true
  validates :name, presence: true
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
  validate :name_uniqueness_within_category, on: :create

  before_update :increment_version, if: :prompt_text_changed?
  after_save :reload_cache
  after_destroy :reload_cache

  def self.active
    where(:active, true).get
  end

  def self.by_category(category)
    where(:category, category).get
  end

  def self.by_model(model)
    where(:model, model).get
  end

  def self.ordered
    # Firestore doesn't support multiple order by easily, so we sort in Ruby
    all.sort_by { |p| [p.sort_order || 0, p.name || ''] }
  end

  def self.get(category:, name:)
    active.find { |p| p.category == category && p.name == name }
  end

  def self.for_category(category)
    active.select { |p| p.category == category }.sort_by { |p| [p.sort_order || 0, p.name || ''] }
  end

  def system_instruction?
    prompt_type == 'system_instruction' || category == 'system_instructions'
  end

  def prompt_template?
    prompt_type == 'prompt_template'
  end

  def tool_function?
    prompt_type == 'tool_function' || category == 'tool_functions'
  end

  def metadata_hash
    metadata.is_a?(Hash) ? metadata : (metadata || {})
  end

  private

  def name_uniqueness_within_category
    existing = self.class.where(:category, category).where(:name, name).first
    if existing && existing.id != id
      errors.add(:name, "has already been taken in this category")
    end
  end

  def increment_version
    self.version = (version || 1) + 1
  end

  def reload_cache
    # Reload cache in background to avoid blocking the request
    Thread.new do
      begin
        PromptCacheService.reload if defined?(PromptCacheService)
      rescue => e
        Rails.logger.error "Failed to reload prompt cache: #{e.message}"
      end
    end
  end
end
