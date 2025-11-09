# R.E.E.D. Bootie Hunter - API Documentation

## Base URL

**Development**: `http://localhost:3000`  
**Production**: `https://your-app.onrender.com`

All API endpoints are under the `/api/v1/` namespace.

## Authentication

The API uses JWT (JSON Web Token) authentication. Include the token in the Authorization header:

```
Authorization: Bearer <token>
```

Tokens are obtained via the `/api/v1/auth/login` or `/api/v1/auth/register` endpoints.

---

## Authentication Endpoints

### POST /api/v1/auth/register

Register a new user account.

**Request Body**:
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "John Doe",
    "phone_number": "+1234567890"
  }
}
```

**Response** (201 Created):
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "agent",
    "total_points": 0,
    "total_items_scanned": 0
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:
- `422 Unprocessable Entity`: Validation errors
```json
{
  "error": {
    "message": "Email has already been taken",
    "code": "VALIDATION_ERROR"
  }
}
```

---

### POST /api/v1/auth/login

Authenticate and get JWT token.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "agent",
    "total_points": 100,
    "total_items_scanned": 5
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid credentials
```json
{
  "error": {
    "message": "Invalid email or password",
    "code": "INVALID_CREDENTIALS"
  }
}
```

---

### GET /api/v1/auth/me

Get current authenticated user information.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "agent",
    "total_points": 100,
    "total_items_scanned": 5
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or missing token

---

### POST /api/v1/auth/logout

Logout current user (invalidates token).

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "message": "Logged out successfully"
}
```

---

### POST /api/v1/auth/refresh

Refresh JWT token (if token refresh is implemented).

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-01-01T14:00:00Z"
}
```

---

## Booties Endpoints

### GET /api/v1/booties

Get list of Booties with optional filters.

**Headers**: `Authorization: Bearer <token>`

**Query Parameters**:
- `status` (optional): Filter by status (`captured`, `submitted`, `researching`, `researched`, `finalized`)
- `category` (optional): Filter by category
- `location_id` (optional): Filter by location
- `user_id` (optional): Filter by user (admin only)

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "title": "Vintage Vinyl Record",
    "description": "Pink Floyd - Dark Side of the Moon",
    "category": "collectibles",
    "status": "researched",
    "recommended_bounty": 25.00,
    "final_bounty": null,
    "primary_image_url": "https://example.com/image.jpg",
    "alternate_image_urls": [],
    "edited_image_urls": [],
    "location": {
      "id": 1,
      "name": "Downtown Store"
    },
    "created_at": "2025-01-01T12:00:00Z",
    "finalized_at": null
  }
]
```

**Note**: Non-admin users only see their own Booties unless `user_id` is specified (and they're admin).

---

### GET /api/v1/booties/:id

Get a single Bootie by ID.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "id": 1,
  "title": "Vintage Vinyl Record",
  "description": "Pink Floyd - Dark Side of the Moon",
  "category": "collectibles",
  "status": "researched",
  "recommended_bounty": 25.00,
  "final_bounty": null,
  "primary_image_url": "https://example.com/image.jpg",
  "alternate_image_urls": [],
  "edited_image_urls": [],
  "location": {
    "id": 1,
    "name": "Downtown Store"
  },
  "created_at": "2025-01-01T12:00:00Z",
  "finalized_at": null
}
```

**Error Responses**:
- `404 Not Found`: Bootie not found
- `403 Forbidden`: Not authorized to view this Bootie

---

### POST /api/v1/booties

Create a new Bootie.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "bootie": {
    "title": "Vintage Vinyl Record",
    "description": "Pink Floyd - Dark Side of the Moon",
    "category": "collectibles",
    "location_id": 1,
    "primary_image_url": "https://example.com/image.jpg",
    "alternate_image_urls": []
  }
}
```

**Response** (201 Created):
```json
{
  "id": 1,
  "title": "Vintage Vinyl Record",
  "description": "Pink Floyd - Dark Side of the Moon",
  "category": "collectibles",
  "status": "captured",
  "recommended_bounty": null,
  "final_bounty": null,
  "primary_image_url": "https://example.com/image.jpg",
  "alternate_image_urls": [],
  "edited_image_urls": [],
  "location": {
    "id": 1,
    "name": "Downtown Store"
  },
  "created_at": "2025-01-01T12:00:00Z",
  "finalized_at": null
}
```

