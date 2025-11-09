class CreateGameSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :game_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :game_type, null: false # scour, locus, tag
      t.string :status, null: false, default: 'active' # active, completed, abandoned
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :score, default: 0, null: false
      t.integer :items_processed, default: 0, null: false
      t.integer :time_seconds
      t.json :metadata
      
      t.timestamps
    end

    add_index :game_sessions, :user_id
    add_index :game_sessions, [:game_type, :status]
    add_index :game_sessions, :started_at
  end
end

