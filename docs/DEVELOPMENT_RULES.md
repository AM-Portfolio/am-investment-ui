```markdown
# Development Rules & Guidelines

## Before Writing Code

1. **Always Read Existing Files First**
   - Examine similar implementations
   - Understand established patterns
   - Follow existing naming conventions
   - Match code structure and style

2. **Configuration Management**
   - All configuration in `assets/application.properties`
   - Use `ConfigService` to access properties
   - Support environment-specific configs (`application-dev.properties`)

3. **Error Handling Pattern**
```dart
try {
  final result = await apiCall();
  return result;
} catch (e) {
  debugPrint('Error in [operation]: $e');
  rethrow;
}
```

## File Organization Rules

### API Models Location
```
lib/core/data/api/models/api_[feature].dart
```

### Service Implementation
```
lib/core/services/[feature]_service.dart
lib/core/services/api/[feature]_client.dart
```

### Feature Structure
```
lib/features/[feature]/
├── screens/[feature]_screen.dart
├── widgets/[feature]_widget.dart
└── web/[feature]_web_screen.dart
```

## Code Generation

### Required Imports for Freezed
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[file_name].freezed.dart';
part '[file_name].g.dart';
```

### Run Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```
```