**Error Responses**:
- `422 Unprocessable Entity`: Validation errors

---

### PUT /api/v1/booties/:id

Update a Bootie.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "bootie": {
    "title": "Updated Title",
    "description": "Updated description",
    "category": "antiques"
  }
}
```

**Response** (200 OK): Same format as GET /api/v1/booties/:id

**Error Responses**:
- `404 Not Found`: Bootie not found
- `403 Forbidden`: Not authorized to update this Bootie
- `422 Unprocessable Entity`: Validation errors

---

### DELETE /api/v1/booties/:id

Delete a Bootie.

**Headers**: `Authorization: Bearer <token>`

**Response** (204 No Content)

**Error Responses**:
- `404 Not Found`: Bootie not found
- `403 Forbidden`: Not authorized to delete this Bootie

---

### POST /api/v1/booties/:id/finalize

Finalize a Bootie to Square catalog. Only Bootie Bosses and Admins can finalize.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "final_bounty": 25.00
}
```

**Response** (200 OK):
```json
{
  "id": 1,
  "title": "Vintage Vinyl Record",
  "status": "finalized",
  "final_bounty": 25.00,
  "finalized_at": "2025-01-01T13:00:00Z",
  ...
}
```

**Error Responses**:
- `403 Forbidden`: User cannot finalize Booties
- `400 Bad Request`: Bootie not ready for finalization or missing final_bounty
- `500 Internal Server Error`: Square API error

---

### POST /api/v1/booties/:id/research

Trigger research for a Bootie (if not already researching/completed).

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "message": "Research started"
}
```

**Error Responses**:
- `400 Bad Request`: Research cannot be started (e.g., already researching)
- `500 Internal Server Error`: Research service error

---

### GET /api/v1/booties/:id/research

Get research results for a Bootie.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "recommended_bounty": 25.00,
  "research_summary": "Based on current market prices...",
  "research_reasoning": "Similar items sold for $20-30...",
  "research_completed_at": "2025-01-01T12:30:00Z"
}
```

---

### GET /api/v1/booties/:id/research/logs

Get research logs for a Bootie.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "bootie_id": 1,
    "query": "Pink Floyd Dark Side of the Moon vinyl record price",
    "response": "Research completed...",
    "research_method": "gemini_google_search",
    "success": true,
    "created_at": "2025-01-01T12:15:00Z"
  }
]
```

---

### GET /api/v1/booties/:id/research/sources

Get grounding sources (citations) for research.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "bootie_id": 1,
    "title": "Pink Floyd Vinyl Prices",
    "url": "https://example.com/pricing",
    "snippet": "Dark Side of the Moon typically sells for...",
    "source_type": "google_search"
  }
]
```

---

## Categories Endpoints

### GET /api/v1/categories

Get all available Bootie categories.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  "used_goods",
  "antiques",
  "electronics",
  "collectibles",
  "weaponry",
  "artifacts",
  "data_logs",
  "miscellaneous"
]
```

---

## Image Endpoints

### POST /api/v1/images/upload

Upload an image file.

**Headers**: `Authorization: Bearer <token>`

**Request**: Multipart form data with `image` file

**Response** (200 OK):
```json
{
  "image_url": "https://example.com/uploads/image.jpg",
  "uploaded_at": "2025-01-01T12:00:00Z"
}
```

---

### POST /api/v1/images/process

Process an image with AI (editing, enhancement, etc.).

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "image_url": "https://example.com/image.jpg",
  "prompt": "remove background, white background",
  "processing_type": "background_removal"
}
```

**Response** (200 OK):
```json
{
  "processed_image_url": "https://example.com/processed/image.jpg",
  "status": "completed"
}
```

---

## Conversations & Messages Endpoints

### GET /api/v1/conversations

