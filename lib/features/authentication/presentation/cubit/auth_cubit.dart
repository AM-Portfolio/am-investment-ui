import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/demo_login_usecase.dart';
import '../../domain/usecases/email_login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

/// Authentication Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required EmailLoginUseCase emailLoginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required DemoLoginUseCase demoLoginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _emailLoginUseCase = emailLoginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _demoLoginUseCase = demoLoginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial());
  final EmailLoginUseCase _emailLoginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final DemoLoginUseCase _demoLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// Login with email and password
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());

    final result = await _emailLoginUseCase(email: email, password: password);

    result.fold((failure) => emit(AuthError(failure.message)), (authResult) => emit(Authenticated(authResult.user)));
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());

    final result = await _googleLoginUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (authResult) => emit(Authenticated(authResult.user)));
  }

  /// Login with demo account
  Future<void> loginWithDemo() async {
    emit(const AuthLoading());

    final result = await _demoLoginUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (authResult) => emit(Authenticated(authResult.user)));
  }

  /// Logout
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase();

    result.fold((failure) => emit(AuthError(failure.message)), (_) => emit(const Unauthenticated()));
  }

  /// Check authentication status and restore session if valid
  Future<void> checkAuthStatus() async {
    AppLogger.methodEntry('checkAuthStatus', tag: 'AuthCubit');
    AppLogger.debug('🔍 Starting authentication status check...', tag: 'AuthCubit');
    emit(const AuthLoading());

    final statusResult = await _checkAuthStatusUseCase();

    await statusResult.fold(
      (failure) async {
        AppLogger.error('❌ Auth status check failed', tag: 'AuthCubit', error: failure);
        AppLogger.debug('🔄 Emitting Unauthenticated state due to check failure', tag: 'AuthCubit');
        emit(const Unauthenticated());
      },
      (isAuthenticated) async {
        AppLogger.info('✅ Auth status result: $isAuthenticated', tag: 'AuthCubit');
        if (isAuthenticated) {
          AppLogger.debug('📦 Fetching user from storage...', tag: 'AuthCubit');
          // Fetch and restore user from storage
          final userResult = await _getCurrentUserUseCase();
          userResult.fold(
            (failure) {
              AppLogger.error('❌ Failed to get current user from storage', tag: 'AuthCubit', error: failure);
              AppLogger.debug('🔄 Emitting Unauthenticated state due to user fetch failure', tag: 'AuthCubit');
              emit(const Unauthenticated());
            },
            (authResult) {
              if (authResult != null) {
                final userId = authResult.user.id;
                final email = authResult.user.email;

                AppLogger.info(
                  '✅ User retrieved from storage - userId: "$userId" (length: ${userId.length}), email: "$email"',
                  tag: 'AuthCubit',
                );

                // CRITICAL: Log if userId is empty before emitting state
                if (userId.isEmpty) {
                  AppLogger.error(
                    '🚨 CRITICAL: Retrieved userId is EMPTY! email: "$email", authMethod: ${authResult.user.authMethod}',
                    tag: 'AuthCubit',
                  );
                  AppLogger.debug('🔄 Emitting Unauthenticated state due to empty userId', tag: 'AuthCubit');
                  emit(const Unauthenticated());
                } else {
                  AppLogger.debug('🔄 Emitting Authenticated state with userId: "$userId"', tag: 'AuthCubit');
                  emit(Authenticated(authResult.user));
                  AppLogger.info('✅ Authentication state emitted successfully', tag: 'AuthCubit');
                }
              } else {
                AppLogger.warning('⚠️ No auth result found in storage (null)', tag: 'AuthCubit');
                AppLogger.debug('🔄 Emitting Unauthenticated state due to null auth result', tag: 'AuthCubit');
                emit(const Unauthenticated());
              }
            },
          );
        } else {
          AppLogger.debug('🔄 Emitting Unauthenticated state (isAuthenticated = false)', tag: 'AuthCubit');
          emit(const Unauthenticated());
        }
      },
    );

    AppLogger.methodExit('checkAuthStatus', tag: 'AuthCubit');
  }

  /// Register new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    emit(const AuthLoading());

    try {
      // TODO: Implement registration with proper use case integration
      // Critical: Do not emit false success - show clear error instead
      emit(
        const AuthError('Registration feature is not yet fully implemented. Please use existing login credentials.'),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());

    try {
      // TODO: Implement forgot password with proper use case integration
      // Critical: Do not emit false success without backend verification
      emit(
        const AuthError(
          'Password reset feature is not yet fully implemented. Please contact support to reset your password.',
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const AuthLoading());

    try {
      // TODO: Implement reset password with proper use case integration
      // Critical: Do not emit false success without backend verification
      emit(
        const AuthError(
          'Password reset feature is not yet fully implemented. Please contact support to reset your password.',
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
