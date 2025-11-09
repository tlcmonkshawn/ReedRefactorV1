# R.E.E.D. Bootie Hunter - System Architecture

## Overview

R.E.E.D. Bootie Hunter is a full-stack application built with Flutter (frontend) and Ruby on Rails (backend). The application provides a gamified inventory management system for thrift stores, powered by AI (Google Gemini) and integrated with Square for e-commerce catalog management.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Frontend                        │
│  (Web, iOS, Android - Single Codebase)                      │
│                                                              │
│  • UI Components (Screens, Widgets)                         │
│  • State Management (Provider/Riverpod)                     │
│  • API Client (Dio)                                         │
│  • Direct Gemini Live API Connection (WebSocket)            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTP/REST API
                        │ JWT Authentication
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                   Rails Backend (API)                       │
│                                                              │
│  • API Controllers (JSON responses)                         │
│  • Service Objects (Business Logic)                         │
│  • ActiveRecord Models                                      │
│  • JWT Authentication                                       │
│  • Tool Call Proxy (for Gemini Live API)                   │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  PostgreSQL  │ │ Google Gemini│ │ Square MCP   │
│  Database    │ │ API          │ │ Server       │
└──────────────┘ └──────────────┘ └──────────────┘
                        │
                        ▼
                ┌──────────────┐
                │ Discogs MCP  │
                │ Server       │
                └──────────────┘
```

## Component Architecture

### Frontend (Flutter)

**Location**: `frontend/lib/`

#### Directory Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Bootie, User, etc.)
├── services/                 # API services and external integrations
│   ├── api_service.dart      # Base HTTP client with auth
│   ├── auth_service.dart     # Authentication service
│   ├── bootie_service.dart   # Bootie CRUD operations
│   ├── gemini_live_service.dart  # Gemini Live API connection
│   └── ...
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart
│   └── bootie_provider.dart
├── screens/                  # UI screens
│   ├── landing_screen.dart        # Animated splash/landing screen
│   ├── login_screen.dart          # Login/register with toggle
│   ├── onboarding_screen.dart     # Multi-page onboarding flow
│   ├── reed_introduction_screen.dart  # R.E.E.D. character intro
│   ├── home_screen.dart
│   ├── booties_list_screen.dart
│   └── ...
└── widgets/                  # Reusable UI components
    ├── app_icon.dart
    └── status_badge.dart
```

#### Key Frontend Patterns

1. **State Management**: Provider pattern for state management
   - `AuthProvider`: Manages user authentication state and onboarding completion
   - `BootieProvider`: Manages Bootie list and operations

2. **API Communication**: Dio HTTP client with interceptors
   - `AuthInterceptor`: Automatically adds JWT token to requests
   - `ErrorInterceptor`: Handles 401 errors and token refresh

3. **Direct Gemini Live Connection**: Frontend connects directly to Gemini Live API
   - WebSocket connection for real-time audio/video
   - Tool calls proxied through Rails backend
   - Lower latency for media streaming

4. **User Flow & Navigation**: Smart routing based on authentication and onboarding status
   - **Landing Screen**: Animated splash screen (3-second auto-transition or tap to skip)
   - **Login/Register Screen**: Toggle between modes with "Add Account" button
   - **Onboarding Flow**: 3-page story introduction for first-time users
   - **Reed Introduction**: Character introduction with animated text reveal
   - **Home Screen**: Main app interface (shown after onboarding completion)
   - Routing logic in `main.dart` checks auth status and onboarding completion

### Backend (Rails)

**Location**: `backend/`

#### Directory Structure
```
backend/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # JSON API controllers
│   │   │   ├── auth_controller.rb
│   │   │   ├── booties_controller.rb
│   │   │   └── ...
│   │   └── admin/           # HTML admin interface
│   │       ├── dashboard_controller.rb
│   │       └── ...
│   ├── models/              # ActiveRecord models
│   │   ├── user.rb
│   │   ├── bootie.rb
│   │   └── ...
│   ├── services/            # Service objects (business logic)
│   │   ├── application_service.rb
│   │   ├── research_service.rb
│   │   ├── finalization_service.rb
│   │   └── ...
│   └── ...
├── config/
│   ├── routes.rb            # Route definitions
│   └── ...
└── db/
    ├── schema.rb            # Database schema
    └── migrate/             # Database migrations
```

#### Key Backend Patterns

