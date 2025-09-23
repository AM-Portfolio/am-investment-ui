# AM Investment UI - Development Context

This document provides essential context for AI assistants working with this codebase.

## Project Overview

AM Investment UI is a cross-platform Flutter application for investment management, supporting web, Android, and iOS platforms. The application follows a component-first approach with a focus on platform adaptivity and responsive design.

## Architecture & Structure

### Project Structure

```
lib/
├── main.dart                     # Entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # Colors, fonts, spacing
│   ├── services/
│   │   └── auth_service.dart     # API, Firebase, etc.
│   └── utils/
│       └── platform_utils.dart   # Helper for platform detection
├── features/                     # Feature modules (clean architecture)
│   ├── home/
│   │   ├── home_screen.dart      # Shared logic + base widget
│   │   ├── web/
│   │   │   └── home_web_screen.dart      # Web-specific UI
│   │   ├── ios/
│   │   │   └── home_ios_screen.dart      # iOS-specific UI
│   │   └── android/
│   │       └── home_android_screen.dart  # Android-specific UI
│   │
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── web/profile_web_screen.dart
│   │   ├── ios/profile_ios_screen.dart
│   │   └── android/profile_android_screen.dart
│   └── ...
├── widgets/
│   ├── shared/                   # Reusable across platforms
│   │   ├── custom_button.dart
│   │   └── card_widget.dart
│   └── platform/                 # Platform-aware widgets
│       ├── responsive_layout.dart
│       └── platform_button.dart
├── routes/
│   └── app_router.dart           # GoRouter or Navigator 2.0 routing
└── themes/
    ├── light_theme.dart
    └── dark_theme.dart
```

### State Management

- Use Provider/Riverpod for simple state
- Use BLoC pattern for complex business logic
- Keep state at appropriate levels (widget, screen, or app-wide)

## Coding Standards

### General Guidelines

1. **Naming Conventions**
   - Use `camelCase` for variables and functions
   - Use `PascalCase` for classes and enums
   - Use `snake_case` for file names
   - Prefix private members with underscore

2. **File Organization**
   - One widget per file for reusable components
   - Group related functionality in feature folders
   - Keep files under 300 lines when possible

3. **Comments and Documentation**
   - Use `///` for public API documentation
   - Document all public methods and classes
   - Include examples for complex functionality
   - Explain "why" not "what" in implementation comments

### Platform-Specific Code

1. **Platform Detection**
   - Use `Platform.isIOS`, `Platform.isAndroid`, and `kIsWeb` for platform-specific behaviors
   - Implement `PlatformWidget` base class for components that need different implementations per platform

2. **Responsive Design**
   - Use `MediaQuery` and `LayoutBuilder` for responsive layouts
   - Implement `ScreenUtil` for consistent sizing across devices
   - Define breakpoints for mobile, tablet, and desktop in `core/constants/breakpoints.dart`

### Component Guidelines

1. **Reusable Components**
   - Create platform-adaptive components in `core/widgets/`
   - Follow the component naming convention: `App{ComponentType}` (e.g., `AppButton`, `AppTextField`)
   - Implement loading states for async operations
   - Support both light and dark themes

2. **Theming**
   - Define all colors in `core/theme/colors.dart`
   - Define all text styles in `core/theme/text_styles.dart`
   - Use semantic color names (e.g., `primaryAction` not `blue`)

## Authentication System

The application uses a flexible authentication system with multiple login options:

1. **Multi-Method Login**
   - Email address
   - Username
   - Phone number (with country code)

2. **Test Users**
   - Test users are loaded from `assets/test_users.json`
   - In debug mode, these users can be used without making API calls
   - Fallback test user: `demo@example.com` / `password123`

3. **AuthService**
   - Singleton service for authentication operations
   - Stream-based auth state management
   - Session persistence using SharedPreferences

## Testing Guidelines

1. **Unit Tests**
   - Test all business logic and services
   - Mock external dependencies
   - Aim for 80% code coverage

2. **Widget Tests**
   - Test all reusable widgets
   - Verify both appearance and behavior
   - Test different states (loading, error, success)

3. **Integration Tests**
   - Test critical user flows
   - Verify cross-platform compatibility

## Performance Guidelines

1. **Image Optimization**
   - Use SVGs when possible
   - Provide appropriate resolution assets for raster images
   - Lazy load images when appropriate

2. **State Management**
   - Minimize rebuilds with proper state management
   - Use const constructors when possible
   - Implement pagination for large lists

3. **Network Requests**
   - Cache responses when appropriate
   - Implement retry logic for failed requests
   - Show loading indicators for long operations

## Deployment

The application is deployed using:
- Web: Azure Static Web Apps
- Android: Google Play Store
- iOS: Apple App Store

CI/CD is handled through GitHub Actions with the workflow defined in `.github/workflows/`.
