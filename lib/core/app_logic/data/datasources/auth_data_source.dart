import '../../domain/entities/user.dart';

/// Abstract data source for authentication operations
///
/// This interface defines the contract for authentication data operations
/// at the data layer, implemented by different data sources (API, local storage, etc.)
abstract class AuthDataSource {
  /// Login with identifier and password
  ///
  /// [identifier] Email, username, or phone number
  /// [password] User's password
  ///
  /// Returns User data and token on success, throws exception on failure
  Future<AuthDataResponse> login(String identifier, String password);

  /// Register a new user
  ///
  /// [name] User's full name
  /// [email] User's email address
  /// [password] User's password
  /// [username] Optional username
  /// [phone] Optional phone number
  ///
  /// Returns User data and token on success, throws exception on failure
  Future<AuthDataResponse> register(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  });

  /// Refresh authentication token
  ///
  /// [token] Current authentication token
  ///
  /// Returns new token on success, throws exception on failure
  Future<String> refreshToken(String token);

  /// Validate if identifier exists
  ///
  /// [identifier] Email, username, or phone to check
  /// [type] Type of identifier ('email', 'username', 'phone')
  ///
  /// Returns true if identifier is already taken
  Future<bool> isIdentifierTaken(String identifier, String type);

  /// Change user password
  ///
  /// [token] Authentication token
  /// [oldPassword] Current password
  /// [newPassword] New password
  ///
  /// Returns true on success, throws exception on failure
  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  );

  /// Request password reset
  ///
  /// [email] Email address to send reset instructions
  ///
  /// Returns true on success, throws exception on failure
  Future<bool> requestPasswordReset(String email);

  /// Reset password with token
  ///
  /// [resetToken] Reset token from email
  /// [newPassword] New password
  ///
  /// Returns true on success, throws exception on failure
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Get list of test users
  ///
  /// Returns list of test users for development/demo purposes
  Future<List<User>> getTestUsers();
}

/// Response model for authentication data operations
class AuthDataResponse {
  const AuthDataResponse({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });
  final User user;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
}
