class CreateScores < ActiveRecord::Migration[7.1]
  def change
    create_table :scores do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type, null: false # scan_item, find_tag, scour_run, locus_audit, social_share
      t.integer :points, null: false
      t.references :bootie, foreign_key: true
      t.references :game_session, foreign_key: true
      t.text :metadata
      
      t.timestamps
    end

    add_index :scores, :user_id
    add_index :scores, :created_at
    add_index :scores, :action_type
  end
end

