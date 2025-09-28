import '../entities/user.dart';
import '../repositories/login_repository.dart';

/// Use case for user registration
class RegisterUser {
  final LoginRepository _repository;
  
  const RegisterUser(this._repository);
  
  /// Execute user registration
  Future<User> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? confirmPassword,
  }) async {
    // Validate input
    _validateInput(email, password, firstName, lastName, confirmPassword);
    
    // Check email availability
    final isEmailAvailable = await _repository.isEmailAvailable(email);
    if (!isEmailAvailable) {
      throw ArgumentError('Email is already in use');
    }
    
    // Perform registration
    return await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
  
  void _validateInput(String email, String password, String firstName, String lastName, String? confirmPassword) {
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      throw ArgumentError('All fields are required');
    }
    
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
    
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters long');
    }
    
    if (confirmPassword != null && password != confirmPassword) {
      throw ArgumentError('Passwords do not match');
    }
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}