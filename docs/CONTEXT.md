# R.E.E.D. Bootie Hunter - Context for AI Assistants

This document provides context for AI assistants working on the R.E.E.D. Bootie Hunter project. It covers project overview, key patterns, conventions, and common development tasks.

## Project Overview

**R.E.E.D. Bootie Hunter** is a gamified inventory management and e-commerce platform for thrift stores. The application uses AI (Google Gemini) to assist with item identification, price research, and catalog management, integrated with Square for e-commerce.

- **Frontend**: Flutter (Dart) - Web, iOS, Android
- **Backend**: Ruby on Rails (Full Rails, not API-only)
- **Database**: PostgreSQL
- **AI**: Google Gemini (multiple models for different tasks)
- **Integrations**: Square MCP, Discogs MCP
- **Deployment**: Render.com via GitHub

## Key Concepts

### Booties
- **Definition**: Captured items/inventory entries
- **Workflow**: `captured` → `submitted` → `researching` → `researched` → `finalized`
- **Finalization**: When a Bootie is finalized, it's published to Square catalog and becomes available for sale

### User Roles
- **Agent**: Store employees who capture Booties
- **Bootie Boss**: Store managers who finalize Booties to Square
- **Admin**: Full system access
- **Player**: Customers/guests who participate in gamification

### R.E.E.D. 8
- AI assistant persona: "The Cool Record Store Expert"
- Personality: Knowledgeable, confident, playfully flirty, sarcastic wit
- Communication: Movie quotes, music lyrics, sarcasm
- See `PRODUCT_PROFILE.md` for detailed persona specifications

## Architecture Patterns

### Backend Service Objects

All business logic is in service objects following this pattern:

```ruby
class ServiceName < ApplicationService
  def initialize(params)
    # Initialize instance variables
  end

  def call
    # Business logic
    return failure("Error message", "ERROR_CODE") if error_condition
    success(data)
  end
end

# Usage:
result = ServiceName.call(params)
if result.success?
  # Handle success with result.data
else
  # Handle failure with result.error and result.error_code
end
```

**Key Services**:
- `ResearchService`: AI-powered price research
- `FinalizationService`: Publishes Booties to Square
- `ImageProcessingService`: AI image editing
- `GeminiLiveService`: Gemini Live API integration
- `SquareCatalogService`: Square catalog operations
- `DiscogsSearchService`: Discogs music database operations

### API Controllers

- All API controllers under `Api::V1` namespace
- JSON-only responses
- JWT authentication via `BaseController`
- Standardized error format: `{ error: { message: "...", code: "..." } }`

### Frontend State Management

- Provider pattern for state management
- `AuthProvider`: Authentication state
- `BootieProvider`: Bootie list and operations
- Local caching of Booties and locations

### Gemini Live API Integration

**Architecture Decision**: Frontend connects directly to Gemini Live API for lower latency

```
Frontend → Gemini Live API (Direct WebSocket)
         ↓
         Tool Calls → Rails Backend (POST /api/v1/gemini/tool_call)
```

- Frontend handles audio/video streaming directly
- Tool calls proxied through Rails backend (for database access and API key security)

## Code Conventions

### Backend (Ruby on Rails)

- **Naming**: `snake_case` for methods/variables, `CamelCase` for classes
- **Controllers**: Thin controllers, fat models, business logic in services
- **Models**: Associations, validations, scopes, business logic methods
- **Services**: All business logic, return `ServiceResult` objects
- **Comments**: Use YARD-style documentation for complex methods

### Frontend (Flutter/Dart)

- **Naming**: `camelCase` for variables/functions, `PascalCase` for classes
- **State Management**: Provider pattern
- **API Client**: Dio with interceptors for auth and error handling
- **Comments**: Use Dart documentation comments for public APIs

## Database Schema

See `docs/DATABASE.md` for complete schema documentation.

**Key Tables**:
- `users`: User accounts and authentication
- `booties`: Captured items/inventory
- `research_logs`: Research history
- `grounding_sources`: Research citations
- `locations`: Physical store locations
- `conversations` & `messages`: Chat/message history
- `scores`, `leaderboards`, `achievements`: Gamification data
- `prompts`: AI prompts and system instructions

## Common Development Tasks

### Adding a New API Endpoint