Get all conversations for the current user.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "conversation_type": "reed",
    "participant_type": "system",
    "context_summary": "Conversation about Bootie capture",
    "last_message_at": "2025-01-01T12:00:00Z",
    "created_at": "2025-01-01T10:00:00Z"
  }
]
```

---

### GET /api/v1/conversations/:id

Get a specific conversation with messages.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "id": 1,
  "conversation_type": "reed",
  "messages": [
    {
      "id": 1,
      "sender_type": "user",
      "content": "Hello R.E.E.D.",
      "message_type": "text",
      "created_at": "2025-01-01T10:00:00Z"
    },
    {
      "id": 2,
      "sender_type": "reed",
      "content": "Hey there! What've you got for me today?",
      "message_type": "text",
      "created_at": "2025-01-01T10:00:05Z"
    }
  ]
}
```

---

### POST /api/v1/conversations

Create a new conversation.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "conversation": {
    "conversation_type": "reed",
    "context_summary": "Starting new conversation"
  }
}
```

**Response** (201 Created): Conversation object (same format as GET /api/v1/conversations/:id)

---

### GET /api/v1/conversations/:conversation_id/messages

Get messages for a conversation.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "sender_type": "user",
    "content": "Hello",
    "message_type": "text",
    "created_at": "2025-01-01T10:00:00Z"
  }
]
```

---

### POST /api/v1/conversations/:conversation_id/messages

Send a message in a conversation.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "message": {
    "content": "Hello R.E.E.D.",
    "message_type": "text"
  }
}
```

**Response** (201 Created): Message object (same format as GET messages)

---

## Game Modes Endpoints

### POST /api/v1/game_modes/scour/start

Start a S.C.O.U.R. (Speed Run) game session.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "duration_minutes": 5
}
```

**Response** (200 OK):
```json
{
  "game_session_id": 1,
  "status": "active",
  "started_at": "2025-01-01T12:00:00Z"
}
```

---

### POST /api/v1/game_modes/scour/complete

Complete a S.C.O.U.R. game session.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "game_session_id": 1,
  "items_processed": 15
}
```

**Response** (200 OK):
```json
{
  "game_session_id": 1,
  "status": "completed",
  "score": 150,
  "items_processed": 15,
  "completed_at": "2025-01-01T12:05:00Z"
}
```

---

### POST /api/v1/game_modes/locus/start

Start a L.O.C.U.S. (Location Audit) game session.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "location_id": 1,
  "sub_location": "Aisle 3"
}
```

**Response** (200 OK):
```json
{
  "game_session_id": 2,
  "status": "active",
  "started_at": "2025-01-01T12:00:00Z"
}
```

---

### POST /api/v1/game_modes/locus/complete

Complete a L.O.C.U.S. game session.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "game_session_id": 2,
  "items_processed": 25
}
```

**Response** (200 OK):
```json
{
  "game_session_id": 2,
  "status": "completed",
  "score": 250,
  "items_processed": 25,
  "completed_at": "2025-01-01T12:30:00Z"
}
```

---

### GET /api/v1/game_modes/tag/current

Get the current T.A.G. (Targeted Acquisition Game) item.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "tag_item": {
    "bootie_id": 42,
    "title": "Vintage Pink Floyd Vinyl",
    "category": "collectibles",
    "hint": "Found in the music section"
  },
  "expires_at": "2025-01-02T00:00:00Z"
}
```

---

## Social Sharing Endpoints

### POST /api/v1/booties/:id/share

Share a Bootie to social media or community.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "platforms": ["twitter", "facebook"],
  "message": "Check out this amazing find!"
}
```

**Response** (200 OK):
```json
{
  "message": "Bootie shared successfully",
  "shared_to": ["twitter", "facebook"]
}
```

---

## System Configuration Endpoints

### GET /api/v1/config

Get system configuration for the current user.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "role": "agent"
  },
  "location": {
    "id": 1,
    "name": "Downtown Store"
  },
  "settings": {
    "auto_research": true,
    "notifications_enabled": true
  }
}
```

---

### PUT /api/v1/config

