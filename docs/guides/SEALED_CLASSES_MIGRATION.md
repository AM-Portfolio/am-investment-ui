# Sealed Classes Migration Guide

## Overview

This guide documents the migration from `abstract class` + `@freezed` to **sealed classes** (Dart 3.0+) for better type safety and pattern matching.

## Why Sealed Classes?

### Benefits
1. **Exhaustiveness Checking**: Compiler ensures all cases are handled
2. **Type Safety**: No need for `@freezed` generator for simple hierarchies
3. **Better Pattern Matching**: Switch statements are more powerful
4. **Simpler Code**: Less boilerplate and generated code
5. **Performance**: No reflection or runtime generation needed

### Trade-offs
- Requires **Dart 3.0+** (check pubspec.yaml minimum SDK)
- More manual implementation vs `@freezed` auto-generation
- Better for simple hierarchies (states, failures, events)
- Use `@freezed` for complex data models with serialization

## Migration Pattern

### Before (Abstract Class)
```dart
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
}
```

### After (Sealed Class)
```dart
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
}
```

## Key Differences

| Aspect | Abstract Class | Sealed Class |
|--------|---|---|
| Syntax | `abstract class` | `sealed class` |
| Subclasses | `class` | `final class` |
| Can extend? | ❌ No (outside file) | ❌ No |
| Type Safety | ⚠️ Optional | ✅ Required by compiler |
| Pattern Matching | Basic | Exhaustive |
| Use Cases | Any hierarchy | Closed, fixed hierarchies |

## Usage Examples

### Switch with Sealed Classes (Exhaustive)
```dart
Widget buildUI(AuthState state) {
  return switch (state) {
    AuthInitial() => const SizedBox.shrink(),
    AuthLoading() => const LoadingIndicator(),
    Authenticated(user: final user) => UserProfile(user: user),
    Unauthenticated() => const LoginScreen(),
    AuthError(message: final msg) => ErrorDisplay(msg),
    // ✅ Compiler ensures all cases are covered
  };
}
```

### With Equatable for Comparison
```dart
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}
```

## Files Already Migrated

1. ✅ `lib/core/errors/failures.dart` - Failure hierarchy
2. ✅ `lib/core/network/errors/failures.dart` - Network failures
3. ✅ `lib/features/authentication/presentation/cubit/auth_state.dart` - Auth states

## Files Pending Migration

Search for patterns:
```dart
abstract class [NameEvent/NameState/NameFailure]
```

Common files to migrate:
- `*_event.dart` - BLoC events
- `*_state.dart` - BLoC/Cubit states
- `*_failure.dart` - Domain failures
- Any class hierarchy with fixed, known subtypes

## When to Use What

### Use Sealed Classes ✅
- **States** in BLoC/Cubit
- **Events** in BLoC
- **Failures/Errors** with known types
- **Results** (Success/Failure)
- **UI Models** with fixed variants

### Use @freezed ✅
- **API DTOs** (need JSON serialization)
- **Domain Entities** with equality
- **Complex data models** with nested objects
- **Immutable value objects** with copyWith

### Use Regular Classes ✅
- **Services** and utility classes
- **Repositories** with no subtyping
- **Widgets** and UI components
- **Controllers** and business logic

## Migration Checklist

When converting a file:
- [ ] Change `abstract class` to `sealed class`
- [ ] Change `class Subclass` to `final class Subclass`
- [ ] Remove `@freezed` if only used for hierarchy
- [ ] Test that sealed class hierarchy still works
- [ ] Update switch statements to use pattern matching
- [ ] Verify compilation and no errors

## Code Example: Complete Migration

### Before
```dart
// old_pattern.dart
@freezed
abstract class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.loading() = _Loading;
  const factory PaymentState.success(String message) = _Success;
  const factory PaymentState.error(String message) = _Error;
}
```

### After
```dart
// new_pattern.dart
sealed class PaymentState {
  const PaymentState();
}

final class Initial extends PaymentState {
  const Initial();
}

final class Loading extends PaymentState {
  const Loading();
}

final class Success extends PaymentState {
  const Success(this.message);
  final String message;
}

final class Error extends PaymentState {
  const Error(this.message);
  final String message;
}

// Usage
void handleState(PaymentState state) {
  switch (state) {
    case Initial():
      // Handle initial
      break;
    case Loading():
      // Handle loading
      break;
    case Success(message: final msg):
      // Access message directly
      print(msg);
      break;
    case Error(message: final error):
      // Access error directly
      print(error);
      break;
  }
}
```

## Best Practices

1. **Prefer sealed classes** for fixed hierarchies
2. **Keep hierarchy shallow** (2-3 levels)
3. **Use immutable data** with `final` properties
4. **Document each variant** with comments
5. **Provide examples** in sealed class documentation
6. **Test exhaustiveness** in switch statements

## Resources

- [Dart Sealed Classes](https://dart.dev/language/class-modifiers#sealed)
- [Pattern Matching in Dart](https://dart.dev/language/patterns)
- [Dart 3.0 Release Notes](https://dart.dev/guides/whats-new/releases)

## Frequently Asked Questions

**Q: Do I need @equatable with sealed classes?**
A: Only if you need value equality. If you only care about type, you don't need it.

**Q: Can sealed classes be extended outside the file?**
A: No, that's the point! They're sealed to prevent external subclassing.

**Q: Should I migrate all abstract classes?**
A: No, only those that are part of a closed hierarchy with known, fixed subtypes.

**Q: What about API DTOs?**
A: Keep using `@freezed` because you need JSON serialization. Sealed classes don't generate that.

**Q: How do I handle common fields across all states?**
A: Add abstract properties to the sealed class - all subclasses must implement them.

```dart
sealed class Result<T> {
  const Result();
  
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess);
}

final class Success<T> extends Result<T> {
  final T value;
  
  Success(this.value);
  
  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return onSuccess(value);
  }
}

final class Failure<T> extends Result<T> {
  final String message;
  
  Failure(this.message);
  
  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return onFailure(this);
  }
}
```
