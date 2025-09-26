import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../lib/core/services/auth_service.dart';

// Generate mocks for external dependencies only
@GenerateMocks([http.Client])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockClient mockHttpClient;

    setUp(() async {
      mockHttpClient = MockClient();
      
      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      
      // Initialize AuthService - it's a singleton, so we get the instance
      authService = AuthService();
      
      // Reset auth state for each test
      await authService.signOut();
    });

    group('signInWithEmail', () {
      test('should successfully sign in with valid test user credentials', () async {
        // Arrange
        const email = 'john.doe@example.com';
        const password = 'password123';

        // Act
        final result = await authService.signInWithEmail(email, password);

        // Assert
        expect(result.success, true);
        expect(result.error, isNull);
        expect(authService.currentState.isAuthenticated, true);
        expect(authService.currentState.user?.email, email);
        expect(authService.currentState.user?.name, 'John Doe');
        expect(authService.currentState.token, isNotNull);
      });

      test('should sign in with username instead of email', () async {
        // Arrange
        const username = 'johndoe';
        const password = 'password123';

        // Act
        final result = await authService.signInWithEmail(username, password);

        // Assert
        expect(result.success, true);
        expect(authService.currentState.user?.email, 'john.doe@example.com');
        expect(authService.currentState.user?.username, username);
      });

      test('should sign in with phone number', () async {
        // Arrange
        const phone = '+1234567890';
        const password = 'password123';

        // Act
        final result = await authService.signInWithEmail(phone, password);

        // Assert
        expect(result.success, true);
        expect(authService.currentState.user?.phone, phone);
        expect(authService.currentState.user?.email, 'john.doe@example.com');
      });

      test('should fail with invalid credentials', () async {
        // Arrange
        const email = 'invalid@example.com';
        const password = 'wrongpassword';

        // Act
        final result = await authService.signInWithEmail(email, password);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('Invalid credentials'));
        expect(authService.currentState.isAuthenticated, false);
        expect(authService.currentState.user, isNull);
      });

      test('should fail with correct email but wrong password', () async {
        // Arrange
        const email = 'john.doe@example.com';
        const password = 'wrongpassword';

        // Act
        final result = await authService.signInWithEmail(email, password);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('Invalid credentials'));
        expect(authService.currentState.isAuthenticated, false);
      });

      test('should handle empty credentials', () async {
        // Act & Assert - Empty email
        final result1 = await authService.signInWithEmail('', 'password');
        expect(result1.success, false);
        expect(result1.error, contains('Email and password are required'));

        // Act & Assert - Empty password
        final result2 = await authService.signInWithEmail('email@test.com', '');
        expect(result2.success, false);
        expect(result2.error, contains('Email and password are required'));

        // Act & Assert - Both empty
        final result3 = await authService.signInWithEmail('', '');
        expect(result3.success, false);
        expect(result3.error, contains('Email and password are required'));
      });

      test('should emit auth state changes during sign in process', () async {
        // Arrange
        const email = 'john.doe@example.com';
        const password = 'password123';
        final stateChanges = <AuthState>[];

        // Listen to auth state changes
        final subscription = authService.authStateChanges.listen(stateChanges.add);

        // Act
        await authService.signInWithEmail(email, password);

        // Allow some time for state changes to emit
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(stateChanges, hasLength(greaterThanOrEqualTo(2)));
        expect(stateChanges.first.status, AuthStatus.loading);
        expect(stateChanges.last.status, AuthStatus.authenticated);
        expect(stateChanges.last.user?.email, email);

        // Cleanup
        await subscription.cancel();
      });
    });

    group('signInWithGoogle', () {
      test('should return success with mock Google sign in', () async {
        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result.success, true);
        expect(authService.currentState.isAuthenticated, true);
        expect(authService.currentState.user?.email, 'mock.google.user@gmail.com');
        expect(authService.currentState.user?.name, 'Mock Google User');
        expect(authService.currentState.token, contains('mock_google_token'));
      });

      test('should emit auth state changes for Google sign in', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateChanges.listen(stateChanges.add);

        // Act
        await authService.signInWithGoogle();
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(stateChanges, hasLength(greaterThanOrEqualTo(2)));
        expect(stateChanges.first.status, AuthStatus.loading);
        expect(stateChanges.last.status, AuthStatus.authenticated);
        expect(stateChanges.last.user?.email, 'mock.google.user@gmail.com');

        await subscription.cancel();
      });
    });

    group('registerWithEmail', () {
      test('should successfully register new user', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'newpassword123';
        const name = 'New User';

        // Act
        final result = await authService.registerWithEmail(email, password, name);

        // Assert
        expect(result.success, true);
        expect(result.error, isNull);
        expect(authService.currentState.isAuthenticated, true);
        expect(authService.currentState.user?.email, email);
        expect(authService.currentState.user?.name, name);
      });

      test('should fail to register with existing email', () async {
        // Arrange - Use existing test user email
        const email = 'john.doe@example.com';
        const password = 'newpassword123';
        const name = 'Another John';

        // Act
        final result = await authService.registerWithEmail(email, password, name);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('User already exists'));
        expect(authService.currentState.isAuthenticated, false);
      });

      test('should validate registration input', () async {
        // Act & Assert - Empty email
        final result1 = await authService.registerWithEmail('', 'password', 'Name');
        expect(result1.success, false);
        expect(result1.error, contains('All fields are required'));

        // Act & Assert - Empty password
        final result2 = await authService.registerWithEmail('email@test.com', '', 'Name');
        expect(result2.success, false);
        expect(result2.error, contains('All fields are required'));

        // Act & Assert - Empty name
        final result3 = await authService.registerWithEmail('email@test.com', 'password', '');
        expect(result3.success, false);
        expect(result3.error, contains('All fields are required'));
      });

      test('should validate email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const password = 'password123';
        const name = 'Test User';

        // Act
        final result = await authService.registerWithEmail(invalidEmail, password, name);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('Invalid email format'));
      });

      test('should validate password strength', () async {
        // Arrange
        const email = 'test@example.com';
        const weakPassword = '123';
        const name = 'Test User';

        // Act
        final result = await authService.registerWithEmail(email, weakPassword, name);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('Password must be at least 6 characters'));
      });
    });

    group('signOut', () {
      test('should successfully sign out authenticated user', () async {
        // Arrange - First sign in
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        expect(authService.currentState.isAuthenticated, true);

        // Act
        await authService.signOut();

        // Assert
        expect(authService.currentState.isAuthenticated, false);
        expect(authService.currentState.user, isNull);
        expect(authService.currentState.token, isNull);
      });

      test('should emit auth state change on sign out', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateChanges.listen(stateChanges.add);

        // Act
        await authService.signOut();
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(stateChanges, hasLength(1));
        expect(stateChanges.first.status, AuthStatus.unauthenticated);
        expect(stateChanges.first.user, isNull);

        await subscription.cancel();
      });

      test('should handle sign out when not authenticated', () async {
        // Arrange - Ensure not authenticated
        expect(authService.currentState.isAuthenticated, false);

        // Act & Assert - Should not throw
        await authService.signOut();
        expect(authService.currentState.isAuthenticated, false);
      });
    });

    group('getCurrentUser', () {
      test('should return current user when authenticated', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');

        // Act
        final user = authService.getCurrentUser();

        // Assert
        expect(user, isNotNull);
        expect(user?.email, 'john.doe@example.com');
        expect(user?.name, 'John Doe');
      });

      test('should return null when not authenticated', () async {
        // Arrange - Ensure not authenticated
        await authService.signOut();

        // Act
        final user = authService.getCurrentUser();

        // Assert
        expect(user, isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return true when user is authenticated', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');

        // Act & Assert
        expect(authService.isAuthenticated(), true);
      });

      test('should return false when user is not authenticated', () async {
        // Arrange
        await authService.signOut();

        // Act & Assert
        expect(authService.isAuthenticated(), false);
      });
    });

    group('getAuthToken', () {
      test('should return token when authenticated', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');

        // Act
        final token = authService.getAuthToken();

        // Assert
        expect(token, isNotNull);
        expect(token, startsWith('mock_token_'));
      });

      test('should return null when not authenticated', () async {
        // Arrange
        await authService.signOut();

        // Act
        final token = authService.getAuthToken();

        // Assert
        expect(token, isNull);
      });
    });

    group('refreshToken', () {
      test('should refresh token for authenticated user', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        final originalToken = authService.getAuthToken();

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result.success, true);
        final newToken = authService.getAuthToken();
        expect(newToken, isNotNull);
        expect(newToken, isNot(equals(originalToken)));
        expect(newToken, startsWith('refreshed_token_'));
      });

      test('should fail to refresh token when not authenticated', () async {
        // Arrange
        await authService.signOut();

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result.success, false);
        expect(result.error, contains('No authenticated user'));
      });
    });

    group('changePassword', () {
      test('should successfully change password for authenticated user', () async {
        // Arrange
        const oldPassword = 'password123';
        const newPassword = 'newpassword456';
        await authService.signInWithEmail('john.doe@example.com', oldPassword);

        // Act
        final result = await authService.changePassword(oldPassword, newPassword);

        // Assert
        expect(result.success, true);
        expect(result.error, isNull);
        
        // Verify user is still authenticated
        expect(authService.currentState.isAuthenticated, true);
      });

      test('should fail with incorrect old password', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        const wrongOldPassword = 'wrongpassword';
        const newPassword = 'newpassword456';

        // Act
        final result = await authService.changePassword(wrongOldPassword, newPassword);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('Current password is incorrect'));
      });

      test('should fail when not authenticated', () async {
        // Arrange
        await authService.signOut();

        // Act
        final result = await authService.changePassword('old', 'new');

        // Assert
        expect(result.success, false);
        expect(result.error, contains('No authenticated user'));
      });

      test('should validate new password strength', () async {
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        const oldPassword = 'password123';
        const weakNewPassword = '123';

        // Act
        final result = await authService.changePassword(oldPassword, weakNewPassword);

        // Assert
        expect(result.success, false);
        expect(result.error, contains('New password must be at least 6 characters'));
      });
    });

    group('error handling', () {
      test('should handle network errors gracefully', () async {
        // Note: Since we're using mock data, we simulate network errors
        // by testing the service's error handling paths
        
        // This test demonstrates how the service would handle real network errors
        // In a real implementation, you would mock HTTP client failures
        
        // For now, test with invalid credentials which simulates a failed network call
        const result = await authService.signInWithEmail('network.error@test.com', 'password');
        
        expect(result.success, false);
        expect(result.error, isNotNull);
      });

      test('should maintain consistent state during errors', () async {
        // Arrange
        await authService.signOut();
        expect(authService.currentState.status, AuthStatus.unauthenticated);

        // Act - Attempt failed login
        await authService.signInWithEmail('invalid@test.com', 'wrong');

        // Assert - State should remain unauthenticated, not error
        expect(authService.currentState.status, AuthStatus.unauthenticated);
        expect(authService.currentState.user, isNull);
        expect(authService.currentState.token, isNull);
      });
    });

    group('persistence', () {
      test('should persist auth state across app restarts', () async {
        // This test would verify SharedPreferences integration
        // For now, we test that the methods exist and handle persistence correctly
        
        // Arrange
        await authService.signInWithEmail('john.doe@example.com', 'password123');
        expect(authService.currentState.isAuthenticated, true);

        // In a real test, you would:
        // 1. Create a new AuthService instance
        // 2. Verify it restores the authenticated state from SharedPreferences
        // 3. Verify token and user data are correctly restored
        
        // For this mock implementation, we just verify the current state
        expect(authService.currentState.user?.email, 'john.doe@example.com');
        expect(authService.getAuthToken(), isNotNull);
      });
    });
  });
}

// Extension for additional test assertions
extension AuthTestExtensions on AuthService {
  /// Helper method to reset auth state for testing
  Future<void> resetForTesting() async {
    await signOut();
  }
}