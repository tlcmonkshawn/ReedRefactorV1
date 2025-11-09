# R.E.E.D. Bootie Hunter - AI Prompts Management

## Overview

The AI Prompts Management system allows Bootie Bosses and Admins to manage all AI prompts and system instructions used throughout the R.E.E.D. Bootie Hunter application. Prompts are stored in the database and can be edited through both the admin interface and the mobile app configuration screen.

**Important**: Prompts are cached in memory at application startup. The application does **not** query the database at runtime for prompts. Prompts are only reloaded when changes are detected.

## Architecture

### Caching Strategy

**Backend (Rails)**:
- Prompts are loaded into memory at application startup via `PromptCacheService`
- All runtime access uses the in-memory cache (no database queries)
- Cache automatically reloads when prompts are created, updated, or deleted
- Cache can be manually reloaded via `PromptCacheService.reload`

**Frontend (Flutter)**:
- Prompts are cached in SharedPreferences at app startup
- Cache is checked for updates before each use
- Only fetches from API if cache is stale or missing
- Cache is invalidated after create/update/delete operations

### Database

Prompts are stored in the `prompts` table. See [DATABASE.md](./DATABASE.md) for complete schema documentation.

Key features:
- **Category-based organization**: Prompts are organized by category
- **Version tracking**: Automatic versioning when prompt text changes
- **Active/Inactive**: Toggle prompts on/off without deleting
- **Metadata support**: JSON metadata for additional information

**Note**: While prompts are stored in the database, they are **not queried at runtime**. All services use the cached prompts from `PromptCacheService`.

### Categories

Prompts are organized into the following categories:

1. **system_instructions**: System instructions for AI models (e.g., R.E.E.D. persona)
2. **image_processing**: Image analysis and editing prompts
3. **research**: Price research and location search prompts
4. **chat**: General chat conversation prompts
5. **game_modes**: Game mode-specific behavior adjustments
6. **tool_functions**: Tool function definitions and prompts

### Models

Prompts are associated with specific Gemini AI models:

- `gemini-2.5-flash`: General chat, research with Google Search grounding
- `gemini-flash-lite-latest`: Quick image analysis
- `gemini-2.5-flash-image`: AI image editing
- `gemini-2.5-flash-native-audio-preview-09-2025`: Live voice/video conversations

## Access Control

### Admin Interface

- **URL**: `/admin/prompts`
- **Authentication**: HTTP Basic Auth (admin password)
- **Access**: All admins

### Mobile App Configuration

- **Screen**: Prompts Config Screen
- **Access**: Bootie Bosses and Admins only
- **Navigation**: Tune icon in home screen app bar

### API Endpoints

- **Read**: All authenticated users can read prompts
- **Write**: Only Bootie Bosses and Admins can create, update, or delete prompts

See [API.md](./API.md) for complete API documentation.

## Usage

### Seeding Initial Prompts

Initial prompts are loaded from `AI_PROMPTS.json`:

```bash
cd backend
rails runner db/seeds/prompts_seed.rb
```

This will:
- Read prompts from `AI_PROMPTS.json` in the project root
- Create or update prompts in the database
- Maintain existing prompts if they already exist
- Cache will automatically reload after seeding (via model callbacks)

**Important**: After seeding, the Rails application will automatically reload the cache. If the server is already running, you may need to restart it or manually reload the cache.

### Admin Interface

1. Navigate to `/admin/prompts`
2. View prompts organized by category
3. Click "New Prompt" to create a new prompt
4. Click "Edit" to modify an existing prompt
5. Click "Delete" to remove a prompt

### Mobile App

1. Log in as Bootie Boss or Admin
2. Tap the tune icon in the home screen app bar
3. Browse prompts by category
4. Tap a prompt to edit it
5. Tap the "+" icon to create a new prompt

### Programmatic Access

**Always use PromptCacheService** (not direct database queries):

