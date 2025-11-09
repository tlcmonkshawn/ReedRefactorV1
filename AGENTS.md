# Project Guidelines for BootyHunter V1

This document provides AI assistants and developers with project-specific guidelines, coding standards, and best practices for the BootyHunter V1 application.

## Project Stack

- **Frontend**: Flutter (Dart) - Web, iOS, Android
- **Backend**: Ruby on Rails (Full Rails, not API-only)
- **Database**: PostgreSQL
- **Deployment**: Render.com via GitHub
- **Integration**: Square MCP (catalog management), Discogs MCP (search, pricing data)

## Architecture Overview

- Flutter frontend communicates with Rails backend via JSON API endpoints
- Rails backend serves both JSON API (for Flutter) and HTML admin pages
- Admin interface accessible via `/admin/*` routes with simple password authentication
- MCP servers (Square, Discogs) accessed via Rails backend

## Git Commit Standards

Follow conventional commit format:

**Format**: `type: description` (keep description under 46 characters)

**Types**:
- `fix:` - Bug fixes
- `feat:` - New features
- `perf:` - Performance improvements
- `docs:` - Documentation updates
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks (dependencies, config)

**Examples**:
- `feat: add user authentication to Flutter app`
- `fix: resolve catalog search pagination bug`
- `docs: update API documentation`
- `refactor: simplify MCP integration service`

## Flutter/Dart Guidelines

### Code Style
- Follow Effective Dart style guide
- Use `camelCase` for variables and functions
- Use `PascalCase` for class names
- Prefix private members with underscore `_`
- Use `const` constructors where possible for performance

### State Management
- Choose appropriate state management solution (Provider, BLoC, Riverpod)
- Keep business logic separate from UI components
- Use dependency injection for services (API clients, MCP clients)

### API Integration
- Use `http` or `dio` package for API calls
- Implement proper error handling and retry logic
- Store API base URL in environment configuration
- Use JSON serialization for request/response models

### Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for critical user flows
- Maintain separation between test and production code

### Cross-Platform Considerations
- Test on web, iOS, and Android platforms
- Handle platform-specific differences gracefully
- Use responsive design patterns for web

## Ruby on Rails Guidelines

### Code Style
- Follow Rails style guide conventions
- Use `snake_case` for methods and variables
- Use `CamelCase` for classes and modules
- Keep controllers thin, models fat
- Use service objects for complex business logic

### API Design
- Follow RESTful conventions for API endpoints
- Use proper HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Return appropriate HTTP status codes
- Version API endpoints (e.g., `/api/v1/items`)
- Use JSON for all API responses
- Implement pagination for list endpoints
- Validate input data at the API level

### Security
- Use strong parameters to prevent mass assignment
- Implement proper authentication (JWT or session-based)
- Use HTTPS in production
- Sanitize user input
- Implement CSRF protection
- Store sensitive data (API keys, passwords) in environment variables
- Use prepared statements for database queries

### Database
- Use ActiveRecord for database operations
- Avoid N+1 queries (use `includes`, `joins`, `preload`)
- Add database indexes for frequently queried columns
- Use migrations for all schema changes

### Testing
- Write unit tests for models and services
- Write integration tests for controllers
- Use RSpec for testing framework
- Maintain test-production code separation
- Tests should validate documented behaviors

### Admin Interface
- Admin routes under `/admin/*` namespace
- Simple password authentication (HTTP Basic Auth acceptable for MVP)
- Admin login accessible via π (pi) logo in bottom right corner
- Admin pages for: logs, users, locations, items management

## MCP Integration

### Render MCP
- **Purpose**: AI-assisted deployment management and monitoring on Render.com
- **Use Cases**: 
  - View deployment logs and status
  - Monitor service metrics (CPU, memory, requests)
  - Update environment variables
  - Query Render PostgreSQL databases
  - Manage deployments
- **Documentation**: See [docs/deployment/render-mcp.md](docs/deployment/render-mcp.md)
- **Tools Available**: Service management, log queries, metrics, database queries, environment variable updates

### Square MCP
- Used for catalog add/edit operations
- Handle authentication securely (store tokens in environment variables)
- Implement proper error handling for API failures
- Cache responses when appropriate to reduce API calls

### Discogs MCP
- Used for search by record details (codes, artist, title)
- Retrieve pricing and sales data
- Support both records and CDs
- Handle rate limiting gracefully

### Implementation Pattern
- Create service objects for MCP interactions (e.g., `SquareCatalogService`, `DiscogsSearchService`)
- Abstract MCP calls behind service interfaces
- Implement retry logic for transient failures
- Log all MCP API calls for debugging
- Use Render MCP for deployment operations and monitoring (via AI assistants)

## Deployment & CI/CD

### GitHub Actions
- Set up workflows for automated testing
- Run tests on pull requests
- Deploy to Render.com automatically on merge to main branch
- Use environment secrets for sensitive configuration

### Render.com Deployment
- Configure Rails backend service
- Configure PostgreSQL database
- Set environment variables in Render dashboard
- Enable automatic deployments from GitHub
- Configure build commands appropriately

### Environment Variables
- Use `.env` files for local development (not committed)
- Use Render environment variables for production
- Never commit API keys, passwords, or secrets

## Testing Standards

### Separation of Concerns
- Test code in dedicated test directories
- Production code should remain unchanged for testing
- Use dependency injection to enable mocking
- Document and justify any production code changes made solely for testing

### Test Types
- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions
- **End-to-End Tests**: Test complete user flows

### Test Quality
- Write tests to validate documented behaviors
- Keep tests deterministic (no flaky tests)
- Clean up test data after execution
- Use appropriate test doubles (mocks, stubs, fakes)

## Documentation

### Code Documentation
- Document complex business logic
- Include method/function descriptions
- Document API endpoints with request/response examples
- Keep documentation up-to-date with code changes

### README Maintenance
- Keep README.md current with setup instructions
- Document environment variable requirements
- Include troubleshooting section
- Update when architecture changes

## Error Handling

### Flutter
- Use try-catch blocks for async operations
- Display user-friendly error messages
- Log errors for debugging
- Implement retry logic for network failures

### Rails
- Use proper HTTP status codes
- Return structured error responses: `{ error: { message: "...", code: "..." } }`
- Log errors with appropriate severity
- Handle MCP API errors gracefully

## Performance

### Flutter
- Minimize widget rebuilds (use `const`, `shouldRebuild`)
- Optimize images and assets
- Use lazy loading for lists
- Profile with Flutter DevTools

### Rails
- Optimize database queries (avoid N+1)
- Use background jobs for long-running tasks
- Implement caching where appropriate
- Monitor API response times

## Security Best Practices

- Never commit secrets or API keys
- Use environment variables for sensitive configuration
- Validate and sanitize all user input
- Implement proper authentication and authorization
- Use HTTPS in production
- Keep dependencies updated
- Review and audit Ruby deployment on Render

## Project-Specific Notes

### App Purpose
_(To be defined - awaiting user input)_

### Current State
- Project initialized
- Rules reference collection complete
- Ready for Flutter and Rails setup

### Next Steps
1. Define app purpose and features
2. Set up Flutter project structure
3. Set up Rails project structure
4. Configure MCP integrations
5. Implement authentication
6. Build admin interface
7. Set up deployment pipeline

## References

- Flutter/Dart: [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Rails: [Rails Style Guide](https://rails.rubystyle.guide/)
- Collected rules: See `rules-reference/` directory

