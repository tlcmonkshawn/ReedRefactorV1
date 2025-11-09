class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :sender_type, null: false # user, reed, system
      t.text :content, null: false
      t.string :message_type, null: false, default: 'text' # text, audio, image, system
      t.json :metadata
      t.boolean :read, default: false, null: false
      
      t.timestamps
    end

    add_index :messages, :conversation_id
    add_index :messages, :created_at
    add_index :messages, [:conversation_id, :read]
  end
end

