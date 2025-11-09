# Bootie Model
#
# Represents a captured item/inventory entry in the system.
# Booties go through a workflow: captured -> submitted -> researching -> researched -> finalized
#
# A Bootie is "finalized" when it's published to the Square catalog for sale.
#
# @see PRODUCT_PROFILE.md for detailed feature descriptions
class Bootie < ApplicationRecord
  # Associations
  belongs_to :user                  # User who captured the Bootie
  belongs_to :location              # Physical store location
  has_many :research_logs, dependent: :destroy           # Research history and process logs
  has_many :grounding_sources, dependent: :destroy       # Research source citations (URLs, titles)
  has_many :scores, dependent: :nullify                  # Gamification scores (nullify to preserve score history)

  # Validations
  validates :title, presence: true
  # Category must be one of the predefined categories
  validates :category, presence: true, inclusion: { in: %w[used_goods antiques electronics collectibles weaponry artifacts data_logs miscellaneous] }
  # Status must follow the workflow progression
  validates :status, presence: true, inclusion: { in: %w[captured submitted researching researched finalized] }

  # Scopes for querying Booties
  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_location, ->(location_id) { where(location_id: location_id) }
  scope :pending_research, -> { where(status: %w[submitted researching]) }          # Booties awaiting or in research
  scope :ready_for_finalization, -> { where(status: 'researched') }                 # Booties ready for Bootie Boss review
  scope :finalized, -> { where(status: 'finalized') }                               # Booties published to Square

  # Status helper methods - convenience methods for checking current status
  def captured?
    status == 'captured'
  end

  def submitted?
    status == 'submitted'
  end

  def researching?
    status == 'researching'
  end

  def researched?
    status == 'researched'
  end

  def finalized?
    status == 'finalized'
  end

  # Status transition methods - enforce workflow progression
  #
  # Submit Bootie for research (moves from captured -> submitted)
  # Research is automatically triggered after submission
  def submit!
    return false unless captured?
    update(status: 'submitted', research_auto_triggered: true)
  end

  # Start research process (moves from submitted -> researching)
  # Called by ResearchService when research begins
  def start_research!
    return false unless submitted?
    update(status: 'researching', research_started_at: Time.current)
  end

  # Complete research with results (moves from researching -> researched)
  # Called by ResearchService after research completes
  #
  # @param recommended_bounty [Decimal] AI-recommended price
  # @param research_summary [String] Brief summary of research findings
  # @param research_reasoning [String] Detailed reasoning for recommended price
  def complete_research!(recommended_bounty:, research_summary:, research_reasoning:)
    return false unless researching?
    update(
      status: 'researched',
      recommended_bounty: recommended_bounty,
      research_summary: research_summary,
      research_reasoning: research_reasoning,
      research_completed_at: Time.current
    )
  end

  # Finalize Bootie to Square catalog (moves from researched -> finalized)
  # Called by FinalizationService when Bootie Boss approves and publishes to Square
  #
  # @param final_bounty [Decimal] Final price set by Bootie Boss
  # @param square_product_id [String] Square catalog product ID
  # @param square_variation_id [String] Square catalog variation ID
  def finalize!(final_bounty:, square_product_id:, square_variation_id:)
    return false unless researched?
    return false if final_bounty.blank?
    
    update(
      status: 'finalized',
      final_bounty: final_bounty,
      square_product_id: square_product_id,
      square_variation_id: square_variation_id,
      finalized_at: Time.current
    )
  end
end

