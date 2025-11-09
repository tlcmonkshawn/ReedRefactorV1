class CreatePrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts do |t|
      t.string :category, null: false # e.g., 'system_instructions', 'image_processing', 'research', 'chat', 'game_modes'
      t.string :name, null: false # Unique identifier/name for the prompt
      t.string :model, null: false # Gemini model name (e.g., 'gemini-2.5-flash', 'gemini-flash-lite-latest')
      t.text :prompt_text, null: false # The actual prompt text
      t.text :description # Description of what this prompt does
      t.string :use_case # What this prompt is used for
      t.json :metadata # Additional metadata (expected_output, tools, etc.)
      t.boolean :active, default: true, null: false # Whether this prompt is currently active
      t.integer :version, default: 1, null: false # Version number for tracking changes
      t.string :prompt_type # Type: 'system_instruction', 'prompt_template', 'tool_function', etc.
      t.integer :sort_order, default: 0 # For ordering prompts in UI
      
      t.timestamps
    end

    add_index :prompts, :category
    add_index :prompts, :name
    add_index :prompts, [:category, :name], unique: true
    add_index :prompts, :active
    add_index :prompts, :prompt_type
  end
end

