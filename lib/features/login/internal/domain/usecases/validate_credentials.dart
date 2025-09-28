import '../repositories/login_repository.dart';

/// Use case for validating user credentials
class ValidateCredentials {
  final LoginRepository _repository;
  
  const ValidateCredentials(this._repository);
  
  /// Check if user is currently authenticated
  Future<bool> call() async {
    return await _repository.isAuthenticated();
  }
  
  /// Validate email format
  bool validateEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate password strength
  bool validatePassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }
  
  /// Validate passwords match
  bool validatePasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}