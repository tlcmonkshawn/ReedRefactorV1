# R.E.E.D. Bootie Hunter - Development Guide

This guide provides step-by-step instructions for setting up and developing the R.E.E.D. Bootie Hunter application.

## Prerequisites

### Required Software

- **Ruby**: Version 3.2.0 or higher
- **Rails**: Version 7.1 or higher
- **PostgreSQL**: Version 14 or higher
- **Flutter**: Version 3.0 or higher
- **Git**: For version control

### Optional Software

- **Node.js**: For JavaScript tooling (if needed)
- **Docker**: For containerized development (optional)

## Initial Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd bootyhunterv1
```

### 2. Backend Setup

#### Install Ruby Dependencies

```bash
cd backend
bundle install
```

#### Configure Database

1. Create PostgreSQL database:
```bash
createdb bootyhunter_development
createdb bootyhunter_test
```

2. Configure database in `config/database.yml` (or use environment variables)

3. Run migrations:
```bash
rails db:migrate
```

4. Seed database (if seed file exists):
```bash
rails db:seed
```

#### Environment Variables

Create `.env` file in `backend/` directory (do not commit to git):

```bash
# Required
GEMINI_API_KEY=your_gemini_api_key_here
JWT_SECRET=your_jwt_secret_here
DATABASE_URL=postgresql://user:password@localhost/bootyhunter_development
RAILS_ENV=development

# Optional
SQUARE_ACCESS_TOKEN=your_square_token_here
DISCOGS_API_KEY=your_discogs_key_here
ADMIN_PASSWORD=admin_password_here
```

Generate secrets:
```bash
# Use the provided script or generate manually
rails secret  # Generate JWT_SECRET
```

#### Start Rails Server

```bash
rails server
```

Server will run on `http://localhost:3000`

### 3. Frontend Setup

#### Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

#### Configure API Base URL

Update API base URL in `lib/services/api_service.dart` or use environment configuration:

```dart
final apiService = ApiService(baseUrl: 'http://localhost:3000');
```

#### Run Flutter App

**Web**:
```bash
flutter run -d chrome
```

**iOS** (requires macOS):
```bash
flutter run -d ios
```

**Android**:
```bash
flutter run -d android
```

## Development Workflow

### Running Tests

#### Backend Tests (RSpec)

```bash
cd backend
bundle exec rspec
```

Run specific test:
```bash
bundle exec rspec spec/models/bootie_spec.rb
```

#### Frontend Tests (Flutter)

```bash
cd frontend
flutter test
```

Run specific test:
```bash
flutter test test/models/bootie_test.dart
```

### Database Migrations

#### Create Migration

```bash
cd backend
rails generate migration MigrationName
```

#### Run Migrations

```bash
rails db:migrate
```

#### Rollback Migration

```bash
rails db:rollback
```

### Code Quality

#### Backend (Ruby)

- **Linter**: RuboCop (if configured)
```bash
bundle exec rubocop
```

- **Formatter**: Standard Ruby style

#### Frontend (Dart)

- **Linter**: Built-in Dart analyzer
```bash
cd frontend
flutter analyze
```

- **Formatter**: Dart formatter
```bash
flutter format lib/
```

## Common Development Tasks

### Adding a New Feature

1. **Create Feature Branch**
```bash
git checkout -b feature/feature-name
```

2. **Backend Changes**
   - Create/update models if needed
   - Create service objects for business logic
   - Create/update API controllers
   - Add routes
   - Write tests

3. **Frontend Changes**
   - Create/update models
   - Create/update services
   - Create/update screens
   - Update state management
   - Write tests

4. **Update Documentation**
   - Update `docs/API.md` if API changed
   - Update `docs/DATABASE.md` if schema changed
   - Update `docs/ARCHITECTURE.md` if architecture changed

5. **Commit and Push**
```bash
git add .
git commit -m "feat: add feature-name"
git push origin feature/feature-name
```

### Debugging

#### Backend Debugging

