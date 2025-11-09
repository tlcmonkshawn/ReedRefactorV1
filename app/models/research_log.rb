class ResearchLog < FirestoreModel
  attribute :bootie_id, :string
  attribute :research_log_id, :string
  attribute :query, :string
  attribute :response, :string
  attribute :research_method, :string
  attribute :raw_data, :string
  attribute :success, :boolean, default: true
  attribute :error_message, :string

  validates :research_method, inclusion: { in: %w[ai_with_search discogs manual] }, allow_nil: true

  def self.successful
    where(:success, true).get
  end

  def self.failed
    where(:success, false).get
  end

  def bootie
    Bootie.find(bootie_id) if bootie_id.present?
  end

  def grounding_sources
    GroundingSource.where(:research_log_id, id).get
  end
end
