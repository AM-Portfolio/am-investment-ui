# Platform-Specific Implementation Guide

This document outlines the approach for implementing platform-specific UI in the AM Investment UI application.

## Folder Structure

```
lib/features/{feature_name}/
├── {feature_name}_screen.dart       # Base screen with shared logic
├── web/                             # Web-specific implementations
│   └── {feature_name}_web_screen.dart
├── ios/                             # iOS-specific implementations
│   └── {feature_name}_ios_screen.dart
└── android/                         # Android-specific implementations
    └── {feature_name}_android_screen.dart
```

## Implementation Pattern

1. **Base Screen**:
   - Contains shared business logic, state management, and data fetching
   - Uses `PlatformUtils` to determine which platform-specific implementation to render
   - Passes necessary data and callbacks to platform implementations

2. **Platform-Specific Screens**:
   - Focus only on UI/UX concerns specific to that platform
   - Receive data and callbacks from the base screen
   - Follow platform design guidelines:
     - Material Design for Android and Web
     - Cupertino for iOS

3. **Shared Widgets**:
   - Common UI elements used across platforms are in `widgets/` folder
   - Platform-specific widgets use the same pattern as screens

## Platform Detection

Use the `PlatformUtils` class for platform detection:

```dart
import '../../core/utils/platform_utils.dart';

if (PlatformUtils.isWeb) {
  // Web-specific code
} else if (PlatformUtils.isIOS) {
  // iOS-specific code
} else {
  // Android-specific code
}
```

## Best Practices

1. **Keep Logic in Base Screen**:
   - Data fetching, state management, and business logic should be in the base screen
   - Platform-specific screens should focus only on UI/UX

2. **Consistent API**:
   - Platform-specific screens should have consistent constructors and parameters
   - This makes it easy to switch between implementations

3. **Responsive Design**:
   - Web implementations should be responsive to different screen sizes
   - Mobile implementations should adapt to different device sizes

4. **Testing**:
   - Test each platform-specific implementation separately
   - Use conditional tests based on platform

## Example

See the Portfolio Summary feature for a complete example of this pattern:
- `lib/features/portfolio/portfolio_summary_screen.dart`
- `lib/features/portfolio/web/portfolio_web_screen.dart`
- `lib/features/portfolio/ios/portfolio_ios_screen.dart`
- `lib/features/portfolio/android/portfolio_android_screen.dart`