Update system configuration for the current user.

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "config": {
    "location_id": 1,
    "settings": {
      "auto_research": false,
      "notifications_enabled": true
    }
  }
}
```

**Response** (200 OK): Same format as GET /api/v1/config

---

## Locations Endpoints

### GET /api/v1/locations

Get list of all locations.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "name": "Downtown Store",
    "address": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip_code": "12345",
    "phone_number": "+1234567890",
    "email": "store@example.com",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "active": true,
    "created_at": "2025-01-01T10:00:00Z"
  }
]
```

---

### GET /api/v1/locations/:id

Get a single location by ID.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Same format as list endpoint (single object)

---

### POST /api/v1/locations

Create a new location (Admin only).

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "location": {
    "name": "New Store",
    "address": "456 Oak Ave",
    "city": "Somewhere",
    "state": "CA",
    "zip_code": "54321",
    "phone_number": "+1987654321",
    "email": "newstore@example.com",
    "latitude": 37.7849,
    "longitude": -122.4094
  }
}
```

**Response** (201 Created): Same format as GET endpoint

---

## Gemini Live API Endpoints

### POST /api/v1/gemini_live/session

Create a Gemini Live API session token.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "session_token": "session_token_here",
  "expires_at": "2025-01-01T14:00:00Z"
}
```

**Note**: This endpoint generates a session token for the frontend to connect directly to Gemini Live API. The token is short-lived and scoped to the user.

---

### POST /api/v1/gemini_live/tool_call

Execute a tool call from Gemini Live API (proxy endpoint).

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "tool_name": "take_snapshot",
  "parameters": {
    "image_url": "https://example.com/image.jpg",
    "title": "Item Title",
    "description": "Item Description"
  }
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "result": {
    "bootie_id": 1,
    "status": "captured"
  }
}
```

**Available Tools**:
- `take_snapshot`: Capture a Bootie from image
- `search_memory`: Search Booties and conversation history
- `get_pending_booties`: Get Booties awaiting attention
- `edit_image`: Process image editing request

---

## Gamification Endpoints

### GET /api/v1/leaderboards

Get overall leaderboards (default).

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "user_id": 1,
    "user_name": "John Doe",
    "points": 1000,
    "rank": 1
  },
  {
    "user_id": 2,
    "user_name": "Jane Smith",
    "points": 850,
    "rank": 2
  }
]
```

---

### GET /api/v1/leaderboards/daily

Get daily leaderboards.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Same format as GET /api/v1/leaderboards

---

### GET /api/v1/leaderboards/weekly

Get weekly leaderboards.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Same format as GET /api/v1/leaderboards

---

### GET /api/v1/leaderboards/monthly

Get monthly leaderboards.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Same format as GET /api/v1/leaderboards

---

### GET /api/v1/leaderboards/overall

Get overall/all-time leaderboards.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Same format as GET /api/v1/leaderboards

---

### GET /api/v1/scores

Get scores for the current user.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "action_type": "bootie_captured",
    "points": 10,
    "bootie_id": 1,
    "created_at": "2025-01-01T12:00:00Z"
  }
]
```

---

### GET /api/v1/scores/:id

Get a specific score by ID.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Single score object (same format as array item above)

---

### GET /api/v1/achievements

Get all achievements.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "name": "First Bootie",
    "description": "Capture your first Bootie",
    "badge_icon_url": "https://example.com/badge.png",
    "achievement_type": "milestone",
    "points_required": 0,
    "active": true
  }
]
```

---

### GET /api/v1/achievements/:id

Get a specific achievement by ID.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Single achievement object (same format as array item above)

---

## Prompts Endpoints

Manage AI prompts and system instructions. Only Bootie Bosses and Admins can create, update, or delete prompts.

### GET /api/v1/prompts

Get all prompts, optionally filtered by category or model.

**Headers**: `Authorization: Bearer <token>`

