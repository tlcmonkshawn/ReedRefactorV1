class GameSession < ApplicationRecord
  belongs_to :user
  has_many :scores, dependent: :nullify

  validates :game_type, presence: true, inclusion: { in: %w[scour locus tag] }
  validates :status, presence: true, inclusion: { in: %w[active completed abandoned] }

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :by_game_type, ->(game_type) { where(game_type: game_type) }

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
end

