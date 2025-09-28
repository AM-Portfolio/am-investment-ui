import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_data_source.dart';

/// Implementation of LoginRepository
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthState> login(String email, String password) async {
    try {
      final data = await remoteDataSource.login(email, password);
      
      // For now, create mock user - in real app, parse from API response
      final user = User(
        id: data['user']['id'] ?? '1',
        email: email,
        firstName: data['user']['firstName'] ?? 'Test',
        lastName: data['user']['lastName'] ?? 'User',
      );

      final authState = AuthState(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        tokenExpiresAt: data['expiresAt'] != null 
          ? DateTime.parse(data['expiresAt'])
          : DateTime.now().add(const Duration(hours: 1)),
      );

      // Store authentication data for persistence
      await _saveAuthData(user, data['accessToken']);

      return authState;
    } catch (error) {
      return AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final data = await remoteDataSource.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    return User(
      id: data['user']['id'] ?? '1',
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    try {
      // Clear stored authentication data
      await _clearAuthData();
      
      // For now, just simulate logout - in real app, call remoteDataSource.logout(token)
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<AuthState> refreshToken(String refreshToken) async {
    try {
      final data = await remoteDataSource.refreshToken(refreshToken);
      
      return AuthState(
        isAuthenticated: true,
        isLoading: false,
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        tokenExpiresAt: data['expiresAt'] != null 
          ? DateTime.parse(data['expiresAt'])
          : DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (error) {
      return AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userJson);
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check if we have stored authentication data
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');
      
      // Return true if both token and user data exist
      return token != null && userData != null;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    return await remoteDataSource.isEmailAvailable(email);
  }

  @override
  Future<void> resetPassword(String email) async {
    // TODO: Implement password reset
    throw UnimplementedError('Password reset not implemented yet');
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    // TODO: Implement password change
    throw UnimplementedError('Password change not implemented yet');
  }

  /// Save authentication data to persistent storage
  Future<void> _saveAuthData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  /// Clear authentication data from persistent storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}