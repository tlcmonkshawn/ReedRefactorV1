class Conversation < FirestoreModel
  attribute :user_id, :string
  attribute :participant_user_id, :string
  attribute :conversation_type, :string
  attribute :participant_type, :string
  attribute :context_summary, :string
  attribute :last_message_at, :datetime

  validates :conversation_type, presence: true, inclusion: { in: %w[voice video text] }
  validates :participant_type, inclusion: { in: %w[reed bootie_boss admin player] }, allow_nil: true

  def self.recent
    order(:last_message_at, :desc).get
  end

  def self.unread
    # Get conversations with unread messages
    unread_message_conversation_ids = Message.where(:read, false).get.map(&:conversation_id).uniq
    return [] if unread_message_conversation_ids.empty?
    unread_message_conversation_ids.map { |id| find(id) }.compact
  end

  def update_last_message!
    update(last_message_at: Time.current)
  end

  def user
    User.find(user_id) if user_id.present?
  end

  def participant_user
    User.find(participant_user_id) if participant_user_id.present?
  end

  def messages
    Message.where(:conversation_id, id).get
  end
end
