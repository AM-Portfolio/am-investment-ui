import '../repositories/auth_repository.dart';
import '../entities/auth_result.dart';

/// Use case for forgot password operation
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._authRepository);
  final AuthRepository _authRepository;

  /// Execute forgot password request
  /// 
  /// [email] User's email address
  /// 
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> call(String email) async {
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

    // Call repository method
    return _authRepository.requestPasswordReset(email.trim());
  }

  /// Validate email format
  bool _isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
}
