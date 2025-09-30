# Authentication Module - Clean Architecture

This document explains the refactored authentication module that follows clean architecture principles with proper separation of concerns.

## Architecture Overview

The authentication module has been restructured into the following layers:

```
app_logic/
├── domain/                 # Business logic and abstract contracts
│   ├── entities/          # Data models and value objects
│   ├── repositories/      # Abstract repository interfaces  
│   └── usecases/         # Business use cases
├── data/                  # Data access and external dependencies
│   ├── datasources/      # Abstract and concrete data sources
│   ├── repositories/     # Repository implementations
│   └── dtos/             # Data transfer objects (if needed)
└── services/             # High-level service layer
```

## Key Components

### Domain Layer (`domain/`)

#### Entities
- **AuthResult**: Freezed union type for operation results (success/failure)
- **TestUser**: Freezed entity for test user data

#### Repository Interface
- **AuthRepository**: Abstract interface defining authentication operations
- Provides contracts for login, register, logout, token refresh, etc.
- Allows different implementations (API, local storage, mock)

#### Use Cases  
- **LoginUseCase**: Validates input and executes login business logic
- **RegisterUseCase**: Handles registration with comprehensive validation
- **LogoutUseCase**: Manages logout operations
- **GetAuthStateUseCase**: Handles authentication state management
- **GetTestUsersUseCase**: Manages test user data retrieval

### Data Layer (`data/`)

#### Data Sources
- **AuthDataSource**: Abstract interface for data operations
- **AuthLocalDataSource**: Handles test users and local/demo authentication
- **AuthRemoteDataSource**: Manages API calls for production
- **AuthStorageDataSource**: Handles persistent storage operations

#### Repository Implementation
- **AuthRepositoryImpl**: Concrete implementation combining all data sources
- Handles environment-specific logic (debug vs production)
- Manages state changes and error handling
- Coordinates between local and remote data sources

### Service Layer (`services/`)

#### Clean Service
- **AuthService** (renamed to AuthServiceClean): High-level service facade
- Uses dependency injection for all components
- Provides simple interface for UI layer
- Handles additional validation and error management

## Key Design Patterns

### 1. Clean Architecture
- **Dependency Inversion**: Business logic doesn't depend on implementation details
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to mock and test individual components

### 2. Repository Pattern
- Abstracts data access behind interfaces
- Allows switching between different data sources
- Centralizes data logic and caching

### 3. Use Case Pattern
- Each business operation has its own use case
- Contains validation and business rules
- Provides clear single-responsibility components

### 4. Dependency Injection
- Components receive dependencies through constructor injection
- Makes testing easier and reduces coupling
- Allows flexible configuration

## Usage Examples

### Basic Authentication
```dart
// Import the clean auth module
import 'package:your_app/core/app_logic/auth_module.dart';

// Initialize the service
final authService = AuthService();
await authService.initialize();

// Login
final result = await authService.login('user@example.com', 'password');
if (result.isSuccess) {
  // Handle success
} else {
  // Handle error: result.errorMessage
}

// Listen to auth state changes
authService.authStateChanges.listen((authState) {
  if (authState.isAuthenticated) {
    // User is logged in
  } else {
    // User is logged out
  }
});
```

### Testing
```dart
// Easy to mock individual components
class MockAuthRepository extends Mock implements AuthRepository {}

final mockRepo = MockAuthRepository();
final loginUseCase = LoginUseCase(mockRepo);

// Test business logic without external dependencies
when(mockRepo.login('test@example.com', 'password'))
  .thenAnswer((_) async => const AuthResult.success());

final result = await loginUseCase('test@example.com', 'password');
expect(result.isSuccess, true);
```

## Migration Guide

### From Old Service to New Clean Architecture

1. **Update Imports**
   ```dart
   // Old
   import 'package:your_app/core/app_logic/services/auth_service.dart';
   
   // New
   import 'package:your_app/core/app_logic/auth_module.dart';
   ```

2. **Service Initialization**
   ```dart
   // Old
   final authService = AuthService();
   await authService.initialize();
   
   // New (same interface)
   final authService = AuthService();
   await authService.initialize();
   ```

3. **Method Calls**
   ```dart
   // Most method signatures remain the same
   // But now with better error handling and validation
   
   // Registration now requires confirmPassword
   final result = await authService.register(
     'John Doe',
     'john@example.com', 
     'password123',
     'password123', // confirm password
     username: 'johndoe',
   );
   ```

## Benefits

### 1. **Maintainability**
- Clear separation of concerns makes code easier to understand
- Changes in one layer don't affect others
- Business logic is isolated from framework dependencies

### 2. **Testability**  
- Each component can be tested in isolation
- Easy to mock dependencies
- Business logic can be tested without UI or network calls

### 3. **Flexibility**
- Easy to switch between different data sources
- Can add new authentication methods without changing business logic
- Environment-specific behavior is properly isolated

### 4. **Scalability**
- New features can be added following the same patterns
- Components are reusable across different parts of the app
- Clear interfaces make team development easier

## Environment Handling

The architecture automatically handles different environments:

- **Debug Mode**: Uses local data sources and test users
- **Production Mode**: Uses remote API calls
- **Hybrid Mode**: Falls back gracefully between local and remote

## Error Handling

Comprehensive error handling at each layer:

- **Use Case Layer**: Input validation and business rule enforcement
- **Repository Layer**: Data access error handling and fallback logic  
- **Service Layer**: Additional validation and user-friendly error messages

## State Management

Clean state management with reactive streams:

- **AuthState**: Immutable state using Freezed
- **State Changes**: Broadcast stream for reactive UI updates
- **Persistence**: Automatic state persistence and restoration

This architecture provides a robust, maintainable, and testable foundation for authentication in your Flutter application.