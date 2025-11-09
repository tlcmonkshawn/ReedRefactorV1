class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true

  validates :sender_type, presence: true, inclusion: { in: %w[user reed system] }
  validates :content, presence: true
  validates :message_type, presence: true, inclusion: { in: %w[text audio image system] }

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :update_conversation_timestamp

  def mark_as_read!
    update_column(:read, true)
  end

  private

  def update_conversation_timestamp
    conversation.update_last_message!
  end
end