1. Add route to `config/routes.rb` under `namespace :api, namespace :v1`
2. Create controller action in appropriate controller
3. Add authorization checks if needed
4. Use service objects for business logic
5. Return standardized JSON response
6. Update `docs/API.md` with endpoint documentation

### Adding a New Service Object

1. Create file in `app/services/`
2. Inherit from `ApplicationService`
3. Implement `initialize` and `call` methods
4. Return `success(data)` or `failure(error_message, error_code)`
5. Add comments explaining the service's purpose and process

### Adding a New Model

1. Create migration: `rails generate migration CreateModelName`
2. Create model file in `app/models/`
3. Add associations, validations, scopes
4. Add helper methods for common queries
5. Update `docs/DATABASE.md` with schema documentation

### Working with Gemini AI

**Models Used**:
- `gemini-2.5-flash`: Chat, research with Google Search grounding
- `gemini-flash-lite-latest`: Quick image analysis
- `gemini-2.5-flash-image`: AI image editing
- `gemini-2.5-flash-native-audio-preview`: Live voice/video

**API Keys**: Stored in environment variables, never in code

### Testing

- **Backend**: RSpec for unit and integration tests
- **Frontend**: Flutter unit tests, widget tests, integration tests
- **Test Data**: Use factories/fixtures for consistent test data

## File Locations

### Backend

- **Models**: `backend/app/models/`
- **Controllers**: `backend/app/controllers/api/v1/` (API) or `backend/app/controllers/admin/` (Admin)
- **Services**: `backend/app/services/`
- **Routes**: `backend/config/routes.rb`
- **Migrations**: `backend/db/migrate/`
- **Schema**: `backend/db/schema.rb`

### Frontend

- **Models**: `frontend/lib/models/`
- **Screens**: `frontend/lib/screens/`
- **Services**: `frontend/lib/services/`
- **Providers**: `frontend/lib/providers/`
- **Widgets**: `frontend/lib/widgets/`
- **Entry Point**: `frontend/lib/main.dart`

### Documentation

- **Product Spec**: `PRODUCT_PROFILE.md`
- **Architecture**: `docs/ARCHITECTURE.md`
- **API Docs**: `docs/API.md`
- **Database Docs**: `docs/DATABASE.md`
- **Development Guide**: `docs/DEVELOPMENT_GUIDE.md` (this file)
- **Project Guidelines**: `AGENTS.md`

## Environment Variables

### Required Backend Variables

- `GEMINI_API_KEY`: Google Gemini API key
- `JWT_SECRET`: Secret for JWT token signing
- `DATABASE_URL`: PostgreSQL connection string
- `RAILS_ENV`: Environment (development, production, test)

### Optional Backend Variables

- `SQUARE_ACCESS_TOKEN`: Square API access token (if using Square MCP)
- `DISCOGS_API_KEY`: Discogs API key (if using Discogs MCP)
- `ADMIN_PASSWORD`: Admin interface password (for simple auth)

## Git Commit Standards

Follow conventional commit format:

```
type: description

Types:
- fix: Bug fixes
- feat: New features
- perf: Performance improvements
- docs: Documentation updates
- style: Code style changes
- refactor: Code refactoring
- test: Adding or updating tests
- chore: Maintenance tasks
```

Examples:
- `feat: add user authentication to Flutter app`
- `fix: resolve catalog search pagination bug`
- `docs: update API documentation`

## Common Issues and Solutions

### Authentication Issues

- **Problem**: 401 Unauthorized errors
- **Solution**: Check JWT token is included in Authorization header, verify token hasn't expired

### Database Issues

- **Problem**: Migration errors
- **Solution**: Run `rails db:migrate`, check for conflicting migrations

### API Integration Issues

- **Problem**: Service returning failure
- **Solution**: Check service logs, verify API keys are set, check error messages in ServiceResult

### Frontend Build Issues

- **Problem**: Flutter build errors
- **Solution**: Run `flutter pub get`, check for dependency conflicts, verify Dart version

## References

- **Product Spec**: `PRODUCT_PROFILE.md` - Complete product requirements and features
- **Architecture**: `docs/ARCHITECTURE.md` - System architecture and design
- **API Docs**: `docs/API.md` - API endpoint documentation
- **Database**: `docs/DATABASE.md` - Database schema documentation
- **Project Guidelines**: `AGENTS.md` - Coding standards and best practices

---

*This context file should be updated as the project evolves. Add new patterns, conventions, and common tasks as they emerge.*

