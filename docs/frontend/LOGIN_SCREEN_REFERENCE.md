# Login Screen Reference for New Login Agent

## Current Implementation Overview

The login screen is located at: `frontend/lib/screens/login_screen.dart`

## Key Components

### 1. **LoginScreen Widget**
- **Location**: `frontend/lib/screens/login_screen.dart`
- **Type**: StatefulWidget
- **Features**:
  - Toggle between Login and Register modes
  - Form validation
  - Loading state during submission
  - Error handling with SnackBar

### 2. **Form Fields**
- **Email**: Required, email validation
- **Password**: Required, min 8 chars for registration
- **Name**: Required only for registration

### 3. **State Management**
- Uses `AuthProvider` (Provider pattern)
- Located at: `frontend/lib/providers/auth_provider.dart`
- Methods used:
  - `authProvider.login(email, password)`
  - `authProvider.register(email, password, name)`

### 4. **Backend Integration**
- **AuthService**: `frontend/lib/services/auth_service.dart`
- **API Endpoints**:
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/register`
  - `GET /api/v1/auth/me` (for checking current user)

## Current API Contract

### Login Request
```dart
POST /api/v1/auth/login
Body: {
  "email": "user@example.com",
  "password": "password123"
}
```

### Login Response (200)
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "role": "agent",
    "total_points": 0,
    "total_items_scanned": 0
  }
}
```

### Register Request
```dart
POST /api/v1/auth/register
Body: {
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "User Name"
  }
}
```

### Register Response (201)
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "role": "agent",
    "total_points": 0,
    "total_items_scanned": 0
  }
}
```

## Current UI Structure

```dart
Scaffold
  └─ SafeArea
      └─ Center
          └─ SingleChildScrollView
              └─ Form
                  ├─ Title: "R.E.E.D. Bootie Hunter"
                  ├─ Email TextFormField
                  ├─ Name TextFormField (registration only)
                  ├─ Password TextFormField
                  ├─ Submit Button (Login/Register)
                  └─ Toggle Button (Login ↔ Register)
```

## Key Behaviors

1. **Form Validation**:
   - Email: Required, must contain '@'
   - Password: Required, min 8 chars for registration
   - Name: Required for registration only

2. **Loading State**:
   - Button shows CircularProgressIndicator when `_isSubmitting = true`
   - Button is disabled during submission

3. **Error Handling**:
   - Errors shown in red SnackBar
   - Error messages from backend are displayed
   - Debug prints to console

4. **Navigation**:
   - After successful login/register, `AuthProvider` updates
   - App automatically navigates to `HomeScreen` via Consumer pattern
   - No explicit navigation needed in LoginScreen

## Integration Points

### AuthProvider
```dart
// Located at: frontend/lib/providers/auth_provider.dart
final authProvider = context.read<AuthProvider>();
await authProvider.login(email, password);
// or
await authProvider.register(email, password, name);
```

### AuthService
```dart
// Located at: frontend/lib/services/auth_service.dart
// Handles API calls and token storage
// Token stored in SharedPreferences as 'auth_token'
```

### Main App Flow
```dart
// Located at: frontend/lib/main.dart
// Uses Consumer<AuthProvider> to show LoginScreen or HomeScreen
// Based on authProvider.isAuthenticated
```

## Current Issues to Address

1. **500 Error on Backend**: Currently debugging backend 500 errors on login/register
   - Backend logs should show detailed error messages
   - Check Render logs for specific error

2. **Error Messages**: Currently shows generic error messages
   - Could be improved with more specific error handling

3. **UI/UX**: Basic Material Design
   - Could be enhanced with custom styling
   - Could add password visibility toggle
   - Could add "Forgot Password" functionality

## Notes for New Login Agent

1. **Keep API Contract**: Don't change the API request/response format without coordinating with backend
2. **Maintain AuthProvider Integration**: The app relies on AuthProvider for state management
3. **Error Handling**: Ensure errors are user-friendly and displayed properly
4. **Loading States**: Keep the loading indicator during submission
5. **Form Validation**: Maintain current validation rules or improve them
6. **Navigation**: Don't add explicit navigation - let AuthProvider handle it

## Testing

- Test on web (current deployment)
- Test login flow
- Test registration flow
- Test error scenarios (invalid email, wrong password, etc.)
- Test form validation
- Test loading states

## Backend Status

- Backend deployed at: `https://reed-bootie-hunter-v1-1.onrender.com`
- Currently debugging 500 errors
- Detailed logging added to backend for debugging

---

**Last Updated**: 2025-11-06
**Current Status**: Backend 500 errors being debugged, frontend login screen functional but basic
