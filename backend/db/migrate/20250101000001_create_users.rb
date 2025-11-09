class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :name, null: false
      t.string :role, null: false, default: 'agent' # agent, bootie_boss, admin, player
      t.string :phone_number
      t.string :avatar_url
      t.boolean :active, default: true, null: false
      t.datetime :last_login_at
      
      # Player-specific fields
      t.integer :total_points, default: 0, null: false
      t.integer :total_items_scanned, default: 0, null: false
      
      t.timestamps
    end

    add_index :users, :role
    add_index :users, :total_points
  end
end

