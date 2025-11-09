class Leaderboard < FirestoreModel
  attribute :user_id, :string
  attribute :period_type, :string
  attribute :period_date, :date
  attribute :points, :integer, default: 0
  attribute :rank, :integer

  validates :period_type, presence: true, inclusion: { in: %w[daily weekly monthly overall] }

  def self.for_period(period_type, period_date = nil)
    query = where(:period_type, period_type)
    query = query.where(:period_date, period_date) if period_date
    query.order(:points, :desc).get
  end

  def self.update_rankings!(period_type:, period_date: nil)
    entries = for_period(period_type, period_date)
    entries.each_with_index do |entry, index|
      entry.update(rank: index + 1)
    end
  end

  def user
    User.find(user_id) if user_id.present?
  end
end
