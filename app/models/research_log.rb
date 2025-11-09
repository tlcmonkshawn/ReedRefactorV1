class ResearchLog < ApplicationRecord
  belongs_to :bootie
  has_many :grounding_sources, dependent: :destroy

  validates :research_method, inclusion: { in: %w[ai_with_search discogs manual] }, allow_nil: true

  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
end

