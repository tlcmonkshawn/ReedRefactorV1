# Gemini Live API Architecture

## Overview

The Gemini Live API integration uses a **hybrid architecture** where the frontend and backend handle different responsibilities. This document explains why and how.

## Architecture Diagram

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Flutter   │◄───────►│ Gemini Live  │         │   Rails     │
│  Frontend   │ WebSocket│     API      │         │   Backend   │
│             │         │  (Google)    │         │             │
└─────────────┘         └──────────────┘         └─────────────┘
      │                                                  │
      │ 1. Request session token                         │
      ├─────────────────────────────────────────────────►│
      │                                                  │
      │ 2. Return session token                          │
      │◄─────────────────────────────────────────────────┤
      │                                                  │
      │ 3. WebSocket connection (direct)                 │
      ├─────────────────────────────────────────────────►│
      │                                                  │
      │ 4. Audio/Video streaming (direct)                │
      │◄─────────────────────────────────────────────────┤
      │                                                  │
      │ 5. Tool call (via frontend)                      │
      ├─────────────────────────────────────────────────►│
      │                                                  │
      │ 6. Tool result                                   │
      │◄─────────────────────────────────────────────────┤
```

## Why This Architecture?

### 1. Security
- **API keys never exposed to frontend**: The Gemini API key stays on the backend
- **Secure token exchange**: Frontend gets a time-limited session token
- **Backend-controlled tool execution**: Sensitive operations run server-side

### 2. Performance
- **Lower latency**: Media streams bypass backend (direct WebSocket to Gemini)
- **Reduced server load**: No proxying of audio/video data
- **Better user experience**: Real-time communication without backend bottlenecks

### 3. Functionality
- **Database access**: Tool calls need PostgreSQL access
- **Cross-service integration**: Tools may call other services (Square, Discogs, etc.)
- **Sensitive operations**: Creating Booties, finalizing items, etc.

## How It Works

### Step 1: Session Token Generation

**Frontend** → `POST /api/v1/gemini_live/session` → **Backend**

Backend generates a session token using the secure Gemini API key.

```ruby
# Backend: GeminiLiveService#create_session
result = GeminiLiveService.call(user: current_user).create_session
# Returns: { session_token: "...", expires_at: "..." }
```

### Step 2: Direct WebSocket Connection

**Frontend** → WebSocket → **Gemini Live API** (direct connection)

Frontend uses the session token to establish a WebSocket connection directly to Gemini Live API. All audio/video streaming happens here.

### Step 3: Tool Call Execution

When R.E.E.D. calls a tool during conversation:

1. **Gemini Live API** → Tool call request → **Frontend**
2. **Frontend** → `POST /api/v1/gemini_live/tool_call` → **Backend**
3. **Backend** → Executes tool (database, services) → Returns result
4. **Frontend** → Tool result → **Gemini Live API**

## Available Tools

### `take_snapshot`
Creates a new Bootie from an AI-captured image during a video call.

**Arguments:**
```json
{
  "image_url": "...",
  "description": "...",
  "location_id": 123
}
```

**Backend Execution:**
- Creates Bootie record in database
- Triggers image analysis
- Returns Bootie details

### `search_memory`
Searches conversation history and context for the user.

**Arguments:**
```json
{
  "query": "vinyl records",
  "limit": 10
}
```

**Backend Execution:**
- Searches conversations table
- Searches messages table
- Searches Booties table
- Returns relevant results

### `get_pending_booties`
Returns list of Booties that need attention.

**Arguments:**
```json
{
  "status": "researched"  // optional
}
```

**Backend Execution:**
- Queries Booties for user
- Filters by status
- Returns list

### `edit_image`
Performs AI-powered image editing (e.g., remove background).

**Arguments:**
```json
{
  "image_url": "...",
  "prompt": "remove background"
}
```

**Backend Execution:**
- Calls ImageProcessingService
- Uses Gemini 2.5 Flash Image model
- Returns edited image URL

## Implementation Files

### Backend
- `app/services/gemini_live_service.rb` - Service object with detailed documentation
- `app/controllers/api/v1/gemini_live_controller.rb` - API endpoints

### Frontend
- `lib/services/gemini_live_service.dart` - WebSocket connection and tool call forwarding (to be implemented)

## Security Considerations

1. **Session tokens are time-limited** - Expire after a set period
2. **Tool calls are authenticated** - Require valid user session
3. **API keys in environment variables** - Never in code
4. **Tool execution is logged** - All tool calls are recorded

## Performance Considerations

1. **Media streams bypass backend** - Direct WebSocket to Gemini
2. **Tool calls are asynchronous** - Don't block conversation
3. **Caching where appropriate** - Reduce database queries
4. **Connection pooling** - Efficient resource usage

## Troubleshooting

### Frontend can't connect to Gemini Live API
- Check session token is valid
- Verify API key is configured in backend
- Check network connectivity

### Tool calls failing
- Verify user is authenticated
- Check database connectivity
- Review service logs for errors

### Performance issues
- Check WebSocket connection is direct (not proxied)
- Monitor backend tool call execution time
- Review database query performance

