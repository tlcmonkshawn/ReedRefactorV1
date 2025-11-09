# Bootie Model
#
# Represents a captured item/inventory entry in the system.
# Booties go through a workflow: captured -> submitted -> researching -> researched -> finalized
#
# A Bootie is "finalized" when it's published to the Square catalog for sale.
#
# @see PRODUCT_PROFILE.md for detailed feature descriptions
class Bootie < FirestoreModel
  # Define attributes
  attribute :title, :string
  attribute :description, :string
  attribute :category, :string
  attribute :status, :string, default: 'captured'
  attribute :user_id, :string
  attribute :location_id, :string
  attribute :primary_image_url, :string
  attribute :alternate_image_urls, default: []
  attribute :edited_image_urls, default: []
  attribute :recommended_bounty, :decimal
  attribute :final_bounty, :decimal
  attribute :research_summary, :string
  attribute :research_reasoning, :string
  attribute :research_auto_triggered, :boolean, default: false
  attribute :research_started_at, :datetime
  attribute :research_completed_at, :datetime
  attribute :square_product_id, :string
  attribute :square_variation_id, :string
  attribute :finalized_at, :datetime

  # Validations
  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: %w[used_goods antiques electronics collectibles weaponry artifacts data_logs miscellaneous] }
  validates :status, presence: true, inclusion: { in: %w[captured submitted researching researched finalized] }
  validates :user_id, presence: true
  validates :location_id, presence: true

  # Scopes
  def self.by_status(status)
    where(:status, status).get
  end

  def self.by_category(category)
    where(:category, category).get
  end

  def self.by_location(location_id)
    where(:location_id, location_id).get
  end

  def self.pending_research
    # Firestore doesn't support OR queries directly, so we query each status separately
    submitted = where(:status, 'submitted').get
    researching = where(:status, 'researching').get
    submitted + researching
  end

  def self.ready_for_finalization
    where(:status, 'researched').get
  end

  def self.finalized
    where(:status, 'finalized').get
  end

  # Status helper methods
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

  # Status transition methods
  def submit!
    return false unless captured?
    update(status: 'submitted', research_auto_triggered: true)
  end

  def start_research!
    return false unless submitted?
    update(status: 'researching', research_started_at: Time.current)
  end

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

  # Associations
  def user
    User.find(user_id) if user_id.present?
  end

  def location
    Location.find(location_id) if location_id.present?
  end

  def research_logs
    ResearchLog.where(:bootie_id, id).get
  end

  def grounding_sources
    GroundingSource.where(:bootie_id, id).get
  end

  def scores
    Score.where(:bootie_id, id).get
  end
end
