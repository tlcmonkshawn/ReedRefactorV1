# R.E.E.D. Bootie Hunter - Prompts Database & User Functions

## Overview

The Prompts system manages all AI prompts and system instructions used throughout the R.E.E.D. application. Prompts are stored in the database, cached in memory for performance, and can be managed through both the admin interface and API endpoints.

## Database Schema

### prompts Table

**Location**: `backend/db/migrate/20250127000001_create_prompts.rb`

**Columns**:

| Column | Type | Null | Default | Description |
|--------|------|------|---------|-------------|
| `id` | bigint | NO | auto | Primary key |
| `category` | string | NO | - | Prompt category (see Categories below) |
| `name` | string | NO | - | Unique identifier within category |
| `model` | string | NO | - | Gemini model name (see Models below) |
| `prompt_text` | text | NO | - | The actual prompt text |
| `description` | text | YES | - | Human-readable description |
| `use_case` | string | YES | - | What this prompt is used for |
| `metadata` | json | YES | - | Additional metadata (see Metadata below) |
| `active` | boolean | NO | `true` | Whether prompt is currently active |
| `version` | integer | NO | `1` | Version number (auto-increments on text changes) |
| `prompt_type` | string | YES | - | Type: `system_instruction`, `prompt_template`, `tool_function` |
| `sort_order` | integer | NO | `0` | For ordering prompts in UI |
| `created_at` | datetime | NO | - | Creation timestamp |
| `updated_at` | datetime | NO | - | Last update timestamp |

**Indexes**:
- `index_prompts_on_category` - Category queries
- `index_prompts_on_name` - Name lookups
- `index_prompts_on_category_and_name` (unique) - Composite unique index
- `index_prompts_on_active` - Active prompts filtering
- `index_prompts_on_prompt_type` - Type filtering

**Constraints**:
- `category` and `name` together must be unique
- `category` must be one of: `system_instructions`, `image_processing`, `research`, `chat`, `game_modes`, `tool_functions`
- `prompt_type` must be one of: `system_instruction`, `prompt_template`, `tool_function` (or null)

### Categories

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
- `gemini-2.5-flash-image`: AI image editing ("Nano Banana")
- `gemini-2.5-flash-native-audio-preview-09-2025`: Live voice/video conversations

### Metadata Structure

The `metadata` JSON column can contain:

```json
{
  "expected_output": "Expected output format",
  "tools": ["tool1", "tool2"],
  "workflow_steps": ["step1", "step2"],
  "arguments": {
    "arg1": "description",
    "arg2": "description"
  },
  "execution": {
    "method": "description",
    "returns": "description"
  },
  "reed_behavior": "Behavior adjustments for game modes",
  "prompt_addition": "Additional prompt text",
  "persona": {
    "traits": ["trait1", "trait2"],
    "style": "description"
  }
}
```

## Prompt Model

**Location**: `backend/app/models/prompt.rb`

### Validations

```ruby
validates :category, presence: true
validates :name, presence: true, uniqueness: { scope: :category }
validates :model, presence: true
validates :prompt_text, presence: true
validates :category, inclusion: { 
  in: %w[system_instructions image_processing research chat game_modes tool_functions]
}
validates :prompt_type, inclusion: { 
  in: %w[system_instruction prompt_template tool_function],
  allow_blank: true
}
```

### Scopes

```ruby
# Active prompts only
Prompt.active

# Filter by category
Prompt.by_category('image_processing')

# Filter by model
Prompt.by_model('gemini-2.5-flash')

# Ordered by sort_order, then name
Prompt.ordered
```

### Class Methods

#### `Prompt.get(category:, name:)`

Get a prompt by category and name (active prompts only).

```ruby
prompt = Prompt.get(category: 'system_instructions', name: 'reed_persona')
# Returns: Prompt object or nil
```

#### `Prompt.for_category(category)`

Get all active prompts for a category, ordered.

```ruby
prompts = Prompt.for_category('image_processing')
# Returns: ActiveRecord::Relation of Prompt objects
```

### Instance Methods

#### `system_instruction?`

Check if this is a system instruction prompt.

```ruby
prompt.system_instruction?
# Returns: true if prompt_type == 'system_instruction' or category == 'system_instructions'
```

#### `prompt_template?`

Check if this is a prompt template.

```ruby
prompt.prompt_template?
# Returns: true if prompt_type == 'prompt_template'
```

#### `tool_function?`

Check if this is a tool function prompt.

```ruby
prompt.tool_function?
# Returns: true if prompt_type == 'tool_function' or category == 'tool_functions'
```

#### `metadata_hash`

Get metadata as a hash (handles JSON column conversion).