```ruby
# Get a specific prompt (from cache)
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')

# Get all prompts for a category (from cache)
prompts = PromptCacheService.all_for_category('image_processing')

# Get all prompts (from cache)
all_prompts = PromptCacheService.all

# Get prompts for a specific model (from cache)
model_prompts = PromptCacheService.all_for_model('gemini-2.5-flash')

# Check if cache needs updating
needs_update = PromptCacheService.check_for_updates

# Force reload cache
PromptCacheService.reload
```

**Never use direct database queries at runtime**:
```ruby
# ❌ DON'T DO THIS at runtime
prompt = Prompt.find_by(category: 'system_instructions', name: 'reed_persona')

# ✅ DO THIS instead
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
```

## Prompt Structure

### Required Fields

- `category`: One of the valid categories
- `name`: Unique identifier within the category
- `model`: Gemini model name
- `prompt_text`: The actual prompt text

### Optional Fields

- `description`: Human-readable description
- `use_case`: What the prompt is used for
- `prompt_type`: `system_instruction`, `prompt_template`, or `tool_function`
- `metadata`: JSON object with additional information
- `sort_order`: For ordering in UI (default: 0)
- `active`: Whether the prompt is active (default: true)

### Metadata

The `metadata` field can contain:

- `expected_output`: Expected output format
- `tools`: Required tools (for research prompts)
- `workflow_steps`: Workflow steps (for research prompts)
- `arguments`: Function arguments (for tool functions)
- `execution`: Execution details (for tool functions)
- `reed_behavior`: Behavior adjustments (for game modes)
- `prompt_addition`: Additional prompt text (for game modes)
- `persona`: Persona details (for system instructions)

## Versioning

Prompts are automatically versioned:
- Version starts at 1
- Version increments automatically when `prompt_text` changes
- Version does not increment for other field changes
- Version history is not stored (only current version)

## Best Practices

1. **Use descriptive names**: Prompt names should clearly indicate their purpose
2. **Keep prompts focused**: Each prompt should have a single, clear purpose
3. **Document metadata**: Use the description and metadata fields to document usage
4. **Test changes**: Test prompt changes in a development environment first
5. **Version control**: Consider backing up prompts before making changes
6. **Use categories**: Organize prompts by category for easier management

## Troubleshooting

### Prompt not found

- Check that the prompt is active (`active = true`)
- Verify category and name are correct
- Ensure the prompt exists in the database

### Changes not taking effect

- Verify the prompt is active
- Check that the correct model is being used
- Ensure the service is using the database prompt (not hardcoded)

### Seeding fails

- Verify `AI_PROMPTS.json` exists in the project root
- Check that the JSON file is valid
- Ensure the database migration has been run

## Related Documentation

- [DATABASE.md](./DATABASE.md) - Database schema documentation
- [API.md](./API.md) - API endpoint documentation
- [PROMPTS_CACHE.md](./PROMPTS_CACHE.md) - Caching architecture details
- [AI_PROMPTS.json](../AI_PROMPTS.json) - Source file for initial prompts
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture

## Examples

### Creating a New Prompt (Rails Console)

```ruby
Prompt.create!(
  category: 'image_processing',
  name: 'enhance_colors',
  model: 'gemini-2.5-flash-image',
  prompt_text: 'enhance colors, improve saturation and vibrancy',
  description: 'Enhances image colors',
  use_case: 'Image editing',
  prompt_type: 'prompt_template',
  active: true,
  sort_order: 0
)
```

### Getting a Prompt for Use

```ruby
# In a service object - use cache, not database
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
system_instruction = prompt.prompt_text if prompt

# Example in GeminiLiveService
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
system_instruction = prompt.prompt_text if prompt
```

### Filtering Prompts

```ruby
# Get all active image processing prompts (from cache)
image_prompts = PromptCacheService.all_for_category('image_processing')

# Get prompts for a specific model (from cache)
flash_prompts = PromptCacheService.all_for_model('gemini-2.5-flash')
```

### Cache Management

```ruby
# Check cache statistics
stats = PromptCacheService.stats
# => { cached_count: 25, last_updated_at: ..., categories: [...] }

# Reload cache if changed
PromptCacheService.reload_if_changed

# Force reload
PromptCacheService.reload
```

---

*Last Updated: 2025-01-27*

