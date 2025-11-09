class UserAchievement < FirestoreModel
  attribute :user_id, :string
  attribute :achievement_id, :string
  attribute :earned_at, :datetime

  validate :user_achievement_uniqueness, on: :create

  private

  def user_achievement_uniqueness
    existing = self.class.where(:user_id, user_id).where(:achievement_id, achievement_id).first
    if existing && existing.id != id
      errors.add(:base, "User already has this achievement")
    end
  end

  def user
    User.find(user_id) if user_id.present?
  end

  def achievement
    Achievement.find(achievement_id) if achievement_id.present?
  end
end
