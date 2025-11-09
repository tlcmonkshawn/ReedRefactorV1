# User Model
#
# Represents a user account in the system.
# Supports multiple roles: agent, bootie_boss, admin, player
#
# @see PRODUCT_PROFILE.md for role descriptions and workflows
class User < FirestoreModel
  require 'bcrypt'

  # Define attributes
  attribute :email, :string
  attribute :password_digest, :string
  attribute :name, :string
  attribute :role, :string, default: 'agent'
  attribute :phone_number, :string
  attribute :avatar_url, :string
  attribute :active, :boolean, default: true
  attribute :last_login_at, :datetime
  attribute :total_points, :integer, default: 0
  attribute :total_items_scanned, :integer, default: 0

  # Virtual attribute for password (not stored)
  attr_accessor :password, :password_confirmation

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[agent bootie_boss admin player] }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validate :email_uniqueness, on: :create
  validate :password_confirmation_match, if: -> { password.present? }

  # Password hashing callback
  before_save :hash_password, if: -> { password.present? }

  # Class methods (scopes)
  def self.active
    where(:active, true).get
  end

  def self.by_role(role)
    where(:role, role).get
  end

  def self.find_by_email(email)
    where(:email, email).first
  end

  # Authenticate user with password
  def self.authenticate(email, password)
    user = find_by_email(email)
    return nil unless user
    return nil unless user.active?
    return nil unless user.authenticate_password(password)
    user
  end

  # Instance methods
  def authenticate_password(password)
    return false if password_digest.blank?
    BCrypt::Password.new(password_digest) == password
  end

  # Role helper methods
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

  def active?
    active == true
  end

  # Permission check: Can this user finalize Booties to Square?
  def can_finalize?
    bootie_boss? || admin?
  end

  # Record login timestamp
  def record_login!
    update(last_login_at: Time.current)
  end

  # Associations (return query results)
  def booties
    Bootie.where(:user_id, id).get
  end

  def conversations
    Conversation.where(:user_id, id).get
  end

  def messages
    Message.where(:user_id, id).get
  end

  def scores
    Score.where(:user_id, id).get
  end

  def game_sessions
    GameSession.where(:user_id, id).get
  end

  def leaderboards
    Leaderboard.where(:user_id, id).get
  end

  def user_achievements
    UserAchievement.where(:user_id, id).get
  end

  def achievements
    achievement_ids = user_achievements.map(&:achievement_id)
    return [] if achievement_ids.empty?
    Achievement.find_by_ids(achievement_ids)
  end

  private

  def hash_password
    self.password_digest = BCrypt::Password.create(password)
  end

  def email_uniqueness
    existing = self.class.find_by_email(email)
    if existing && existing.id != id
      errors.add(:email, 'has already been taken')
    end
  end

  def password_confirmation_match
    if password != password_confirmation
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end
end