**Query Parameters**:
- `category` (optional): Filter by category (`system_instructions`, `image_processing`, `research`, `chat`, `game_modes`, `tool_functions`)
- `model` (optional): Filter by Gemini model name

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "category": "system_instructions",
    "name": "reed_persona",
    "model": "gemini-2.5-flash-native-audio-preview-09-2025",
    "prompt_text": "You are R.E.E.D. 8...",
    "description": "System instructions for R.E.E.D. persona",
    "use_case": "Live voice and video conversations",
    "metadata": {
      "persona": {...}
    },
    "active": true,
    "version": 1,
    "prompt_type": "system_instruction",
    "sort_order": 0,
    "created_at": "2025-01-27T00:00:00Z",
    "updated_at": "2025-01-27T00:00:00Z"
  }
]
```

---

### GET /api/v1/prompts/:id

Get a single prompt by ID.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "id": 1,
  "category": "system_instructions",
  "name": "reed_persona",
  "model": "gemini-2.5-flash-native-audio-preview-09-2025",
  "prompt_text": "You are R.E.E.D. 8...",
  "description": "System instructions for R.E.E.D. persona",
  "use_case": "Live voice and video conversations",
  "metadata": {...},
  "active": true,
  "version": 1,
  "prompt_type": "system_instruction",
  "sort_order": 0,
  "created_at": "2025-01-27T00:00:00Z",
  "updated_at": "2025-01-27T00:00:00Z"
}
```

**Error Responses**:
- `404 Not Found`: Prompt not found

---

### GET /api/v1/prompts/get

Get a prompt by category and name.

**Headers**: `Authorization: Bearer <token>`

**Query Parameters**:
- `category` (required): Prompt category
- `name` (required): Prompt name

**Response** (200 OK): Same as GET /api/v1/prompts/:id

**Error Responses**:
- `404 Not Found`: Prompt not found

---

### GET /api/v1/prompts/by_category/:category

Get all prompts for a specific category.

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK): Array of prompts (same format as GET /api/v1/prompts)

---

### POST /api/v1/prompts

Create a new prompt. **Requires Bootie Boss or Admin role.**

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "prompt": {
    "category": "image_processing",
    "name": "remove_background",
    "model": "gemini-2.5-flash-image",
    "prompt_text": "remove the background, keep only the main subject",
    "description": "Removes background from image",
    "use_case": "Image editing",
    "prompt_type": "prompt_template",
    "active": true,
    "sort_order": 0,
    "metadata": {}
  }
}
```

**Response** (201 Created): Same as GET /api/v1/prompts/:id

**Error Responses**:
- `403 Forbidden`: Insufficient permissions (must be Bootie Boss or Admin)
- `422 Unprocessable Entity`: Validation errors

---

### PUT /api/v1/prompts/:id

Update an existing prompt. **Requires Bootie Boss or Admin role.**

**Headers**: `Authorization: Bearer <token>`

**Request Body**: Same as POST /api/v1/prompts

**Response** (200 OK): Same as GET /api/v1/prompts/:id

**Error Responses**:
- `403 Forbidden`: Insufficient permissions (must be Bootie Boss or Admin)
- `404 Not Found`: Prompt not found
- `422 Unprocessable Entity`: Validation errors

**Note**: Version automatically increments when `prompt_text` changes.

---

### DELETE /api/v1/prompts/:id

Delete a prompt. **Requires Bootie Boss or Admin role.**

**Headers**: `Authorization: Bearer <token>`

**Response** (200 OK):
```json
{
  "message": "Prompt deleted successfully"
}
```

**Error Responses**:
- `403 Forbidden`: Insufficient permissions (must be Bootie Boss or Admin)
- `404 Not Found`: Prompt not found

---

## Health Check

### GET /health

Check if the API is running.

**Response** (200 OK):
```json
{
  "status": "ok",
  "timestamp": "2025-01-01T12:00:00Z"
}
```

---

## Error Response Format

All errors follow this format:

```json
{
  "error": {
    "message": "Human-readable error message",
    "code": "ERROR_CODE"
  }
}
```

**Common Error Codes**:
- `VALIDATION_ERROR`: Validation failed
- `INVALID_CREDENTIALS`: Authentication failed
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Missing or invalid token

---

## Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `204 No Content`: Successful deletion
- `400 Bad Request`: Invalid request
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

---

*For implementation details, see controller code in `backend/app/controllers/api/v1/`.*

---

*Last Updated: 2025-01-27*

