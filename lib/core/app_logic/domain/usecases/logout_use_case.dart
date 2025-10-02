import '../repositories/auth_repository.dart';

/// Use case for user logout operation
/// 
/// Handles the business logic for user logout including cleanup
/// and interaction with the authentication repository
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  /// Execute logout operation
  /// 
  /// Clears all authentication data and notifies listeners
  Future<void> call() async {
    await _authRepository.logout();
  }
}