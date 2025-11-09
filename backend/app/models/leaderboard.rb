class Leaderboard < ApplicationRecord
  belongs_to :user

  validates :period_type, presence: true, inclusion: { in: %w[daily weekly monthly overall] }

  scope :for_period, ->(period_type, period_date = nil) {
    query = where(period_type: period_type)
    query = query.where(period_date: period_date) if period_date
    query.order(points: :desc)
  }

  def self.update_rankings!(period_type:, period_date: nil)
    entries = for_period(period_type, period_date)
    entries.each_with_index do |entry, index|
      entry.update_column(:rank, index + 1)
    end
  end
end

