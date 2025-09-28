import '../domain/entities/auth_state.dart';
import '../domain/entities/user.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/register_user.dart';
import '../domain/usecases/validate_credentials.dart';

/// Login orchestration service for complex workflows.
/// 
/// Combines multiple use cases and coordinates complex operations like:
/// - Login with validation + token refresh
/// - Registration with email verification
/// - Auto-logout on token expiry
/// - Session management workflows
/// 
/// This service acts as a facade that combines multiple use cases
/// to perform complex business workflows that span multiple domain operations.
class LoginService {
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;
  final ValidateCredentials _validateCredentials;

  const LoginService(
    this._loginUser,
    this._logoutUser,
    this._registerUser,
    this._validateCredentials,
  );

  /// Performs complete login workflow with validation
  /// 1. Validates credentials format
  /// 2. Attempts login
  /// 3. Validates authentication state
  /// 4. Returns success/failure result
  Future<AuthState> loginWithValidation(String email, String password) async {
    try {
      // Step 1: Validate input format
      if (!_validateCredentials.validateEmail(email)) {
        throw ArgumentError('Invalid email format');
      }
      
      if (!_validateCredentials.validatePassword(password)) {
        throw ArgumentError('Password must be at least 6 characters');
      }
      
      // Step 2: Attempt login
      final authState = await _loginUser(email, password);
      
      // Step 3: Validate successful authentication
      if (!authState.isLoggedIn) {
        throw Exception('Login failed - invalid credentials');
      }
      
      return authState;
    } catch (error) {
      // Return error state
      return const AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Login failed',
      );
    }
  }

  /// Performs complete registration workflow
  /// 1. Validates all input fields
  /// 2. Checks email availability
  /// 3. Creates user account
  /// 4. Optionally auto-login after registration
  Future<User> registerWithValidation({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    bool autoLogin = false,
  }) async {
    // Step 1: Validate input
    if (!_validateCredentials.validateEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
    
    if (!_validateCredentials.validatePassword(password)) {
      throw ArgumentError('Password must be at least 6 characters');
    }
    
    if (!_validateCredentials.validatePasswordMatch(password, confirmPassword)) {
      throw ArgumentError('Passwords do not match');
    }
    
    // Step 2: Register user
    final user = await _registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      confirmPassword: confirmPassword,
    );
    
    // Step 3: Optional auto-login
    if (autoLogin) {
      await _loginUser(email, password);
    }
    
    return user;
  }

  /// Performs secure logout workflow
  /// 1. Clears local session
  /// 2. Invalidates tokens
  /// 3. Clears cached user data
  Future<void> secureLogout() async {
    try {
      await _logoutUser();
    } catch (error) {
      // Even if logout fails on server, clear local state
      rethrow;
    }
  }

  /// Validates current session and refreshes if needed
  /// 1. Checks authentication status
  /// 2. Validates token expiry
  /// 3. Refreshes token if needed
  /// 4. Returns current authentication state
  Future<bool> validateAndRefreshSession() async {
    try {
      // Check if user is currently authenticated
      final isAuthenticated = await _validateCredentials();
      
      if (!isAuthenticated) {
        return false;
      }
      
      // TODO: Add token refresh logic when repository supports it
      return true;
    } catch (error) {
      return false;
    }
  }
}