class Score < FirestoreModel
  attribute :user_id, :string
  attribute :bootie_id, :string
  attribute :game_session_id, :string
  attribute :action_type, :string
  attribute :points, :integer
  attribute :metadata, default: {}

  validates :action_type, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :update_user_total_points

  def user
    User.find(user_id) if user_id.present?
  end

  def bootie
    Bootie.find(bootie_id) if bootie_id.present?
  end

  def game_session
    GameSession.find(game_session_id) if game_session_id.present?
  end

  private

  def update_user_total_points
    u = user
    return unless u
    current_points = u.total_points || 0
    u.update(total_points: current_points + points)
  end
end
