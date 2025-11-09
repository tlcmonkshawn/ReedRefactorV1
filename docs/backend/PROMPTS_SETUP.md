# AI Prompts Management - Setup Guide

This guide explains how to set up and use the AI Prompts Management system in R.E.E.D. Bootie Hunter.

## Quick Start

1. **Run the database migration:**
   ```bash
   cd backend
   rails db:migrate
   ```

2. **Seed initial prompts from AI_PROMPTS.json:**
   ```bash
   rails runner db/seeds/prompts_seed.rb
   ```

3. **Access the admin interface:**
   - Navigate to `http://localhost:3000/admin/prompts`
   - Use HTTP Basic Auth (admin password from environment variables)

4. **Access from mobile app:**
   - Log in as Bootie Boss or Admin
   - Tap the tune icon in the home screen app bar
   - Manage prompts on the go

## File Structure

```
backend/
├── db/
│   ├── migrate/
│   │   └── 20250127000001_create_prompts.rb
│   └── seeds/
│       └── prompts_seed.rb
├── app/
│   ├── models/
│   │   └── prompt.rb
│   ├── controllers/
│   │   ├── admin/
│   │   │   └── prompts_controller.rb
│   │   └── api/
│   │       └── v1/
│   │           └── prompts_controller.rb
│   └── views/
│       └── admin/
│           └── prompts/
│               ├── index.html.erb
│               ├── show.html.erb
│               ├── new.html.erb
│               ├── edit.html.erb
│               └── _form.html.erb

frontend/
├── lib/
│   ├── models/
│   │   └── prompt.dart
│   ├── services/
│   │   └── prompt_service.dart
│   └── screens/
│       └── prompts_config_screen.dart

docs/
└── PROMPTS.md              # Complete documentation

AI_PROMPTS.json             # Source file for initial prompts
```

## Database Schema

The `prompts` table stores:
- Category and name (unique together)
- Model name (Gemini model)
- Prompt text (the actual prompt)
- Description, use case, metadata
- Active status, version, sort order

See `docs/DATABASE.md` for complete schema documentation.

## API Endpoints

All endpoints are under `/api/v1/prompts`:

- `GET /api/v1/prompts` - List all prompts (filterable)
- `GET /api/v1/prompts/:id` - Get single prompt
- `GET /api/v1/prompts/get?category=...&name=...` - Get by category and name
- `GET /api/v1/prompts/by_category/:category` - Get prompts by category
- `POST /api/v1/prompts` - Create prompt (Bootie Boss/Admin only)
- `PUT /api/v1/prompts/:id` - Update prompt (Bootie Boss/Admin only)
- `DELETE /api/v1/prompts/:id` - Delete prompt (Bootie Boss/Admin only)

See `docs/API.md` for complete API documentation.

## Categories

Prompts are organized into 6 categories:

1. **system_instructions** - System instructions for AI models (e.g., R.E.E.D. persona)
2. **image_processing** - Image analysis and editing prompts
3. **research** - Price research and location search prompts
4. **chat** - General chat conversation prompts
5. **game_modes** - Game mode-specific behavior adjustments
6. **tool_functions** - Tool function definitions and prompts

## Usage Examples

### Rails Console

```ruby
# Get a prompt
prompt = Prompt.get(category: 'system_instructions', name: 'reed_persona')

# Get all active prompts for a category
prompts = Prompt.for_category('image_processing')

# Create a new prompt
Prompt.create!(
  category: 'image_processing',
  name: 'enhance_colors',
  model: 'gemini-2.5-flash-image',
  prompt_text: 'enhance colors, improve saturation and vibrancy',
  description: 'Enhances image colors',
  active: true
)
```

### Flutter/Dart

```dart
// Get all prompts
final prompts = await promptService.getPrompts();

// Get prompts by category
final imagePrompts = await promptService.getPromptsByCategory('image_processing');

// Get a specific prompt
final prompt = await promptService.getPromptByName('system_instructions', 'reed_persona');

// Create a new prompt
final newPrompt = Prompt(
  id: 0,
  category: 'image_processing',
  name: 'enhance_colors',
  model: 'gemini-2.5-flash-image',
  promptText: 'enhance colors, improve saturation and vibrancy',
  description: 'Enhances image colors',
  active: true,
  version: 1,
  sortOrder: 0,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await promptService.createPrompt(newPrompt);
```

## Versioning

Prompts are automatically versioned:
- Version starts at 1
- Version increments automatically when `prompt_text` changes
- Version does not increment for other field changes
- Only current version is stored (no version history)

## Access Control

- **Read**: All authenticated users can read prompts
- **Write**: Only Bootie Bosses and Admins can create, update, or delete prompts
- **Admin Interface**: Requires HTTP Basic Auth (admin password)

## Troubleshooting

### Migration fails
- Ensure PostgreSQL is running
- Check database connection in `config/database.yml`
- Verify Rails version compatibility

### Seed fails
- Verify `AI_PROMPTS.json` exists in project root
- Check JSON file is valid
- Ensure migration has been run

### Prompts not appearing in app
- Check prompt is active (`active: true`)
- Verify user has Bootie Boss or Admin role
- Check API authentication token is valid

### Changes not taking effect
- Verify prompt is active
- Check correct model is being used
- Ensure service is using database prompt (not hardcoded)

## Related Documentation

- **Complete Documentation**: `docs/PROMPTS.md`
- **API Reference**: `docs/API.md`
- **Database Schema**: `docs/DATABASE.md`
- **Source File**: `AI_PROMPTS.json`

## Support

For questions or issues:
1. Check `docs/PROMPTS.md` for detailed documentation
2. Review `docs/API.md` for API endpoint details
3. Check controller code in `backend/app/controllers/` for implementation details

---

*Last Updated: 2025-01-27*

