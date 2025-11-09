# Landing Experience Documentation

## Overview

The R.E.E.D. Bootie Hunter app features a polished onboarding flow that guides new users through the app's storyline and introduces them to R.E.E.D. 8, the AI assistant. The experience consists of four main screens: Landing, Login, Onboarding, and Reed Introduction.

## User Flow

```
App Launch
    ↓
Landing Screen (animated splash)
    ↓ (auto-transition after 3s or tap)
Login Screen
    ↓ (after successful login/registration)
Root Route Check
    ↓
┌─────────────────────────────────┐
│ Has completed onboarding?       │
└─────────────────────────────────┘
    │                    │
   NO                   YES
    ↓                    ↓
Onboarding Screen    Home Screen
    ↓
Reed Introduction Screen
    ↓
Home Screen (onboarding marked complete)
```

## Screen Details

### 1. Landing Screen

**File**: `frontend/lib/screens/landing_screen.dart`

**Purpose**: Animated splash screen that introduces the app branding.

**Features**:
- Animated logo/icon with scale and fade effects
- App branding: "R.E.E.D." (large, bold) and "Bootie Hunter" (subtitle)
- Gradient background (blue tones: blue.shade900 → blue.shade700 → blue.shade500)
- White circular icon container with search icon (placeholder for logo)
- "Tap anywhere to continue" hint text
- Auto-transition to login after 3 seconds
- Tap anywhere to skip animation and go directly to login

**Animations**:
- Logo: Scale animation (0.5 → 1.0) with elastic curve
- Text: Fade-in animation
- Smooth page transition to login screen

**Navigation**:
- Automatically navigates to `LoginScreen` after 3 seconds
- User can tap anywhere to skip and go immediately to login

---

### 2. Login Screen (Enhanced)

**File**: `frontend/lib/screens/login_screen.dart`

**Purpose**: User authentication with integrated account creation.

**Features**:
- Toggle between Login and Register modes
- **"Add Account" button**: Prominent green button (only shown in login mode) that switches to register mode
- Form validation (email, password, name for registration)
- Loading states during submission (CircularProgressIndicator)
- Error handling with SnackBar notifications (red background, 5-second duration)
- Smooth navigation to root route after successful auth

**Form Fields**:
- **Email**: Required, must contain '@'
- **Password**: Required, minimum 8 characters for registration
- **Name**: Required only for registration mode

**API Integration**:
- Uses `AuthProvider` for state management
- Maintains existing API contract:
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/register`
- Token stored in SharedPreferences as 'auth_token'

**Navigation**:
- After successful login/registration, navigates to root route (`/`)
- Root route checks onboarding status and routes accordingly

---

### 3. Onboarding Screen

**File**: `frontend/lib/screens/onboarding_screen.dart`

**Purpose**: Multi-page story presentation that introduces the app's concept and user role.

**Features**:
- **3 Story Pages**:
  1. **Welcome to the Treasure Hunt**: Introduces the concept of transforming thrift store operations
  2. **You're an Agent**: Explains the user's role in discovering valuable items (Booties)
  3. **The Mission**: Describes working alongside AI to research and catalog treasures

- **Animations**:
  - Page transitions with slide effects
  - Icon animations (scale with elastic curve)
  - Text fade-in and slide-up animations
  - Animated page indicators

- **Navigation**:
  - Swipeable pages (PageView)
  - "Continue" button on each page
  - Final page has "Meet Reed" button
  - **No skip button** - users must complete all pages

**Page Indicators**:
- Animated dots showing current page
- Active indicator expands to show progress

---

### 4. Reed Introduction Screen

**File**: `frontend/lib/screens/reed_introduction_screen.dart`

**Purpose**: Introduces R.E.E.D. 8 character with visual and text presentation.

**Features**:
- **Visual Introduction**:
  - Animated avatar/icon with pulsing effect
  - Gradient background (blue, purple, pink tones)
  - Glowing shadow effect

- **Text Introduction** (sequential reveal):
  1. **Name**: "R.E.E.D. 8" (large, bold, blue)
  2. **Full Name**: "Rapid Estimation & Entry Droid" (italic, gray)
  3. **Title**: "The Cool Record Store Expert" (bold, purple)
  4. **Catchphrase**: "I speak in Movie Quotes, Music Lyrics, and Sarcasm" (highlighted in orange box)

- **Personality Traits**:
  - Displayed as chips: Knowledgeable, Confident, Playfully Flirty, Sarcastic Wit

- **Call-to-Action Buttons**:
  - **"Call Reed"**: Navigates to PhoneScreen (green button)
  - **"Get Started"**: Marks onboarding complete and navigates to HomeScreen (outlined button)

**Onboarding Completion**:
- When user clicks "Get Started", calls `authProvider.markOnboardingComplete()`
- Stores completion status in SharedPreferences with key: `onboarding_completed_{userId}`
- Navigates to HomeScreen

---

## Routing Logic

**File**: `frontend/lib/main.dart`

The routing logic in `_buildInitialRoute()` determines which screen to show:

```dart
1. Check if loading → Show loading indicator
2. Check if authenticated:
   - NO → Show LandingScreen
   - YES → Check onboarding status:
     - NOT completed → Show OnboardingScreen
     - Completed → Show HomeScreen
