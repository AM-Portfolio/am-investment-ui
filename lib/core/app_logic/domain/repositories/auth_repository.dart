import '../entities/auth_result.dart';
import '../entities/auth_state.dart';
import '../entities/user.dart';

/// Abstract repository interface for authentication operations
///
/// This interface defines the contract for authentication data operations,
/// allowing different implementations (API, local storage, mock, etc.)
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges;

  /// Get current authentication state
  AuthState get currentState;

  /// Initialize the repository and restore session if available
  Future<void> initialize();

  /// Login with identifier (email, username, or phone) and password
  ///
  /// [identifier] Can be email, username, or phone number
  /// [password] User's password
  ///
  /// Returns [AuthResult] indicating success or failure with error message
  Future<AuthResult> login(String identifier, String password);

  /// Register a new user
  ///
  /// [name] User's full name
  /// [email] User's email address
  /// [password] User's password
  /// [username] Optional username
  /// [phone] Optional phone number
  ///
  /// Returns [AuthResult] indicating success or failure with error message
  Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  });

  /// Logout the current user
  ///
  /// Clears all authentication data and notifies listeners
  Future<void> logout();

  /// Get list of available test users
  ///
  /// Returns list of test users for development/demo purposes
  Future<List<User>> getTestUsers();

  /// Validate if identifier exists (for registration)
  ///
  /// [identifier] Email, username, or phone to check
  /// [type] Type of identifier ('email', 'username', 'phone')
  ///
  /// Returns true if identifier is already taken
  Future<bool> isIdentifierTaken(String identifier, String type);

  /// Refresh authentication token
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> refreshToken();

  /// Change user password
  ///
  /// [oldPassword] Current password
  /// [newPassword] New password
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> changePassword(String oldPassword, String newPassword);

  /// Request password reset
  ///
  /// [email] Email address to send reset instructions
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> requestPasswordReset(String email);

  /// Dispose resources and close streams
  void dispose();
}