1. **Service Objects**: Business logic encapsulated in service classes
   - All services inherit from `ApplicationService`
   - Return `ServiceResult` objects (success/failure pattern)
   - Called via `ServiceName.call(params)`

2. **API Controllers**: JSON-only responses for Flutter frontend
   - Namespaced under `Api::V1`
   - JWT authentication via `BaseController`
   - Standardized error responses

3. **Admin Interface**: HTML-based admin panel
   - Namespaced under `/admin/*`
   - Simple password authentication
   - Separate controllers from API

4. **Database Layer**: ActiveRecord ORM
   - 12 core tables for users, booties, research, gamification
   - Associations and validations in models
   - Database indexes for performance

## Data Flow

### User Onboarding Flow

```
1. App Launch
   ↓
2. Root Route Check (main.dart)
   ↓
3. Is Authenticated?
   │
   ├─ NO → Landing Screen (animated splash)
   │         ↓ (3 seconds or tap)
   │         Login/Register Screen
   │         ↓ (successful auth)
   │         Root Route Check
   │
   └─ YES → Has Completed Onboarding?
            │
            ├─ NO → Onboarding Screen (3 pages)
            │         ↓ (swipe/continue)
            │         Reed Introduction Screen
            │         ↓ ("Get Started" button)
            │         Mark onboarding complete
            │         ↓
            │         Home Screen
            │
            └─ YES → Home Screen
```

**Key Components**:
- `LandingScreen`: Animated splash with branding
- `LoginScreen`: Toggle between login/register modes
- `OnboardingScreen`: 3-page story introduction
- `ReedIntroductionScreen`: Character introduction
- `AuthProvider`: Tracks authentication and onboarding status
- Onboarding completion stored in SharedPreferences per user

### Authentication Flow

```
1. User submits login credentials (email/password)
   ↓
2. Frontend: POST /api/v1/auth/login
   ↓
3. Backend: Validates credentials, generates JWT token
   ↓
4. Frontend: Stores JWT token in SharedPreferences
   ↓
5. Frontend: Adds token to all subsequent API requests via AuthInterceptor
```

### Bootie Capture & Research Flow

```
1. User captures item via Gemini Live API (video call)
   ↓
2. R.E.E.D. calls take_snapshot tool
   ↓
3. Tool call proxied to Rails: POST /api/v1/gemini/tool_call
   ↓
4. Backend: Creates Bootie record with status="captured"
   ↓
5. User submits Bootie (or auto-submitted)
   ↓
6. Backend: Status changes to "submitted", research triggered
   ↓
7. ResearchService: Calls Gemini 2.5 Flash with Google Search grounding
   ↓
8. Research results stored in bootie record (status="researched")
   ↓
9. Bootie Boss reviews and finalizes Bootie
   ↓
10. FinalizationService: Creates product in Square via Square MCP
   ↓
11. Bootie status changes to "finalized"
```

### Gemini Live API Integration

**Architecture Decision**: Frontend connects directly to Gemini Live API for lower latency

```
Frontend (Flutter)
    │
    ├─► Gemini Live API (Direct WebSocket)
    │   • Audio/video streaming
    │   • Real-time transcription
    │   • Voice responses
    │
    └─► Tool Calls ──► Rails Backend (POST /api/v1/gemini/tool_call)
                        • Database access
                        • API key security
                        • Business logic execution
```

## External Integrations

### Google Gemini AI

**Models Used**:
- `gemini-2.5-flash`: Chat, research with Google Search grounding, location search
- `gemini-flash-lite-latest`: Quick image analysis
- `gemini-2.5-flash-image`: AI image editing ("Nano Banana")
- `gemini-2.5-flash-native-audio-preview`: Live voice/video conversations

**Integration Points**:
- ResearchService: Price research with Google Search grounding
- ImageProcessingService: Image editing and enhancement
- GeminiLiveService: Session token generation and tool call proxy

### Square MCP (Model Context Protocol)

**Purpose**: Catalog management for e-commerce platform

**Integration**:
- SquareCatalogService: Creates and updates products in Square
- FinalizationService: Publishes Booties to Square catalog
- Category syncing from Square catalog

### Discogs MCP (Model Context Protocol)

**Purpose**: Music database for records and CDs

**Integration**:
- DiscogsSearchService: Search records by codes, artist, title
- Retrieves pricing and sales data for music items
- Used during research phase for music-specific items

