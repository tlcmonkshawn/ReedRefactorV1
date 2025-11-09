class GroundingSource < FirestoreModel
  attribute :bootie_id, :string
  attribute :research_log_id, :string
  attribute :title, :string
  attribute :url, :string
  attribute :snippet, :string
  attribute :source_type, :string

  validates :title, presence: true
  validates :url, presence: true
  validates :source_type, inclusion: { in: %w[google_search discogs manual] }, allow_nil: true

  def bootie
    Bootie.find(bootie_id) if bootie_id.present?
  end

  def research_log
    ResearchLog.find(research_log_id) if research_log_id.present?
  end
end
