class CreateBooties < ActiveRecord::Migration[7.1]
  def change
    create_table :booties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      
      t.string :title, null: false
      t.text :description
      t.string :category, null: false
      t.string :status, null: false, default: 'captured' # captured, submitted, researching, researched, finalized
      
      t.decimal :recommended_bounty, precision: 10, scale: 2
      t.decimal :final_bounty, precision: 10, scale: 2
      t.text :research_summary
      t.text :research_reasoning
      
      # Images
      t.string :primary_image_url
      t.json :alternate_image_urls, default: []
      t.json :edited_image_urls, default: []
      
      # Square Integration
      t.string :square_product_id
      t.string :square_variation_id
      t.datetime :finalized_at
      
      # Research metadata
      t.datetime :research_started_at
      t.datetime :research_completed_at
      t.boolean :research_auto_triggered, default: false
      
      t.timestamps
    end

    add_index :booties, :status
    add_index :booties, :category
    add_index :booties, :location_id
    add_index :booties, :user_id
    add_index :booties, :created_at
    add_index :booties, :square_product_id
  end
end

