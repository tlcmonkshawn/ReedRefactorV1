class CreateGroundingSources < ActiveRecord::Migration[7.1]
  def change
    create_table :grounding_sources do |t|
      t.references :bootie, null: false, foreign_key: true
      t.references :research_log, foreign_key: true
      
      t.string :title, null: false
      t.text :url, null: false
      t.text :snippet
      t.string :source_type # google_search, discogs, manual
      
      t.timestamps
    end

    add_index :grounding_sources, :bootie_id
    add_index :grounding_sources, :research_log_id
  end
end

