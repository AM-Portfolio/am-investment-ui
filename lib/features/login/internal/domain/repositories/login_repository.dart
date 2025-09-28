import '../entities/user.dart';
import '../entities/auth_state.dart';

/// Login repository interface
/// Defines the contract for authentication data operations
abstract class LoginRepository {
  /// Authenticate user with email and password
  Future<AuthState> login(String email, String password);
  
  /// Register new user
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  
  /// Logout current user
  Future<void> logout();
  
  /// Refresh authentication token
  Future<AuthState> refreshToken(String refreshToken);
  
  /// Get current user profile
  Future<User?> getCurrentUser();
  
  /// Validate if user is still authenticated
  Future<bool> isAuthenticated();
  
  /// Validate email format and availability
  Future<bool> isEmailAvailable(String email);
  
  /// Reset password
  Future<void> resetPassword(String email);
  
  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword);
}