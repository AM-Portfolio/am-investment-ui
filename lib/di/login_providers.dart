import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/app_logic/domain/entities/auth_state.dart';
import '../core/app_logic/domain/entities/user.dart';
import '../core/app_logic/services/auth_service.dart';
import '../core/app_logic/services/google_signin_service.dart';
import '../core/utils/logger.dart';

part 'login_providers.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

@riverpod
GoogleSignInService googleSignInService(GoogleSignInServiceRef ref) =>
    GoogleSignInService();

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String identifier, String password) async {
    AppLogger.info(
      'Login attempt started for identifier: $identifier',
      tag: 'AuthStateNotifier',
    );
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.login(identifier, password);

      if (result.isSuccess) {
        AppLogger.info(
          'Login successful - syncing with auth service',
          tag: 'AuthStateNotifier',
        );
        // Sync with the auth service state
        _syncWithAuthService(authService);
        AppLogger.info(
          'User authentication completed successfully - UserId: ${state.currentUser?.id}, Email: ${state.currentUser?.email}',
          tag: 'AuthStateNotifier',
        );
      } else {
        AppLogger.warning(
          'Login failed: ${result.errorMessage}',
          tag: 'AuthStateNotifier',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Login failed',
        );
      }
    } catch (error) {
      AppLogger.error(
        'Login process failed with exception',
        tag: 'AuthStateNotifier',
        error: error,
      );
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void _syncWithAuthService(AuthService authService) {
    final serviceState = authService.currentState;

    // The AuthService.currentState already returns the domain AuthState
    // so we can just sync the data directly
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: serviceState.isAuthenticated,
      currentUser: serviceState.currentUser,
      accessToken: serviceState.accessToken,
      refreshToken: serviceState.refreshToken,
      tokenExpiresAt: serviceState.tokenExpiresAt,
      errorMessage: serviceState.errorMessage,
    );
  }

  Future<void> logout() async {
    AppLogger.info(
      'Logout initiated for user: ${state.currentUser?.email}',
      tag: 'AuthStateNotifier',
    );

    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      AppLogger.info(
        'Auth service logout completed successfully',
        tag: 'AuthStateNotifier',
      );
    } catch (error) {
      AppLogger.warning(
        'Auth service logout failed',
        tag: 'AuthStateNotifier',
        error: error,
      );
    }

    state = const AuthState();
    AppLogger.info(
      'User session cleared - logout complete',
      tag: 'AuthStateNotifier',
    );
  }

  Future<void> validateSession() async {
    state = state.copyWith(isLoading: true);

    try {
      AppLogger.info(
        'Validating existing session...',
        tag: 'AuthStateNotifier',
      );
      final authService = ref.read(authServiceProvider);
      await authService.initialize();
      _syncWithAuthService(authService);

      if (state.isAuthenticated) {
        AppLogger.info(
          'Session restored successfully for user: ${state.currentUser?.email}',
          tag: 'AuthStateNotifier',
        );
      } else {
        AppLogger.debug('No existing session found', tag: 'AuthStateNotifier');
      }
    } catch (error) {
      AppLogger.error(
        'Session validation failed',
        tag: 'AuthStateNotifier',
        error: error,
      );
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> loginWithGoogle({String? webClientId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final googleService = ref.read(googleSignInServiceProvider);

      await googleService.initialize(webClientId: webClientId);

      final user = await googleService.signIn();

      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google Sign-In cancelled',
        );
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.currentUser;
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.isLoggedIn;
}
