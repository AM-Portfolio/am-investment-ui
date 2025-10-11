import '../repositories/auth_repository.dart';
import '../entities/auth_result.dart';

/// Use case for reset password operation
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._authRepository);
  final AuthRepository _authRepository;

  /// Execute password reset with token
  /// 
  /// [resetToken] Reset token from email
  /// [newPassword] New password
  /// [confirmPassword] Password confirmation
  /// 
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> call({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (resetToken.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Invalid reset token',
        errorCode: 'INVALID_TOKEN',
      );
    }

    if (newPassword.trim().isEmpty) {
      return const AuthResult.failure(
        error: 'Please enter a new password',
        errorCode: 'EMPTY_PASSWORD',
      );
    }

    if (newPassword.length < 8) {
      return const AuthResult.failure(
        error: 'Password must be at least 8 characters long',
        errorCode: 'PASSWORD_TOO_SHORT',
      );
    }

    if (newPassword != confirmPassword) {
      return const AuthResult.failure(
        error: 'Passwords do not match',
        errorCode: 'PASSWORD_MISMATCH',
      );
    }

    // Call repository method
    return _authRepository.resetPassword(
      resetToken: resetToken.trim(),
      newPassword: newPassword,
    );
  }
}
