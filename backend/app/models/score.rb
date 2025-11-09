class Score < ApplicationRecord
  belongs_to :user
  belongs_to :bootie, optional: true
  belongs_to :game_session, optional: true

  validates :action_type, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :update_user_total_points

  private

  def update_user_total_points
    user.increment!(:total_points, points)
  end
end