```ruby
metadata = prompt.metadata_hash
# Returns: Hash (never nil, always returns at least {})
```

### Callbacks

#### Automatic Versioning

Version automatically increments when `prompt_text` changes:

```ruby
before_update :increment_version, if: :prompt_text_changed?
```

#### Cache Reload

Cache is automatically reloaded when prompts are saved or destroyed:

```ruby
after_save :reload_cache
after_destroy :reload_cache
```

The reload happens in a background thread to avoid blocking the request.

## PromptCacheService

**Location**: `backend/app/services/prompt_cache_service.rb`

**Purpose**: In-memory cache of all active prompts to avoid database queries at runtime.

### Initialization

Cache is automatically loaded at Rails startup via `config/initializers/prompt_cache.rb`:

```ruby
Rails.application.config.after_initialize do
  PromptCacheService.load! if ActiveRecord::Base.connection.table_exists?('prompts')
end
```

### Class Methods

#### `PromptCacheService.load!`

Load all active prompts into cache. Called automatically at startup.

```ruby
PromptCacheService.load!
# Loads all active prompts and stores in memory
# Updates @@last_updated_at timestamp
```

#### `PromptCacheService.get(category:, name:)`

Get a prompt by category and name from cache.

```ruby
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
# Returns: Prompt object or nil
# Key format: "category:name"
```

#### `PromptCacheService.all_for_category(category)`

Get all prompts for a category from cache.

```ruby
prompts = PromptCacheService.all_for_category('image_processing')
# Returns: Array of Prompt objects
```

#### `PromptCacheService.all`

Get all prompts from cache.

```ruby
all_prompts = PromptCacheService.all
# Returns: Array of all Prompt objects
```

#### `PromptCacheService.all_for_model(model)`

Get all prompts for a specific model from cache.

```ruby
prompts = PromptCacheService.all_for_model('gemini-2.5-flash')
# Returns: Array of Prompt objects for that model
```

#### `PromptCacheService.check_for_updates`

Check if prompts have been updated since last cache load.

```ruby
needs_update = PromptCacheService.check_for_updates
# Returns: true if updates are needed, false otherwise
```

#### `PromptCacheService.reload_if_changed`

Reload prompts from database only if they've changed.

```ruby
reloaded = PromptCacheService.reload_if_changed
# Returns: true if reloaded, false if up to date
```

#### `PromptCacheService.reload`

Force reload all prompts from database.

```ruby
PromptCacheService.reload
# Always reloads, even if no changes detected
```

#### `PromptCacheService.stats`

Get cache statistics.

```ruby
stats = PromptCacheService.stats
# Returns: {
#   cached_count: 42,
#   last_updated_at: 2025-01-27 12:00:00 UTC,
#   categories: ["chat", "game_modes", "image_processing", ...]
# }
```

#### `PromptCacheService.clear`

Clear the cache (useful for testing).

```ruby
PromptCacheService.clear
# Clears cache and resets @@last_updated_at
```

### Cache Key Format

Prompts are stored in cache with keys: `"category:name"`

Example: `"system_instructions:reed_persona"`

### Thread Safety

All cache operations use a mutex (`@@mutex`) to ensure thread safety.

## API Controller Methods

**Location**: `backend/app/controllers/api/v1/prompts_controller.rb`

### Authentication & Authorization

- **Read operations** (`index`, `show`, `get`, `by_category`): All authenticated users
- **Write operations** (`create`, `update`, `destroy`): Bootie Bosses and Admins only

### Action Methods

#### `index`

Get all prompts with optional filtering.

```ruby
GET /api/v1/prompts?category=image_processing&model=gemini-2.5-flash
```

- Uses cache (`PromptCacheService.all`)
- Filters by category and/or model if provided
- Sorts by `sort_order`, then `name`
- Returns JSON array of prompts

#### `show`

Get a single prompt by ID.

```ruby
GET /api/v1/prompts/:id
```

- Tries cache first, falls back to database
- Returns JSON prompt object

#### `create`

Create a new prompt.

```ruby
POST /api/v1/prompts
```

- Requires Bootie Boss or Admin role
- Creates prompt in database
- Automatically reloads cache (via model callback)
- Returns JSON prompt object

#### `update`

Update an existing prompt.

```ruby
PUT /api/v1/prompts/:id
```

- Requires Bootie Boss or Admin role
- Updates prompt in database
- Version auto-increments if `prompt_text` changed
- Automatically reloads cache (via model callback)
- Returns JSON prompt object

#### `destroy`

Delete a prompt.

```ruby
DELETE /api/v1/prompts/:id
```

- Requires Bootie Boss or Admin role
- Deletes prompt from database
- Automatically reloads cache (via model callback)
- Returns success message

