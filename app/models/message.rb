class Message < FirestoreModel
  attribute :conversation_id, :string
  attribute :user_id, :string
  attribute :sender_type, :string
  attribute :content, :string
  attribute :message_type, :string, default: 'text'
  attribute :read, :boolean, default: false
  attribute :metadata, default: {}

  validates :sender_type, presence: true, inclusion: { in: %w[user reed system] }
  validates :content, presence: true
  validates :message_type, presence: true, inclusion: { in: %w[text audio image system] }

  after_create :update_conversation_timestamp

  def self.unread
    where(:read, false).get
  end

  def self.read
    where(:read, true).get
  end

  def self.recent
    order(:created_at, :desc).get
  end

  def mark_as_read!
    update(read: true)
  end

  def conversation
    Conversation.find(conversation_id) if conversation_id.present?
  end

  def user
    User.find(user_id) if user_id.present?
  end

  private

  def update_conversation_timestamp
    conv = conversation
    conv&.update_last_message!
  end
end
