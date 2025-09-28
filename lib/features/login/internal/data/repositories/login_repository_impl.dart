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

      return AuthState(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
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
    // For now, just simulate logout
    // In real app, get current token and call remoteDataSource.logout(token)
    await Future.delayed(const Duration(milliseconds: 500));
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
      // For now, return mock user
      // In real app, get current token and call remoteDataSource.getCurrentUser(token)
      return const User(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );
    } catch (error) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // For now, always return false for demo
    // In real app, check stored token validity
    return false;
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
}