#### `get`

Get a prompt by category and name (from cache).

```ruby
GET /api/v1/prompts/get?category=system_instructions&name=reed_persona
```

- Uses cache (`PromptCacheService.get`)
- Returns JSON prompt object or 404 error

#### `by_category`

Get all prompts for a category (from cache).

```ruby
GET /api/v1/prompts/by_category/image_processing
```

- Uses cache (`PromptCacheService.all_for_category`)
- Returns JSON array of prompts

## Usage Examples

### Getting a Prompt in Service Objects

**Always use PromptCacheService** (not direct database queries):

```ruby
# ✅ Correct - uses cache
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
system_instruction = prompt.prompt_text if prompt&.active?

# ❌ Wrong - database query at runtime
prompt = Prompt.find_by(category: 'system_instructions', name: 'reed_persona')
```

### Getting All Prompts for a Category

```ruby
# From cache
image_prompts = PromptCacheService.all_for_category('image_processing')

# All active, ordered
image_prompts = PromptCacheService.all_for_category('image_processing').sort_by(&:sort_order)
```

### Getting Prompts for a Model

```ruby
# All prompts for Gemini Live API
live_prompts = PromptCacheService.all_for_model('gemini-2.5-flash-native-audio-preview-09-2025')
```

### Creating a New Prompt

```ruby
prompt = Prompt.create!(
  category: 'image_processing',
  name: 'enhance_colors',
  model: 'gemini-2.5-flash-image',
  prompt_text: 'enhance colors, improve saturation and vibrancy',
  description: 'Enhances image colors',
  use_case: 'Image editing',
  prompt_type: 'prompt_template',
  active: true,
  sort_order: 0,
  metadata: {
    expected_output: 'Enhanced image with improved colors'
  }
)
# Cache automatically reloads
```

### Updating a Prompt

```ruby
prompt = Prompt.find_by(category: 'image_processing', name: 'enhance_colors')
prompt.update!(prompt_text: 'enhance colors with improved saturation and vibrancy')
# Version auto-increments
# Cache automatically reloads
```

### Checking Cache Status

```ruby
# Check if cache needs updating
if PromptCacheService.check_for_updates
  PromptCacheService.reload
end

# Get cache statistics
stats = PromptCacheService.stats
puts "Cached #{stats[:cached_count]} prompts"
puts "Last updated: #{stats[:last_updated_at]}"
puts "Categories: #{stats[:categories].join(', ')}"
```

## Best Practices

### 1. Always Use Cache at Runtime

**Never query the database directly for prompts at runtime:**

```ruby
# ❌ DON'T DO THIS
prompt = Prompt.find_by(category: 'system_instructions', name: 'reed_persona')

# ✅ DO THIS
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
```

### 2. Check for Active Prompts

Always check if a prompt is active before using it:

```ruby
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
if prompt&.active?
  # Use prompt.prompt_text
end
```

### 3. Handle Missing Prompts Gracefully

```ruby
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
if prompt.nil?
  Rails.logger.warn "Prompt not found: system_instructions:reed_persona"
  # Use default or raise error
end
```

### 4. Use Metadata for Additional Context

Store structured data in metadata:

```ruby
prompt = Prompt.create!(
  category: 'research',
  name: 'price_research',
  model: 'gemini-2.5-flash',
  prompt_text: 'Research the price of...',
  metadata: {
    tools: ['googleSearch'],
    expected_output: 'JSON with price and reasoning',
    workflow_steps: ['search', 'analyze', 'extract']
  }
)
```

### 5. Version Tracking

Version automatically increments when `prompt_text` changes. Use this to track changes:

```ruby
prompt = PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')
puts "Using version #{prompt.version} of #{prompt.name}"
```

## Database Queries

### Direct Database Access (Development/Admin Only)

For development, admin tasks, or seeding:

```ruby
# Get all prompts (including inactive)
all_prompts = Prompt.all

# Get inactive prompts
inactive = Prompt.where(active: false)

# Get prompts by version
old_version = Prompt.where('version < ?', 5)

# Get prompts updated recently
recent = Prompt.where('updated_at > ?', 1.day.ago)
```

**Note**: Never use direct database queries in production service objects or controllers. Always use `PromptCacheService`.

## Related Documentation

- [PROMPTS.md](./PROMPTS.md) - Prompts management system overview
- [PROMPTS_CACHE.md](./PROMPTS_CACHE.md) - Caching architecture details
- [DATABASE.md](./DATABASE.md) - Complete database schema documentation
- [API.md](./API.md) - API endpoint documentation

---

*Last Updated: 2025-01-27*

