class GameSession < FirestoreModel
  attribute :user_id, :string
  attribute :game_type, :string
  attribute :status, :string, default: 'active'
  attribute :started_at, :datetime
  attribute :completed_at, :datetime
  attribute :time_seconds, :integer
  attribute :score, :integer, default: 0
  attribute :items_processed, :integer, default: 0
  attribute :metadata, default: {}

  validates :game_type, presence: true, inclusion: { in: %w[scour locus tag] }
  validates :status, presence: true, inclusion: { in: %w[active completed abandoned] }

  def self.active
    where(:status, 'active').get
  end

  def self.completed
    where(:status, 'completed').get
  end

  def self.by_game_type(game_type)
    where(:game_type, game_type).get
  end

  def active?
    status == 'active'
  end

  def complete!
    return false unless active?
    update(
      status: 'completed',
      completed_at: Time.current,
      time_seconds: calculate_time_seconds
    )
  end

  def calculate_time_seconds
    return nil unless completed_at && started_at
    (completed_at - started_at).to_i
  end

  def user
    User.find(user_id) if user_id.present?
  end

  def scores
    Score.where(:game_session_id, id).get
  end
end
