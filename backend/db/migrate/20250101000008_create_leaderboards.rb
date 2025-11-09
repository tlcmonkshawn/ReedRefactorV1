class CreateLeaderboards < ActiveRecord::Migration[7.1]
  def change
    create_table :leaderboards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :period_type, null: false # daily, weekly, monthly, overall
      t.date :period_date # For daily/weekly/monthly
      t.integer :points, default: 0, null: false
      t.integer :rank
      
      t.timestamps
    end

    add_index :leaderboards, [:period_type, :period_date, :points]
    add_index :leaderboards, [:period_type, :period_date, :rank]
    add_index :leaderboards, :user_id
  end
end

