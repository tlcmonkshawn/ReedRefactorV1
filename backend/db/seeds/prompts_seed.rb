# Seeds prompts from AI_PROMPTS.json
# Run with: rails runner db/seeds/prompts_seed.rb

require 'json'
require 'fileutils'

def seed_prompts
  prompts_file = Rails.root.join('..', 'AI_PROMPTS.json')
  
  unless File.exist?(prompts_file)
    puts "AI_PROMPTS.json not found at #{prompts_file}"
    return
  end

  data = JSON.parse(File.read(prompts_file))
  
  # Seed system instructions
  if data['system_instructions'] && data['system_instructions']['reed_persona']
    persona = data['system_instructions']['reed_persona']
    Prompt.find_or_create_by(category: 'system_instructions', name: 'reed_persona') do |p|
      p.model = persona['model']
      p.prompt_text = persona['system_instruction']
      p.description = persona['description']
      p.use_case = persona['use_case']
      p.prompt_type = 'system_instruction'
      p.metadata = persona['persona'].to_json
      p.active = true
      p.sort_order = 0
    end
    puts "Seeded: system_instructions.reed_persona"
  end

  # Seed image processing prompts
  if data['image_processing']
    seed_category_prompts('image_processing', data['image_processing'])
  end

  # Seed research prompts
  if data['research']
    seed_category_prompts('research', data['research'])
  end

  # Seed chat prompts
  if data['chat']
    seed_category_prompts('chat', data['chat'])
  end

  # Seed game mode prompts
  if data['game_modes']
    seed_category_prompts('game_modes', data['game_modes'])
  end

  # Seed tool function prompts
  if data['tool_functions']
    seed_category_prompts('tool_functions', data['tool_functions'])
  end

  puts "Prompt seeding completed!"
end

def seed_category_prompts(category, category_data)
  category_data.each do |key, prompt_data|
    next unless prompt_data.is_a?(Hash)
    
    # Handle prompts with nested structure (like image_processing.edit_image.prompts)
    if prompt_data['prompts'] && prompt_data['prompts'].is_a?(Hash)
      prompt_data['prompts'].each do |prompt_key, prompt_info|
        full_name = "#{key}_#{prompt_key}"
        create_or_update_prompt(category, full_name, prompt_info, prompt_data)
      end
    else
      # Handle direct prompt structure
      create_or_update_prompt(category, key, prompt_data, nil)
    end
  end
end

def create_or_update_prompt(category, name, prompt_data, parent_data)
  prompt_text = prompt_data['prompt'] || prompt_data['prompt_text'] || prompt_data['system_instruction'] || prompt_data['prompt_template']
  model = prompt_data['model'] || parent_data&.dig('model')
  
  # For categories without explicit prompts (like tool_functions, game_modes, chat), use description or create a placeholder
  if !prompt_text && (category == 'tool_functions' || category == 'game_modes' || category == 'chat')
    prompt_text = prompt_data['description'] || prompt_data['prompt_addition'] || prompt_data['context'] || "#{name} prompt"
  end
  
  # For tool_functions, game_modes, and chat, use a default model if none specified
  model ||= 'gemini-2.5-flash' if category == 'tool_functions' || category == 'game_modes' || category == 'chat'
  
  return unless prompt_text && model
  
  Prompt.find_or_create_by(category: category, name: name) do |p|
    p.model = model
    p.prompt_text = prompt_text
    p.description = prompt_data['description'] || parent_data&.dig('description')
    p.use_case = prompt_data['use_case'] || parent_data&.dig('use_case')
    p.prompt_type = determine_prompt_type(category, prompt_data)
    p.metadata = extract_metadata(prompt_data, parent_data)
    p.active = true
    p.sort_order = 0
  end
  
  puts "Seeded: #{category}.#{name}"
end

def determine_prompt_type(category, prompt_data)
  return 'system_instruction' if category == 'system_instructions'
  return 'tool_function' if category == 'tool_functions'
  return 'prompt_template'
end

def extract_metadata(prompt_data, parent_data)
  metadata = {}
  
  # Extract expected_output, tools, etc.
  metadata['expected_output'] = prompt_data['expected_output'] if prompt_data['expected_output']
  metadata['tools'] = prompt_data['tools'] if prompt_data['tools']
  metadata['workflow_steps'] = prompt_data['workflow_steps'] if prompt_data['workflow_steps']
  metadata['arguments'] = prompt_data['arguments'] if prompt_data['arguments']
  metadata['execution'] = prompt_data['execution'] if prompt_data['execution']
  metadata['reed_behavior'] = prompt_data['reed_behavior'] if prompt_data['reed_behavior']
  metadata['prompt_addition'] = prompt_data['prompt_addition'] if prompt_data['prompt_addition']
  
  metadata.present? ? metadata : nil
end

# Run the seeding
seed_prompts

