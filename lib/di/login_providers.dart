import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/app_logic/domain/entities/user.dart';
import '../core/app_logic/domain/entities/auth_state.dart';
import '../core/app_logic/services/auth_service.dart';

part 'login_providers.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.login(identifier, password);
      
      if (result.isSuccess) {
        // Sync with the auth service state
        _syncWithAuthService(authService);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Login failed',
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
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
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
    } catch (_) {}
    state = const AuthState();
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
