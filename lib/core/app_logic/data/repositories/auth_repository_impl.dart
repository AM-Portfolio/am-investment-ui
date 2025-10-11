import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../config/config_service.dart';
import '../../../utils/logger.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/auth_storage_data_source.dart';

/// Implementation of AuthRepository that combines multiple data sources
///
/// Uses local data source for development/demo and remote data source for production
/// Also handles persistent storage of authentication state
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthDataSource localDataSource,
    required AuthDataSource remoteDataSource,
    required AuthStorageDataSource storageDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _storageDataSource = storageDataSource;
  final AuthDataSource _localDataSource;
  final AuthDataSource _remoteDataSource;
  final AuthStorageDataSource _storageDataSource;

  // Stream controller for auth state changes
  final _authStateController = StreamController<AuthState>.broadcast();

  // Current auth state
  AuthState _currentState = const AuthState();

  @override
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  @override
  AuthState get currentState => _currentState;

  @override
  Future<void> initialize() async {
    AppLogger.methodEntry('initialize', tag: 'AuthRepositoryImpl');

    try {
      AppLogger.info('Initializing AuthRepository', tag: 'AuthRepositoryImpl');

      // Try to restore session from storage
      AppLogger.debug(
        'Checking for existing session in storage',
        tag: 'AuthRepositoryImpl',
      );
      final storedAuthState = await _storageDataSource.loadAuthData();

      if (storedAuthState != null && storedAuthState.isAuthenticated) {
        // Check if token is expired
        if (storedAuthState.isTokenExpired) {
          AppLogger.info(
            'Stored token is expired, attempting refresh',
            tag: 'AuthRepositoryImpl',
          );

          try {
            // Try to refresh token
            final result = await refreshToken();
            if (!result.isSuccess) {
              AppLogger.warning(
                'Token refresh failed, clearing stored session',
                tag: 'AuthRepositoryImpl',
              );
              await _storageDataSource.clearAuthData();
              _updateAuthState(const AuthState());
            }
          } catch (e) {
            AppLogger.warning(
              'Token refresh error, clearing stored session',
              tag: 'AuthRepositoryImpl',
            );
            await _storageDataSource.clearAuthData();
            _updateAuthState(const AuthState());
          }
        } else {
          // Token is still valid, restore session
          AppLogger.info(
            'Restored valid session for user: ${storedAuthState.currentUser?.email}',
            tag: 'AuthRepositoryImpl',
          );
          _updateAuthState(storedAuthState);

          // If token needs refresh soon, do it proactively
          if (storedAuthState.needsTokenRefresh) {
            AppLogger.debug(
              'Token needs refresh soon, refreshing proactively',
              tag: 'AuthRepositoryImpl',
            );
            refreshToken().catchError((e) {
              AppLogger.warning(
                'Proactive token refresh failed',
                tag: 'AuthRepositoryImpl',
                error: e,
              );
              return const AuthResult.failure(error: 'Token refresh failed');
            });
          }
        }
      } else {
        AppLogger.debug(
          'No valid session found in storage',
          tag: 'AuthRepositoryImpl',
        );
        _updateAuthState(const AuthState());
      }

      AppLogger.methodExit(
        'initialize',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
    } catch (e) {
      AppLogger.error(
        'Error initializing auth repository',
        tag: 'AuthRepositoryImpl',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Clear any potentially corrupted data and start fresh
      await _storageDataSource.clearAuthData();
      _updateAuthState(const AuthState());

      AppLogger.methodExit(
        'initialize',
        tag: 'AuthRepositoryImpl',
        result: 'error_cleared',
      );
    }
  }

  @override
  Future<AuthResult> login(String identifier, String password) async {
    AppLogger.methodEntry(
      'login',
      tag: 'AuthRepositoryImpl',
      params: {'identifier': identifier},
    );
    AppLogger.userAction(
      'User attempting login',
      tag: 'AuthRepositoryImpl',
      context: {'identifier': identifier},
    );

    try {
      _updateAuthState(_currentState.copyWith(isLoading: true));
      AppLogger.stateChange('idle', 'loading', tag: 'AuthRepositoryImpl');

      AuthDataResponse response;

      // Check configuration to decide whether to use mock data or real API
      final useMockData = ConfigService.config.api.useMockData;

      if (useMockData &&
          (kDebugMode ||
              identifier.contains('test') ||
              identifier.contains('demo'))) {
        AppLogger.debug(
          'Using local data source for authentication (mock mode enabled)',
          tag: 'AuthRepositoryImpl',
        );

        try {
          response = await _localDataSource.login(identifier, password);
          AppLogger.info(
            'Local authentication successful',
            tag: 'AuthRepositoryImpl',
          );
        } catch (e) {
          // If local auth fails and we're in strict debug mode, don't try remote
          if (kDebugMode && identifier.contains('test')) {
            AppLogger.warning(
              'Local authentication failed in debug mode',
              tag: 'AuthRepositoryImpl',
            );
            _updateAuthState(
              _currentState.copyWith(
                isLoading: false,
                errorMessage: e.toString(),
              ),
            );
            AppLogger.stateChange(
              'loading',
              'error',
              tag: 'AuthRepositoryImpl',
            );
            AppLogger.methodExit(
              'login',
              tag: 'AuthRepositoryImpl',
              result: 'failure',
            );
            return AuthResult.failure(error: e.toString());
          }

          // Fall back to remote API
          AppLogger.debug(
            'Local authentication failed, trying remote API',
            tag: 'AuthRepositoryImpl',
          );
          response = await _remoteDataSource.login(identifier, password);
          AppLogger.info(
            'Remote authentication successful',
            tag: 'AuthRepositoryImpl',
          );
        }
      } else {
        // Use real API - either mock is disabled or production mode
        AppLogger.debug(
          'Using remote API for authentication',
          tag: 'AuthRepositoryImpl',
        );
        response = await _remoteDataSource.login(identifier, password);
        AppLogger.info(
          'Remote authentication successful',
          tag: 'AuthRepositoryImpl',
        );
      }

      // Save authentication data to storage
      await _storageDataSource.saveAuthData(
        user: response.user,
        token: response.token,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      // Update auth state
      final newAuthState = AuthState(
        isAuthenticated: true,
        currentUser: response.user,
        accessToken: response.token,
        refreshToken: response.refreshToken,
        tokenExpiresAt: response.expiresAt,
      );

      _updateAuthState(newAuthState);
      AppLogger.stateChange(
        'loading',
        'authenticated',
        tag: 'AuthRepositoryImpl',
      );
      AppLogger.userAction(
        'User login successful',
        tag: 'AuthRepositoryImpl',
        context: {'userId': response.user.id, 'userEmail': response.user.email},
      );
      AppLogger.methodExit(
        'login',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );

      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error('Login failed', tag: 'AuthRepositoryImpl', error: e);

      _updateAuthState(
        _currentState.copyWith(isLoading: false, errorMessage: errorMessage),
      );
      AppLogger.stateChange('loading', 'error', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'login',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );

      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  }) async {
    AppLogger.methodEntry(
      'register',
      tag: 'AuthRepositoryImpl',
      params: {
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
      },
    );
    AppLogger.userAction(
      'User attempting registration',
      tag: 'AuthRepositoryImpl',
      context: {'email': email, 'name': name},
    );

    try {
      _updateAuthState(_currentState.copyWith(isLoading: true));
      AppLogger.stateChange('idle', 'loading', tag: 'AuthRepositoryImpl');

      AuthDataResponse response;

      // In debug mode, use local data source
      if (kDebugMode) {
        AppLogger.debug(
          'Using local data source for registration',
          tag: 'AuthRepositoryImpl',
        );
        response = await _localDataSource.register(
          name,
          email,
          password,
          username: username,
          phone: phone,
        );
        AppLogger.info(
          'Local registration successful',
          tag: 'AuthRepositoryImpl',
        );
      } else {
        // Production mode - use remote data source
        AppLogger.debug(
          'Using remote data source for registration',
          tag: 'AuthRepositoryImpl',
        );
        response = await _remoteDataSource.register(
          name,
          email,
          password,
          username: username,
          phone: phone,
        );
        AppLogger.info(
          'Remote registration successful',
          tag: 'AuthRepositoryImpl',
        );
      }

      // Save authentication data to storage
      await _storageDataSource.saveAuthData(
        user: response.user,
        token: response.token,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      // Update auth state
      final newAuthState = AuthState(
        isAuthenticated: true,
        currentUser: response.user,
        accessToken: response.token,
        refreshToken: response.refreshToken,
        tokenExpiresAt: response.expiresAt,
      );

      _updateAuthState(newAuthState);
      AppLogger.stateChange(
        'loading',
        'authenticated',
        tag: 'AuthRepositoryImpl',
      );
      AppLogger.userAction(
        'User registration successful',
        tag: 'AuthRepositoryImpl',
        context: {'userId': response.user.id, 'userEmail': response.user.email},
      );
      AppLogger.methodExit(
        'register',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );

      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error(
        'Registration failed',
        tag: 'AuthRepositoryImpl',
        error: e,
      );

      _updateAuthState(
        _currentState.copyWith(isLoading: false, errorMessage: errorMessage),
      );
      AppLogger.stateChange('loading', 'error', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'register',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );

      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<void> logout() async {
    AppLogger.methodEntry('logout', tag: 'AuthRepositoryImpl');
    AppLogger.userAction('User logging out', tag: 'AuthRepositoryImpl');

    try {
      AppLogger.info('Clearing authentication data', tag: 'AuthRepositoryImpl');
      await _storageDataSource.clearAuthData();

      _updateAuthState(const AuthState());
      AppLogger.stateChange(
        'authenticated',
        'unauthenticated',
        tag: 'AuthRepositoryImpl',
      );
      AppLogger.info('User logout successful', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'logout',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
    } catch (e) {
      AppLogger.error(
        'Error during logout',
        tag: 'AuthRepositoryImpl',
        error: e,
      );

      // Still clear local state even if storage operations fail
      _updateAuthState(const AuthState());
      AppLogger.stateChange(
        'authenticated',
        'unauthenticated',
        tag: 'AuthRepositoryImpl',
        event: 'force_logout',
      );
      AppLogger.methodExit(
        'logout',
        tag: 'AuthRepositoryImpl',
        result: 'error_but_cleared',
      );
    }
  }

  @override
  Future<List<User>> getTestUsers() async {
    AppLogger.methodEntry('getTestUsers', tag: 'AuthRepositoryImpl');

    try {
      final testUsers = await _localDataSource.getTestUsers();
      AppLogger.methodExit(
        'getTestUsers',
        tag: 'AuthRepositoryImpl',
        result: '${testUsers.length} users',
      );
      return testUsers;
    } catch (e) {
      AppLogger.error(
        'Failed to get test users',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'getTestUsers',
        tag: 'AuthRepositoryImpl',
        result: 'error',
      );
      return [];
    }
  }

  @override
  Future<bool> isIdentifierTaken(String identifier, String type) async {
    AppLogger.methodEntry(
      'isIdentifierTaken',
      tag: 'AuthRepositoryImpl',
      params: {'identifier': identifier, 'type': type},
    );

    try {
      // In debug mode, check local data source
      if (kDebugMode) {
        final taken = await _localDataSource.isIdentifierTaken(
          identifier,
          type,
        );
        AppLogger.methodExit(
          'isIdentifierTaken',
          tag: 'AuthRepositoryImpl',
          result: taken ? 'taken' : 'available',
        );
        return taken;
      } else {
        // Production mode - check remote data source
        final taken = await _remoteDataSource.isIdentifierTaken(
          identifier,
          type,
        );
        AppLogger.methodExit(
          'isIdentifierTaken',
          tag: 'AuthRepositoryImpl',
          result: taken ? 'taken' : 'available',
        );
        return taken;
      }
    } catch (e) {
      AppLogger.error(
        'Failed to check identifier availability',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'isIdentifierTaken',
        tag: 'AuthRepositoryImpl',
        result: 'error',
      );
      // On error, assume not taken to allow user to proceed
      return false;
    }
  }

  @override
  Future<AuthResult> refreshToken() async {
    AppLogger.methodEntry('refreshToken', tag: 'AuthRepositoryImpl');

    if (_currentState.accessToken == null) {
      AppLogger.warning('No token to refresh', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthRepositoryImpl',
        result: 'no_token',
      );
      return const AuthResult.failure(error: 'No token to refresh');
    }

    try {
      final dataSource = kDebugMode ? _localDataSource : _remoteDataSource;
      final newToken = await dataSource.refreshToken(
        _currentState.accessToken!,
      );

      // Update storage with new token
      await _storageDataSource.updateTokenData(
        token: newToken,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Update auth state
      _updateAuthState(
        _currentState.copyWith(
          accessToken: newToken,
          tokenExpiresAt: DateTime.now().add(const Duration(hours: 24)),
        ),
      );

      AppLogger.info('Token refresh successful', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error(
        'Token refresh failed',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    AppLogger.methodEntry('changePassword', tag: 'AuthRepositoryImpl');

    if (_currentState.accessToken == null) {
      AppLogger.warning(
        'No token for password change',
        tag: 'AuthRepositoryImpl',
      );
      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthRepositoryImpl',
        result: 'no_token',
      );
      return const AuthResult.failure(error: 'Not authenticated');
    }

    try {
      final dataSource = kDebugMode ? _localDataSource : _remoteDataSource;
      await dataSource.changePassword(
        _currentState.accessToken!,
        oldPassword,
        newPassword,
      );

      AppLogger.info('Password change successful', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error(
        'Password change failed',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> requestPasswordReset(String email) async {
    AppLogger.methodEntry(
      'requestPasswordReset',
      tag: 'AuthRepositoryImpl',
      params: {'email': email},
    );

    try {
      final dataSource = kDebugMode ? _localDataSource : _remoteDataSource;
      await dataSource.requestPasswordReset(email);

      AppLogger.info(
        'Password reset request successful',
        tag: 'AuthRepositoryImpl',
      );
      AppLogger.methodExit(
        'requestPasswordReset',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error(
        'Password reset request failed',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'requestPasswordReset',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    AppLogger.methodEntry(
      'resetPassword',
      tag: 'AuthRepositoryImpl',
      params: {'resetToken': resetToken},
    );

    try {
      final dataSource = kDebugMode ? _localDataSource : _remoteDataSource;
      await dataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );

      AppLogger.info('Password reset successful', tag: 'AuthRepositoryImpl');
      AppLogger.methodExit(
        'resetPassword',
        tag: 'AuthRepositoryImpl',
        result: 'success',
      );
      return const AuthResult.success();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error(
        'Password reset failed',
        tag: 'AuthRepositoryImpl',
        error: e,
      );
      AppLogger.methodExit(
        'resetPassword',
        tag: 'AuthRepositoryImpl',
        result: 'failure',
      );
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  void dispose() {
    AppLogger.info('Disposing AuthRepository', tag: 'AuthRepositoryImpl');
    _authStateController.close();
  }

  /// Update auth state and notify listeners
  void _updateAuthState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }
}
