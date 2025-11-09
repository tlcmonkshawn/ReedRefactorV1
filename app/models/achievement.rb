class Achievement < FirestoreModel
  attribute :name, :string
  attribute :description, :string
  attribute :achievement_type, :string
  attribute :points_required, :integer
  attribute :badge_icon_url, :string
  attribute :active, :boolean, default: true

  validates :name, presence: true

  def self.active
    where(:active, true).get
  end

  def user_achievements
    UserAchievement.where(:achievement_id, id).get
  end

  def users
    user_ids = user_achievements.map(&:user_id)
    return [] if user_ids.empty?
    User.find_by_ids(user_ids)
  end
end
