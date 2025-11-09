class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :conversation_type, null: false # voice, video, text
      t.string :participant_type # reed, bootie_boss, admin, player
      t.references :participant_user, foreign_key: { to_table: :users }
      t.text :context_summary
      t.datetime :last_message_at
      
      t.timestamps
    end

    add_index :conversations, :user_id
    add_index :conversations, :last_message_at
  end
end

