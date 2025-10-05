import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration operation
///
/// Handles the business logic for user registration including validation
/// and interaction with the authentication repository
class RegisterUseCase {
  const RegisterUseCase(this._authRepository);
  final AuthRepository _authRepository;

  /// Execute registration with user details
  ///
  /// [name] User's full name
  /// [email] User's email address
  /// [password] User's password
  /// [confirmPassword] Password confirmation
  /// [username] Optional username
  /// [phone] Optional phone number
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> call(
    String name,
    String email,
    String password,
    String confirmPassword, {
    String? username,
    String? phone,
  }) async {
    // Input validation
    if (name.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter your full name',
        errorCode: 'EMPTY_NAME',
      );
    }

    if (email.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter your email address',
        errorCode: 'EMPTY_EMAIL',
      );
    }

    if (!_isValidEmail(email.trim())) {
      return const AuthResult.failure(
        error: 'Please enter a valid email address',
        errorCode: 'INVALID_EMAIL',
      );
    }

    if (password.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter a password',
        errorCode: 'EMPTY_PASSWORD',
      );
    }

    if (password.length < 8) {
      return const AuthResult.failure(
        error: 'Password must be at least 8 characters long',
        errorCode: 'PASSWORD_TOO_SHORT',
      );
    }

    if (password != confirmPassword) {
      return const AuthResult.failure(
        error: 'Passwords do not match',
        errorCode: 'PASSWORD_MISMATCH',
      );
    }

    if (username != null && username.trim().isNotEmpty) {
      if (username.trim().length < 3) {
        return const AuthResult.failure(
          error: 'Username must be at least 3 characters long',
          errorCode: 'USERNAME_TOO_SHORT',
        );
      }

      if (!_isValidUsername(username.trim())) {
        return const AuthResult.failure(
          error: 'Username can only contain letters, numbers, and underscores',
          errorCode: 'INVALID_USERNAME',
        );
      }
    }

    if (phone != null && phone.trim().isNotEmpty) {
      if (!_isValidPhone(phone.trim())) {
        return const AuthResult.failure(
          error: 'Please enter a valid phone number',
          errorCode: 'INVALID_PHONE',
        );
      }
    }

    // Check if email is already taken
    if (await _authRepository.isIdentifierTaken(email.trim(), 'email')) {
      return const AuthResult.failure(
        error: 'This email address is already registered',
        errorCode: 'EMAIL_TAKEN',
      );
    }

    // Check if username is already taken
    if (username != null && username.trim().isNotEmpty) {
      if (await _authRepository.isIdentifierTaken(
        username.trim(),
        'username',
      )) {
        return const AuthResult.failure(
          error: 'This username is already taken',
          errorCode: 'USERNAME_TAKEN',
        );
      }
    }

    // Check if phone is already taken
    if (phone != null && phone.trim().isNotEmpty) {
      if (await _authRepository.isIdentifierTaken(phone.trim(), 'phone')) {
        return const AuthResult.failure(
          error: 'This phone number is already registered',
          errorCode: 'PHONE_TAKEN',
        );
      }
    }

    // Delegate to repository
    return _authRepository.register(
      name.trim(),
      email.trim(),
      password,
      username: username?.trim(),
      phone: phone?.trim(),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);

  /// Validate username format (alphanumeric and underscores only)
  bool _isValidUsername(String username) =>
      RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);

  /// Validate phone number format (basic validation)
  bool _isValidPhone(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Should start with + and have at least 10 digits after country code
    return RegExp(r'^\+\d{10,15}$').hasMatch(digitsOnly);
  }
}
