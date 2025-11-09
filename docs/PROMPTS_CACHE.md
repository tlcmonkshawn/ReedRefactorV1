# Prompts Cache Architecture

## Overview

The prompts system uses a two-tier caching strategy to ensure prompts are never queried from the database at runtime:

1. **Backend Cache**: In-memory cache loaded at Rails startup
2. **Frontend Cache**: SharedPreferences cache loaded at Flutter app startup

## Backend Caching (Rails)

### PromptCacheService

The `PromptCacheService` is a singleton service that maintains an in-memory cache of all active prompts.

**Initialization**:
- Automatically loads at Rails startup via `config/initializers/prompt_cache.rb`
- Loads all active prompts from database once
- Stores in memory as a hash: `{ "category:name" => Prompt }`

**Access Methods**:
```ruby
# Get a specific prompt
PromptCacheService.get(category: 'system_instructions', name: 'reed_persona')

# Get all prompts for a category
PromptCacheService.all_for_category('image_processing')

# Get all prompts
PromptCacheService.all

# Get prompts for a model
PromptCacheService.all_for_model('gemini-2.5-flash')
```

**Cache Invalidation**:
- Automatically reloads when prompts are created/updated/deleted (via model callbacks)
- Can check if updates are needed: `PromptCacheService.check_for_updates`
- Can force reload: `PromptCacheService.reload`

### Cache Reload Mechanism

The cache is automatically reloaded when:
1. A prompt is created (`after_save` callback)
2. A prompt is updated (`after_save` callback)
3. A prompt is deleted (`after_destroy` callback)

The reload happens in a background thread to avoid blocking the request.

### API Endpoints

The API endpoints use the cache instead of database queries:
- `GET /api/v1/prompts` - Returns cached prompts
- `GET /api/v1/prompts/get` - Looks up prompt in cache
- `GET /api/v1/prompts/by_category/:category` - Filters cached prompts

## Frontend Caching (Flutter)

### PromptService Cache

The Flutter `PromptService` maintains a local cache in SharedPreferences.

**Initialization**:
- Loads from SharedPreferences at app startup (non-blocking)
- If cache exists, uses it immediately
- Checks for updates on first use

**Cache Strategy**:
1. **Load from cache**: If cache exists, use it immediately
2. **Check for updates**: Before using, check if server has newer prompts
3. **Fetch if needed**: Only fetch from API if cache is stale or missing
4. **Save to cache**: Store fetched prompts in SharedPreferences

**Update Check**:
- Calls `GET /api/v1/prompt_cache/check_updates`
- Compares `last_updated_at` timestamp with cached version
- Only fetches if timestamps don't match

### Cache Invalidation

The cache is invalidated when:
- Prompts are created/updated/deleted (sets `_cachedPrompts = null`)
- `forceRefresh: true` is passed to `getPrompts()`
- `checkForUpdates()` returns true

## Benefits

1. **Performance**: No database queries at runtime
2. **Scalability**: Reduces database load
3. **Offline Support**: Frontend can work with cached prompts
4. **Fast Access**: In-memory access is instant

## Cache Consistency

- **Backend**: Cache is automatically reloaded on changes
- **Frontend**: Cache is checked for updates before use
- **Timestamps**: Both systems track `updated_at` to detect changes

## Manual Cache Management

### Backend

```ruby
# Check if cache needs updating
PromptCacheService.check_for_updates

# Force reload
PromptCacheService.reload

# Get cache stats
PromptCacheService.stats
```

### Frontend

```dart
// Clear local cache
await promptService.clearCache();

// Force refresh
await promptService.getPrompts(forceRefresh: true);

// Check for updates
bool needsUpdate = await promptService.checkForUpdates();
```

## Troubleshooting

### Cache Not Updating

- Check that model callbacks are firing (check Rails logs)
- Verify `PromptCacheService.reload` is being called
- Check frontend `checkForUpdates()` is working

### Stale Data

- Backend: Call `PromptCacheService.reload`
- Frontend: Call `promptService.getPrompts(forceRefresh: true)`

### Cache Not Loading at Startup

- Check Rails logs for initialization errors
- Verify `prompts` table exists
- Check Flutter logs for cache load errors

---

*Last Updated: 2025-01-27*