```

**Route Configuration**:
- `/` - Root route (handles initial routing logic)
- `/booties` - Booties list screen
- `/phone` - Phone screen
- `/messages` - Messages screen
- `/prompts` - Prompts configuration screen

---

## Onboarding Tracking

**File**: `frontend/lib/providers/auth_provider.dart`

### State Management

The `AuthProvider` tracks onboarding completion:

```dart
bool? _hasCompletedOnboarding;
bool? get hasCompletedOnboarding => _hasCompletedOnboarding;
```

### Methods

- **`_loadOnboardingStatus()`**: Loads onboarding status from SharedPreferences
  - Key format: `onboarding_completed_{userId}`
  - Called after successful login/registration
  - Defaults to `false` if not set

- **`markOnboardingComplete()`**: Marks onboarding as complete
  - Stores `true` in SharedPreferences
  - Updates `_hasCompletedOnboarding` state
  - Notifies listeners

### Storage

- **Location**: SharedPreferences
- **Key Format**: `onboarding_completed_{userId}`
- **Value**: `bool` (true = completed, false = not completed)
- **Scope**: Per-user (tied to user ID)

---

## Implementation Details

### Animation Framework

All screens use Flutter's animation framework:

- **Landing Screen**: `AnimationController` with `Tween` animations
- **Onboarding Screen**: `TweenAnimationBuilder` for page animations
- **Reed Introduction**: `AnimationController` with pulsing effect

### Navigation Patterns

- **Page Transitions**: `PageRouteBuilder` with `FadeTransition`
- **Route Replacement**: `pushReplacement` to prevent back navigation
- **Named Routes**: Used for main app navigation

### State Management

- **Provider Pattern**: `AuthProvider` manages authentication and onboarding state
- **SharedPreferences**: Persistent storage for onboarding completion
- **Consumer Widgets**: React to state changes automatically

---

## Testing the Flow

### First-Time User Flow

1. **Launch App**:
   ```bash
   cd frontend
   flutter run -d chrome
   ```

2. **Landing Screen**:
   - Should see animated logo and app name
   - Wait 3 seconds or tap to proceed

3. **Login Screen**:
   - Click "Add Account" button (switches to register mode)
   - Fill in email, name, password
   - Click "Register"
   - Should navigate to onboarding

4. **Onboarding Screen**:
   - Should see 3 story pages
   - Swipe or click "Continue" to advance
   - Final page shows "Meet Reed" button
   - Click "Meet Reed"

5. **Reed Introduction**:
   - Should see animated character introduction
   - Text appears sequentially
   - Click "Get Started"
   - Should navigate to HomeScreen

### Returning User Flow

1. **Launch App** (with existing account):
   - Should skip landing screen if already authenticated
   - Should skip onboarding if already completed
   - Should go directly to HomeScreen

2. **Verify Onboarding Skip**:
   - Check SharedPreferences for `onboarding_completed_{userId}`
   - Should be `true` after completing onboarding

### Testing Onboarding Reset

To test onboarding again:

1. **Clear SharedPreferences**:
   ```dart
   final prefs = await SharedPreferences.getInstance();
   await prefs.remove('onboarding_completed_{userId}');
   ```

2. **Or create a new account**:
   - Logout
   - Register with new email
   - Should see onboarding flow again

---

## Customization

### Changing Story Content

Edit `frontend/lib/screens/onboarding_screen.dart`:

```dart
final List<OnboardingPage> _pages = [
  const OnboardingPage(
    title: 'Your Title',
    description: 'Your description',
    icon: Icons.your_icon,
    color: Colors.your_color,
  ),
  // Add more pages...
];
```

### Modifying Landing Screen

Edit `frontend/lib/screens/landing_screen.dart`:

- Change animation duration: `Duration(seconds: 3)`
- Modify gradient colors: `LinearGradient` colors
- Replace logo icon: `Icons.search` → your icon

### Updating Reed Introduction

Edit `frontend/lib/screens/reed_introduction_screen.dart`:

- Modify intro texts: `_introTexts` list
- Change personality traits: `traits` list
- Adjust colors: Gradient and chip colors

---

## Troubleshooting

### Onboarding Not Showing

**Issue**: User doesn't see onboarding after registration.

**Solutions**:
1. Check `authProvider.hasCompletedOnboarding` value
2. Verify SharedPreferences key format: `onboarding_completed_{userId}`
3. Ensure `_loadOnboardingStatus()` is called after login/register
4. Check that user ID is available in `_currentUser`

### Navigation Issues

**Issue**: App doesn't navigate correctly between screens.

**Solutions**:
1. Verify route configuration in `main.dart`
2. Check that `Navigator.pushReplacement` is used (not `push`)
3. Ensure `mounted` check before navigation
4. Verify `AuthProvider` state updates trigger rebuilds

### Animation Performance

**Issue**: Animations are laggy or stuttering.

**Solutions**:
1. Reduce animation duration
2. Use `RepaintBoundary` for complex widgets
3. Check for unnecessary rebuilds
4. Profile with Flutter DevTools

---

## Files Reference

### Created Files

- `frontend/lib/screens/landing_screen.dart` - Landing splash screen
- `frontend/lib/screens/onboarding_screen.dart` - Multi-page onboarding
- `frontend/lib/screens/reed_introduction_screen.dart` - Reed character introduction

### Modified Files

- `frontend/lib/main.dart` - Updated routing logic
- `frontend/lib/screens/login_screen.dart` - Added "Add Account" button
- `frontend/lib/providers/auth_provider.dart` - Added onboarding tracking

---

## Future Enhancements

Potential improvements for the landing experience:

1. **Custom Logo Asset**: Replace placeholder icon with actual app logo
2. **Sound Effects**: Add audio feedback for button clicks
3. **Haptic Feedback**: Vibration on page transitions (mobile)
4. **Skip Option**: Add skip button for returning users (if needed)
5. **Progress Tracking**: Show progress percentage during onboarding
6. **Localization**: Support multiple languages for onboarding content
7. **A/B Testing**: Test different onboarding flows
8. **Analytics**: Track onboarding completion rates

---

## Related Documentation

- [Authentication Flow](AUTHENTICATION.md) - Detailed auth documentation
- [Routing Guide](ROUTING.md) - App navigation patterns
- [State Management](STATE_MANAGEMENT.md) - Provider pattern usage
- [Product Profile](../PRODUCT_PROFILE.md) - App concept and R.E.E.D. persona

---

**Last Updated**: 2025-01-27
**Version**: 1.0.0
**Status**: ✅ **IMPLEMENTED** - All screens complete and functional