## Security Architecture

### Authentication & Authorization

1. **User Authentication**: JWT-based authentication
   - Tokens generated on login
   - Tokens stored client-side (SharedPreferences)
   - Tokens validated on every API request

2. **Role-Based Access Control**:
   - `agent`: Can capture and submit Booties
   - `bootie_boss`: Can finalize Booties to Square
   - `admin`: Full system access
   - `player`: Can participate in gamification features

3. **API Security**:
   - HTTPS required in production
   - CSRF protection for admin interface
   - Input validation and sanitization
   - Strong parameters for mass assignment protection

### API Key Management

- All API keys stored in environment variables (never in code)
- Gemini API key: Backend only (never exposed to frontend)
- Square API keys: Backend only (via Square MCP)
- Discogs API keys: Backend only (via Discogs MCP)

## Database Architecture

See [DATABASE.md](./DATABASE.md) for detailed schema documentation.

**Key Tables**:
- `users`: User accounts and authentication
- `booties`: Captured items/inventory
- `research_logs`: Research history and data
- `grounding_sources`: Research source citations
- `locations`: Physical store locations
- `conversations` & `messages`: Chat/message history
- `scores`, `leaderboards`, `achievements`: Gamification data
- `game_sessions`: Game mode sessions
- `prompts`: AI prompts and system instructions

## Deployment Architecture

### Production Environment (Render.com)

```
GitHub Repository
    │
    ├─► GitHub Actions (CI/CD)
    │   • Automated testing
    │   • Deployment on merge to main
    │
    └─► Render.com
        ├─► Rails Backend Service
        │   • PostgreSQL database
        │   • Environment variables
        │   • Automatic deployments
        │
        └─► Flutter Web Build (or separate service)
```

### Local Development

- Rails: `rails server` (localhost:3000)
- Flutter: `flutter run -d chrome` (for web development)
- PostgreSQL: Local database instance
- Environment: `.env` files (not committed to git)

## API Architecture

See [API.md](./API.md) for detailed API documentation.

**API Namespace**: `/api/v1/*`

**Main Endpoints**:
- `/api/v1/auth/*`: Authentication
- `/api/v1/booties/*`: Bootie CRUD and operations
- `/api/v1/locations/*`: Location management
- `/api/v1/gemini_live/*`: Gemini Live API integration
- `/api/v1/leaderboards/*`: Gamification endpoints

## Service Layer Architecture

All business logic is encapsulated in service objects located in `app/services/`.

**Service Pattern**:
```ruby
class ServiceName < ApplicationService
  def initialize(params)
    # Initialize instance variables
  end

  def call
    # Business logic here
    # Return success(data) or failure(error_message, error_code)
  end
end

# Usage:
result = ServiceName.call(params)
if result.success?
  # Handle success
else
  # Handle failure
end
```

**Key Services**:
- `ResearchService`: AI-powered price research
- `FinalizationService`: Finalizes Booties to Square
- `ImageProcessingService`: Image editing and enhancement
- `GeminiLiveService`: Gemini Live API integration
- `SquareCatalogService`: Square catalog operations
- `DiscogsSearchService`: Discogs music database operations

## Error Handling

### API Error Response Format

```json
{
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE"
  }
}
```

### Service Result Pattern

Services return `ServiceResult` objects:
- `result.success?`: Boolean indicating success
- `result.data`: Success data (if successful)
- `result.error`: Error message (if failed)
- `result.error_code`: Error code (if failed)

## Performance Considerations

1. **Database Indexes**: Key queries indexed (status, category, user_id, etc.)
2. **Caching**: Frontend caches Booties and locations locally
3. **Background Jobs**: Research operations run asynchronously (Sidekiq)
4. **Direct API Connections**: Gemini Live API connected directly from frontend for lower latency
5. **Image Optimization**: Images compressed before upload

## Future Architecture Considerations

1. **Real-time Updates**: WebSocket integration for live Bootie status updates
2. **Caching Layer**: Redis for frequently accessed data
3. **File Storage**: Cloud storage (AWS S3, Google Cloud Storage) for images
4. **Monitoring**: Application monitoring and error tracking (Sentry, etc.)
5. **Horizontal Scaling**: Load balancing and multiple Rails instances

---

*For implementation details, see individual service and controller documentation in code comments.*
