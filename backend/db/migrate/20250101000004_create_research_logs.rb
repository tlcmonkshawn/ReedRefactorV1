class CreateResearchLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :research_logs do |t|
      t.references :bootie, null: false, foreign_key: true
      t.text :query
      t.text :response
      t.string :research_method # ai_with_search, discogs, manual
      t.text :raw_data
      t.boolean :success, default: true, null: false
      t.text :error_message
      
      t.timestamps
    end

    add_index :research_logs, :bootie_id
    add_index :research_logs, :created_at
  end
end

