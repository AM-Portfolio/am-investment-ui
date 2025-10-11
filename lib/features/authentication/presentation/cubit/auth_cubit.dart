import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/email_login_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/demo_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import 'auth_state.dart';

/// Authentication Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required EmailLoginUseCase emailLoginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required DemoLoginUseCase demoLoginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _emailLoginUseCase = emailLoginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _demoLoginUseCase = demoLoginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(const AuthInitial());
  final EmailLoginUseCase _emailLoginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final DemoLoginUseCase _demoLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  /// Login with email and password
  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthLoading());

    final result = await _emailLoginUseCase(email: email, password: password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResult) => emit(Authenticated(authResult.user)),
    );
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());

    final result = await _googleLoginUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResult) => emit(Authenticated(authResult.user)),
    );
  }

  /// Login with demo account
  Future<void> loginWithDemo() async {
    emit(const AuthLoading());

    final result = await _demoLoginUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResult) => emit(Authenticated(authResult.user)),
    );
  }

  /// Logout
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await _checkAuthStatusUseCase();

    result.fold((failure) => emit(const Unauthenticated()), (isAuthenticated) {
      if (isAuthenticated) {
        // In production, fetch user details
        emit(const Unauthenticated()); // Simplified for now
      } else {
        emit(const Unauthenticated());
      }
    });
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
      emit(const AuthError('Registration feature is not yet fully implemented. Please use existing login credentials.'));
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
      emit(const AuthError('Password reset feature is not yet fully implemented. Please contact support to reset your password.'));
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
      emit(const AuthError('Password reset feature is not yet fully implemented. Please contact support to reset your password.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
