# User Model
#
# Represents a user account in the system.
# Supports multiple roles: agent, bootie_boss, admin, player
#
# @see PRODUCT_PROFILE.md for role descriptions and workflows
class User < ApplicationRecord
  has_secure_password  # BCrypt password hashing via bcrypt gem

  # Associations
  has_many :booties, dependent: :destroy              # Booties captured by this user
  has_many :conversations, dependent: :destroy        # Conversation threads
  has_many :messages, dependent: :destroy             # Messages sent by this user
  has_many :scores, dependent: :destroy               # Gamification scores
  has_many :game_sessions, dependent: :destroy        # Game mode sessions (S.C.O.U.R., L.O.C.U.S., T.A.G.)
  has_many :leaderboards, dependent: :destroy         # Leaderboard entries
  has_many :user_achievements, dependent: :destroy    # Achievements earned
  has_many :achievements, through: :user_achievements # Achievements (through join table)

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  # Role must be one of the predefined roles
  validates :role, presence: true, inclusion: { in: %w[agent bootie_boss admin player] }
  # Password must be at least 8 characters (only validated on create or when password is being updated)
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }

  # Role helper methods - convenience methods for checking user role
  def agent?
    role == 'agent'
  end

  def bootie_boss?
    role == 'bootie_boss'
  end

  def admin?
    role == 'admin'
  end

  def player?
    role == 'player'
  end

  # Permission check: Can this user finalize Booties to Square?
  # Only Bootie Bosses and Admins can finalize
  def can_finalize?
    bootie_boss? || admin?
  end

  # Record login timestamp (called after successful authentication)
  # Uses update_column to bypass validations and callbacks for performance
  def record_login!
    update_column(:last_login_at, Time.current)
  end
end

