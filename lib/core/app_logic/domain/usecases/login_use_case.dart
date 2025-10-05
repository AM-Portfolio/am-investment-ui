import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login operation
///
/// Handles the business logic for user authentication including validation
/// and interaction with the authentication repository
class LoginUseCase {
  const LoginUseCase(this._authRepository);
  final AuthRepository _authRepository;

  /// Execute login with identifier and password
  ///
  /// [identifier] Can be email, username, or phone number
  /// [password] User's password
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> call(String identifier, String password) async {
    // Input validation
    if (identifier.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter your email, username, or phone number',
        errorCode: 'EMPTY_IDENTIFIER',
      );
    }

    if (password.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter your password',
        errorCode: 'EMPTY_PASSWORD',
      );
    }

    if (password.length < 6) {
      return const AuthResult.failure(
        error: 'Password must be at least 6 characters long',
        errorCode: 'PASSWORD_TOO_SHORT',
      );
    }

    // Delegate to repository
    return _authRepository.login(identifier.trim(), password);
  }
}
