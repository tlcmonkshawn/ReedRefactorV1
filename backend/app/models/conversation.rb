class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :participant_user, class_name: 'User', optional: true
  has_many :messages, dependent: :destroy

  validates :conversation_type, presence: true, inclusion: { in: %w[voice video text] }
  validates :participant_type, inclusion: { in: %w[reed bootie_boss admin player] }, allow_nil: true

  scope :recent, -> { order(last_message_at: :desc) }
  scope :unread, -> { joins(:messages).where(messages: { read: false }).distinct }

  def update_last_message!
    update_column(:last_message_at, Time.current)
  end
end

