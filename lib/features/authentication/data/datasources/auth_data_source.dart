import '../models/auth_result_model.dart';
import '../models/auth_tokens_model.dart';

/// Interface for authentication data sources
abstract class AuthDataSource {
  /// Login with email and password
  Future<AuthResultModel> emailLogin(String email, String password);

  /// Login with Google
  Future<AuthResultModel> googleLogin();

  /// Login with demo account
  Future<AuthResultModel> demoLogin();

  /// Logout
  Future<void> logout();

  /// Refresh token
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
