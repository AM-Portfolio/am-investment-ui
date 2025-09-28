import '../repositories/login_repository.dart';

/// Use case for user logout
class LogoutUser {
  final LoginRepository _repository;
  
  const LogoutUser(this._repository);
  
  /// Execute logout
  Future<void> call() async {
    await _repository.logout();
  }
}