import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

import '../internal/domain/entities/user.dart';
import '../internal/domain/entities/auth_state.dart';
import '../internal/domain/repositories/login_repository.dart';
import '../internal/domain/usecases/login_user.dart';
import '../internal/domain/usecases/logout_user.dart';
import '../internal/domain/usecases/register_user.dart';
import '../internal/domain/usecases/validate_credentials.dart';
import '../internal/data/repositories/login_repository_impl.dart';
import '../internal/data/datasources/login_remote_data_source.dart';
import '../internal/services/login_service.dart';
import '../../../di/app_providers.dart';

part 'login_providers.g.dart';

/// Login feature providers
/// These providers are specific to the login feature and follow clean architecture.
/// They manage the login feature's internal dependencies and use cases.

/// Data layer providers
@riverpod
LoginRemoteDataSource loginRemoteDataSource(LoginRemoteDataSourceRef ref) {
  final httpClient = http.Client();
  return LoginRemoteDataSource(httpClient: httpClient);
}

@riverpod
LoginRepository loginRepository(LoginRepositoryRef ref) {
  final remoteDataSource = ref.watch(loginRemoteDataSourceProvider);
  return LoginRepositoryImpl(remoteDataSource: remoteDataSource);
}

/// Use case providers
@riverpod
LoginUser loginUser(LoginUserRef ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginUser(repository);
}

@riverpod
LogoutUser logoutUser(LogoutUserRef ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LogoutUser(repository);
}

@riverpod
RegisterUser registerUser(RegisterUserRef ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return RegisterUser(repository);
}

@riverpod
ValidateCredentials validateCredentials(ValidateCredentialsRef ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return ValidateCredentials(repository);
}

/// Service layer providers
@riverpod
LoginService loginService(LoginServiceRef ref) {
  final loginUser = ref.watch(loginUserProvider);
  final logoutUser = ref.watch(logoutUserProvider);
  final registerUser = ref.watch(registerUserProvider);
  final validateCredentials = ref.watch(validateCredentialsProvider);
  
  return LoginService(
    loginUser,
    logoutUser,
    registerUser,
    validateCredentials,
  );
}

/// State providers - Auto-dispose (can be recreated when needed)
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState();

  /// Login user
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final loginService = ref.read(loginServiceProvider);
      final authState = await loginService.loginWithValidation(email, password);
      state = authState;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final loginService = ref.read(loginServiceProvider);
      await loginService.secureLogout();
      state = const AuthState();
    } catch (error) {
      // Force logout even if server call fails
      state = const AuthState();
    }
  }

  /// Register user
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    bool autoLogin = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final loginService = ref.read(loginServiceProvider);
      await loginService.registerWithValidation(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        autoLogin: autoLogin,
      );
      
      if (autoLogin) {
        // Login state will be updated by login flow
        await login(email, password);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// Validate current session
  Future<void> validateSession() async {
    try {
      final loginService = ref.read(loginServiceProvider);
      final isValid = await loginService.validateAndRefreshSession();
      
      if (!isValid) {
        state = const AuthState();
      }
    } catch (error) {
      state = const AuthState();
    }
  }
}

/// Current user provider
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.currentUser;
}

/// Authentication status provider
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.isLoggedIn;
}