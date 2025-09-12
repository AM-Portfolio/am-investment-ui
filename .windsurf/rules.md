# AM Investment UI - Coding Rules

This document outlines specific rules and best practices that should be followed when modifying or adding code to this repository.

## General Rules

1. **Always follow the existing patterns** in the codebase. Look at similar files for guidance.
2. **Never modify the project structure** without explicit permission.
3. **Always write tests** for new functionality.
4. **Always update documentation** when changing behavior.

## Dart & Flutter Specific Rules

1. **Use `const` constructors** whenever possible for better performance.
2. **Avoid using `setState`** for complex state management; use Provider/Riverpod or BLoC instead.
3. **Avoid direct string literals** in UI; use constants or localization.
4. **Always use named parameters** for widgets with more than 2 parameters.
5. **Prefer composition over inheritance** when creating new widgets.
6. **Always handle loading and error states** in async operations.
7. **Use `late` variables sparingly** and only when you're certain they'll be initialized before use.
8. **Avoid using `dynamic` type** unless absolutely necessary.

## Platform-Specific Code

1. **Always use platform detection** rather than duplicating code.
2. **Implement platform-specific widgets** using the `PlatformWidget` base class.
3. **Test all features on all supported platforms** (web, Android, iOS).
4. **Use platform-specific assets** when necessary (different icons for iOS vs. Material).

## Component Guidelines

1. **Follow the naming convention** for components: `App{ComponentType}`.
2. **Implement both light and dark theme support** for all UI components.
3. **Make all UI components responsive** using `MediaQuery` or `LayoutBuilder`.
4. **Implement loading states** for all components that perform async operations.
5. **Use semantic color names** from the theme, not hardcoded colors.

## State Management

1. **Use Provider/Riverpod** for simple state management.
2. **Use BLoC pattern** for complex business logic.
3. **Keep state at the appropriate level** - don't make everything global.
4. **Separate UI from business logic** using presentation models.

## Authentication Rules

1. **Never store sensitive data** (like passwords) in plain text.
2. **Always use the AuthService** for authentication operations.
3. **Handle authentication errors gracefully** with user-friendly messages.
4. **Support all login methods** (email, username, phone) consistently.
5. **Maintain test user functionality** in debug mode.

## Error Handling

1. **Never silently catch exceptions** without proper handling.
2. **Use appropriate error messages** for different error types.
3. **Log errors** for debugging but not sensitive information.
4. **Implement retry logic** for network operations where appropriate.

## Performance Guidelines

1. **Minimize rebuilds** by using const constructors and proper state management.
2. **Optimize image assets** for different screen densities.
3. **Use pagination** for large lists.
4. **Implement caching** for network requests where appropriate.
5. **Avoid expensive operations** on the main thread.

## Testing Requirements

1. **Write unit tests** for all business logic.
2. **Write widget tests** for all reusable components.
3. **Maintain 80% code coverage** for all new code.
4. **Test edge cases** and error scenarios.

## Documentation

1. **Document all public APIs** with `///` comments.
2. **Include examples** for complex functionality.
3. **Update the README** when adding major features.
4. **Document known limitations** and edge cases.

## Code Structure and Design

1. **Class Size Limit**: No class should exceed 500 lines of code. Break larger classes into smaller, focused components.
2. **Method Size Limit**: Keep methods short and focused, ideally under 30 lines.
3. **Parameter Limit**: Methods should have no more than 4 parameters. Use parameter objects for more complex cases.
4. **Initialization Pattern**: Keep `initState` and constructors simple. Move complex initialization to separate methods.
5. **Extraction Principle**: If a method does more than one thing, extract the additional functionality.
6. **Reusability Focus**: Design components to be reusable from the start:
   - Accept customization parameters
   - Use callback functions for behavior customization
   - Avoid hardcoding values that might change
7. **Dependency Injection**: Pass dependencies explicitly rather than creating them internally.
8. **Testability**: Design code with testing in mind - avoid singletons and global state when possible.
