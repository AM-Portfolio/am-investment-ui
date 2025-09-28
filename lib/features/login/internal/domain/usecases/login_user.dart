import '../entities/auth_state.dart';
import '../repositories/login_repository.dart';

/// Use case for user login
class LoginUser {
  final LoginRepository _repository;
  
  const LoginUser(this._repository);
  
  /// Execute login with email and password
  Future<AuthState> call(String email, String password) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password cannot be empty');
    }
    
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
    
    // Perform login
    return await _repository.login(email, password);
  }
  
  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}