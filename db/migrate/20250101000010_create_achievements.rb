class CreateAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.text :description
      t.string :badge_icon_url
      t.string :achievement_type # milestone, challenge, special
      t.integer :points_required
      t.boolean :active, default: true, null: false
      
      t.timestamps
    end

    add_index :achievements, :achievement_type
    add_index :achievements, :active
  end
end

