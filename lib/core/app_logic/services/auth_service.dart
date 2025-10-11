import 'dart:async';

import 'package:http/http.dart' as http;

import '../../utils/logger.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/auth_storage_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/auth_result.dart';
import '../domain/entities/auth_state.dart';
import '../domain/entities/user.dart';
import '../domain/usecases/get_auth_state_use_case.dart';
import '../domain/usecases/get_test_users_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/register_use_case.dart';

/// Clean architecture authentication service
///
/// This service provides a high-level interface for authentication operations
/// using clean architecture principles with dependency injection
class AuthService {
  factory AuthService() => _instance;

  AuthService._internal() {
    _initializeDependencies();
  }
  late final AuthRepositoryImpl _repository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetAuthStateUseCase _getAuthStateUseCase;
  late final GetTestUsersUseCase _getTestUsersUseCase;

  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  /// Initialize dependency injection
  void _initializeDependencies() {
    AppLogger.methodEntry('_initializeDependencies', tag: 'AuthService');

    // Initialize data sources
    final localDataSource = AuthLocalDataSource();
    final remoteDataSource = AuthRemoteDataSource(
      baseUrl: 'https://api.munish.org', // TODO: Get from environment config
      httpClient: http.Client(),
    );
    final storageDataSource = AuthStorageDataSource();

    // Initialize repository
    _repository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      storageDataSource: storageDataSource,
    );

    // Initialize use cases
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _logoutUseCase = LogoutUseCase(_repository);
    _getAuthStateUseCase = GetAuthStateUseCase(_repository);
    _getTestUsersUseCase = GetTestUsersUseCase(_repository);