**Rails Console**:
```bash
cd backend
rails console
```

**Logs**:
```bash
tail -f log/development.log
```

**Byebug/Debugger**:
Add `binding.pry` or `debugger` in code to set breakpoints

#### Frontend Debugging

**Flutter DevTools**:
```bash
flutter run -d chrome
# Open DevTools in browser
```

**Logs**:
```bash
flutter logs
```

**Debug Mode**:
Run with `--debug` flag for verbose logging

### API Testing

#### Using cURL

```bash
# Register user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123","name":"Test User"}}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get Booties (with token)
curl -X GET http://localhost:3000/api/v1/booties \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Using Postman/Insomnia

1. Import API endpoints from `docs/API.md`
2. Set base URL: `http://localhost:3000`
3. Add Authorization header: `Bearer YOUR_TOKEN_HERE`

## Project Structure

### Backend Structure

```
backend/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # API controllers
│   │   └── admin/           # Admin controllers
│   ├── models/              # ActiveRecord models
│   └── services/            # Service objects
├── config/
│   ├── routes.rb            # Route definitions
│   └── database.yml         # Database configuration
├── db/
│   ├── migrate/             # Database migrations
│   └── schema.rb            # Database schema
└── spec/                    # RSpec tests
```

### Frontend Structure

```
frontend/
├── lib/
│   ├── main.dart            # App entry point
│   ├── models/              # Data models
│   ├── screens/             # UI screens
│   ├── services/            # API services
│   ├── providers/           # State management
│   └── widgets/             # Reusable widgets
├── test/                    # Flutter tests
└── pubspec.yaml             # Dependencies
```

## Environment-Specific Configuration

### Development

- **Backend**: `http://localhost:3000`
- **Frontend**: `http://localhost:8080` (web)
- **Database**: Local PostgreSQL
- **Logging**: Verbose, detailed errors

### Production (Render.com)

- **Backend**: Configured in Render dashboard
- **Database**: PostgreSQL on Render
- **Environment Variables**: Set in Render dashboard
- **Deployment**: Automatic via GitHub integration

## Troubleshooting

### Common Issues

#### Backend Won't Start

- Check PostgreSQL is running: `pg_isready`
- Check database exists: `rails db:create`
- Check environment variables are set
- Check for port conflicts: `lsof -i :3000`

#### Frontend Build Errors

- Run `flutter clean` and `flutter pub get`
- Check Flutter version: `flutter --version`
- Check for dependency conflicts
- Verify API base URL is correct

#### Database Connection Errors

- Verify PostgreSQL is running
- Check `DATABASE_URL` or `database.yml` configuration
- Verify database user has correct permissions
- Check database exists: `psql -l`

#### API Authentication Errors

- Verify JWT token is valid
- Check token expiration
- Verify `JWT_SECRET` is set correctly
- Check token is included in Authorization header

## Useful Commands

### Backend

```bash
# Start server
rails server

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Open Rails console
rails console

# Run tests
bundle exec rspec

# Generate model
rails generate model ModelName

# Generate controller
rails generate controller Api::V1::ControllerName

# Generate migration
rails generate migration MigrationName
```

### Frontend

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Build for web
flutter build web

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## Next Steps

1. **Read Documentation**: Start with `PRODUCT_PROFILE.md` to understand the application
2. **Review Architecture**: Read `docs/ARCHITECTURE.md` for system design
3. **Explore Code**: Start with models and controllers to understand data flow
4. **Run Tests**: Execute test suite to see how features are tested
5. **Make Changes**: Start with small improvements and work your way up

## Getting Help

- **Documentation**: Check `docs/` directory for detailed documentation
- **Code Comments**: Review code comments for implementation details
- **API Docs**: See `docs/API.md` for endpoint documentation
- **Project Guidelines**: See `AGENTS.md` for coding standards

---

*This guide should be updated as the development process evolves. Add new procedures, tools, and troubleshooting steps as needed.*

