# AM Investment UI

A Flutter application for investment management.

## Reusable Components

This project follows a component-first approach to ensure consistency across web, Android, and iOS platforms.

### Component Guidelines

1. **Platform Adaptivity**
   - Use `Platform.isIOS`, `Platform.isAndroid`, and `kIsWeb` for platform-specific behaviors
   - Implement `PlatformWidget` base class for components that need different implementations per platform
   - Prefer Material Design with platform-specific tweaks over completely different UIs

2. **Responsive Design**
   - Use `MediaQuery` and `LayoutBuilder` for responsive layouts
   - Implement `ScreenUtil` for consistent sizing across devices
   - Define breakpoints for mobile, tablet, and desktop in `core/constants/breakpoints.dart`

3. **State Management**
   - Use Provider/Riverpod for simple state
   - Use BLoC pattern for complex business logic
   - Keep state at appropriate levels (widget, screen, or app-wide)

4. **Theming**
   - Define all colors in `core/theme/colors.dart`
   - Define all text styles in `core/theme/text_styles.dart`
   - Support both light and dark modes with `ThemeData`
   - Use semantic color names (e.g., `primaryAction` not `blue`)

5. **Asset Management**
   - Use SVGs when possible for resolution independence
   - Provide 1x, 2x, 3x assets for raster images
   - Use asset constants in `core/constants/assets.dart`

### Common Components

| Component | Description | Usage | Cross-Platform Considerations |
|-----------|-------------|-------|------------------------------|
| `AppButton` | Primary, secondary, text buttons with loading states | Forms, CTAs | Uses `CupertinoButton` on iOS, `ElevatedButton` elsewhere |
| `AppTextField` | Text inputs with validation | Forms, search | Platform-specific keyboard types and input formatting |
| `AppCard` | Consistent card styling | Content containers | Adjusts elevation and border radius by platform |
| `AppDialog` | Modal dialogs | Confirmations, alerts | Bottom sheet on mobile, centered dialog on web |
| `AppScaffold` | Base layout with nav handling | Screen wrapper | Adapts navigation patterns to platform conventions |
| `ResponsiveLayout` | Adapts to screen size | Layout container | Grid-based on web, list-based on mobile |
| `LoadingIndicator` | Consistent loading states | Async operations | `CupertinoActivityIndicator` on iOS, `CircularProgressIndicator` elsewhere |
| `ErrorView` | Standard error handling | Error states | Consistent across platforms with platform-specific icons |

## Automated Coding Standards

To ensure consistent code quality across the project, we've implemented automated standards enforcement:

### Static Analysis

We use Flutter's linting system with custom rules defined in analysis_options.yaml.

### Pre-commit Hooks

We use `git_hooks` to enforce standards before commits:

1. **Format Check**: Ensures code is properly formatted
2. **Lint Check**: Verifies code meets linting standards
3. **Unit Test**: Runs tests to ensure functionality

### CI/CD Pipeline

Our CI/CD pipeline enforces:

- Code coverage requirements (minimum 80%)
- Performance benchmarks
- Cross-platform compatibility tests

### Editor Configuration

VS Code settings are provided in `.vscode/settings.json` to ensure consistent editor behavior.

Developers should install the recommended extensions in `.vscode/extensions.json`.

## Cross-Platform Architecture

### Platform Detection

Use Flutter's platform detection to implement platform-specific behaviors.

### Platform Widget Pattern

Create base widgets that render different implementations based on platform.

### Responsive Layout Strategy

Implement a responsive layout strategy that works across all platforms.

## Project Structure

```
lib/
├── core/                  # Shared infrastructure
│   ├── constants/         # App-wide constants (colors, strings, routes)
│   ├── theme/             # App theme (light/dark, text styles, etc.)
│   ├── utils/             # Helpers (validators, formatters, extensions)
│   ├── widgets/           # Reusable common widgets (buttons, loaders, inputs)
│   ├── services/          # API, storage, navigation, etc.
│   └── errors/            # Error handling
│
├── features/              # Feature-based modules
│   ├── auth/              # Auth feature
│   │   ├── presentation/  # UI (screens, widgets)
│   │   ├── domain/        # Models, interfaces
│   │   └── data/          # Repos, impl, API calls
│   │
│   ├── profile/           # Profile feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── ...                # Other features
│
├── shared/                # Cross-feature reusable logic
│   ├── widgets/           # E.g., CustomAppBar, LoadingIndicator
│   ├── utils/             # Shared helpers
│   └── models/            # Shared data models (e.g., User, Address)
│
├── routes/                # App routing (auto_route or manual)
├── di/                    # Dependency Injection (GetIt, Riverpod, etc.)
└── main.dart              # Entry point
```

## Authentication Features

The application supports a flexible authentication system with multiple login options:

### Multi-Method Login

Users can log in using any of the following identifiers:
- Email address
- Username
- Phone number (with country code)

The login screen provides a segmented control to switch between these methods, with appropriate validation for each type.

### Test Users

For development and testing purposes, the app includes predefined test users loaded from `assets/test_users.json`. In debug mode, these users can be used to log in without making actual API calls.

#### Available Test Users

| ID  | Email             | Username  | Phone          | Password    |
|-----|-------------------|-----------|----------------|------------|
| 123 | demo@example.com  | demouser  | +1234567890    | password123 |
| 456 | test@example.com  | testuser  | +9876543210    | test123    |
| 789 | admin@example.com | admin     | +1122334455    | admin123   |

#### Quick Login

The login screen includes a "Quick Login" button that automatically fills in credentials for the demo user based on the currently selected login method.

### Authentication Service

The `AuthService` class handles all authentication operations including:

- Login with multiple identifier types (email, username, phone)
- User registration with optional fields
- Session persistence using SharedPreferences
- Authentication state management via streams
- Automatic test user detection in debug mode
- Logout functionality

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