    AppLogger.info('Dependencies initialized successfully', tag: 'AuthService');
    AppLogger.methodExit(
      '_initializeDependencies',
      tag: 'AuthService',
      result: 'success',
    );
  }

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges =>
      _getAuthStateUseCase.authStateChanges;

  /// Get current authentication state
  AuthState get currentState => _getAuthStateUseCase.currentState;

  /// Initialize the auth service and restore session if available
  Future<void> initialize() async {
    AppLogger.methodEntry('initialize', tag: 'AuthService');

    try {
      AppLogger.info(
        'Initializing AuthService with clean architecture',
        tag: 'AuthService',
      );
      await _getAuthStateUseCase.initialize();
      AppLogger.info(
        'AuthService initialized successfully',
        tag: 'AuthService',
      );
      AppLogger.methodExit('initialize', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error(
        'Error initializing auth service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('initialize', tag: 'AuthService', result: 'error');
      rethrow;
    }
  }

  /// Login with identifier (email, username, or phone) and password
  ///
  /// [identifier] Can be email, username, or phone number
  /// [password] User's password
  ///
  /// Returns [AuthResult] indicating success or failure with error message
  Future<AuthResult> login(String identifier, String password) async {
    AppLogger.methodEntry(
      'login',
      tag: 'AuthService',
      params: {'identifier': identifier},
    );
    AppLogger.userAction(
      'User attempting login through service',
      tag: 'AuthService',
      context: {'identifier': identifier},
    );

    try {
      final result = await _loginUseCase(identifier, password);

      if (result.isSuccess) {
        AppLogger.info('Login successful through service', tag: 'AuthService');
        AppLogger.userAction(
          'User login successful through service',
          tag: 'AuthService',
        );
      } else {
        AppLogger.warning(
          'Login failed through service: ${result.errorMessage}',
          tag: 'AuthService',
        );
      }

      AppLogger.methodExit(
        'login',
        tag: 'AuthService',
        result: result.isSuccess ? 'success' : 'failure',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Unexpected error in login service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'login',
        tag: 'AuthService',
        result: 'unexpected_error',
      );
      return const AuthResult.failure(
        error: 'An unexpected error occurred during login',
      );
    }
  }

  /// Register a new user
  ///
  /// [name] User's full name
  /// [email] User's email address
  /// [password] User's password
  /// [confirmPassword] Password confirmation
  /// [username] Optional username
  /// [phone] Optional phone number
  ///
  /// Returns [AuthResult] indicating success or failure with error message
  Future<AuthResult> register(
    String name,
    String email,
    String password,
    String confirmPassword, {
    String? username,
    String? phone,
  }) async {
    AppLogger.methodEntry(
      'register',
      tag: 'AuthService',
      params: {
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
      },
    );
    AppLogger.userAction(
      'User attempting registration through service',
      tag: 'AuthService',
      context: {'email': email, 'name': name},
    );

    try {
      final result = await _registerUseCase(
        name,
        email,
        password,
        confirmPassword,
        username: username,
        phone: phone,
      );

      if (result.isSuccess) {
        AppLogger.info(
          'Registration successful through service',
          tag: 'AuthService',
        );
        AppLogger.userAction(
          'User registration successful through service',
          tag: 'AuthService',
        );
      } else {
        AppLogger.warning(
          'Registration failed through service: ${result.errorMessage}',
          tag: 'AuthService',
        );
      }

      AppLogger.methodExit(
        'register',
        tag: 'AuthService',
        result: result.isSuccess ? 'success' : 'failure',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Unexpected error in registration service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'register',
        tag: 'AuthService',
        result: 'unexpected_error',
      );
      return const AuthResult.failure(
        error: 'An unexpected error occurred during registration',
      );
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    AppLogger.methodEntry('logout', tag: 'AuthService');
    AppLogger.userAction(
      'User logging out through service',
      tag: 'AuthService',
    );

    try {
      await _logoutUseCase();
      AppLogger.info('Logout successful through service', tag: 'AuthService');
      AppLogger.userAction(
        'User logout successful through service',
        tag: 'AuthService',
      );
      AppLogger.methodExit('logout', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error(
        'Error during logout service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('logout', tag: 'AuthService', result: 'error');
      rethrow;
    }
  }

  /// Get list of available test users
  ///
  /// Returns list of test users for development/demo purposes
  Future<List<User>> getTestUsers() async {
    AppLogger.methodEntry('getTestUsers', tag: 'AuthService');

    try {
      final testUsers = await _getTestUsersUseCase();
      AppLogger.methodExit(
        'getTestUsers',
        tag: 'AuthService',
        result: '${testUsers.length} users',
      );
      return testUsers;
    } catch (e) {
      AppLogger.error(
        'Error getting test users',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit('getTestUsers', tag: 'AuthService', result: 'error');
      return [];
    }
  }

  /// Refresh authentication token
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> refreshToken() async {
    AppLogger.methodEntry('refreshToken', tag: 'AuthService');

    try {
      final result = await _repository.refreshToken();

      if (result.isSuccess) {
        AppLogger.info(
          'Token refresh successful through service',
          tag: 'AuthService',
        );
      } else {
        AppLogger.warning(
          'Token refresh failed through service: ${result.errorMessage}',
          tag: 'AuthService',
        );
      }

      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthService',
        result: result.isSuccess ? 'success' : 'failure',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Unexpected error in token refresh service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthService',
        result: 'unexpected_error',
      );
      return const AuthResult.failure(
        error: 'An unexpected error occurred during token refresh',
      );
    }
  }

  /// Change user password
  ///
  /// [oldPassword] Current password
  /// [newPassword] New password
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    AppLogger.methodEntry('changePassword', tag: 'AuthService');
    AppLogger.userAction(
      'User changing password through service',
      tag: 'AuthService',
    );

    try {
      // Basic validation
      if (oldPassword.trim().isEmpty) {
        return const AuthResult.failure(
          error: 'Please enter your current password',
        );
      }

      if (newPassword.trim().isEmpty) {
        return const AuthResult.failure(error: 'Please enter a new password');
      }

      if (newPassword.length < 8) {
        return const AuthResult.failure(
          error: 'New password must be at least 8 characters long',
        );
      }

      if (oldPassword == newPassword) {
        return const AuthResult.failure(
          error: 'New password must be different from current password',
        );
      }

      final result = await _repository.changePassword(oldPassword, newPassword);

      if (result.isSuccess) {
        AppLogger.info(
          'Password change successful through service',
          tag: 'AuthService',
        );
        AppLogger.userAction(
          'User password change successful through service',
          tag: 'AuthService',
        );
      } else {
        AppLogger.warning(
          'Password change failed through service: ${result.errorMessage}',
          tag: 'AuthService',
        );
      }

      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthService',
        result: result.isSuccess ? 'success' : 'failure',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Unexpected error in password change service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthService',
        result: 'unexpected_error',
      );
      return const AuthResult.failure(
        error: 'An unexpected error occurred during password change',
      );
    }
  }

  /// Request password reset
  ///
  /// [email] Email address to send reset instructions
  ///
  /// Returns [AuthResult] indicating success or failure
  Future<AuthResult> requestPasswordReset(String email) async {
    AppLogger.methodEntry(
      'requestPasswordReset',
      tag: 'AuthService',
      params: {'email': email},
    );
    AppLogger.userAction(
      'User requesting password reset through service',
      tag: 'AuthService',
      context: {'email': email},
    );

    try {
      // Basic validation
      if (email.trim().isEmpty) {
        return const AuthResult.failure(
          error: 'Please enter your email address',
        );
      }

      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email.trim())) {
        return const AuthResult.failure(
          error: 'Please enter a valid email address',
        );
      }

      final result = await _repository.requestPasswordReset(email.trim());

      if (result.isSuccess) {
        AppLogger.info(
          'Password reset request successful through service',
          tag: 'AuthService',
        );
        AppLogger.userAction(
          'User password reset request successful through service',
          tag: 'AuthService',
        );
      } else {
        AppLogger.warning(
          'Password reset request failed through service: ${result.errorMessage}',
          tag: 'AuthService',
        );
      }

      AppLogger.methodExit(
        'requestPasswordReset',
        tag: 'AuthService',
        result: result.isSuccess ? 'success' : 'failure',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Unexpected error in password reset request service',
        tag: 'AuthService',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'requestPasswordReset',
        tag: 'AuthService',
        result: 'unexpected_error',
      );
      return const AuthResult.failure(
        error: 'An unexpected error occurred during password reset request',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    AppLogger.info('Disposing AuthService', tag: 'AuthService');
    _repository.dispose();
  }
}
