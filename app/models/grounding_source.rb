class GroundingSource < ApplicationRecord
  belongs_to :bootie
  belongs_to :research_log, optional: true

  validates :title, presence: true
  validates :url, presence: true
  validates :source_type, inclusion: { in: %w[google_search discogs manual] }, allow_nil: true
end

