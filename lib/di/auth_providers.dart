import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/auth_interceptor.dart';
import 'package:am_common_ui/core/services/secure_storage_service.dart';  // Migrated to am_common_ui
import 'package:am_common_ui/features/authentication/data/datasources/auth_remote_datasource.dart';  // Migrated
import 'package:am_common_ui/features/authentication/data/datasources/mock_auth_datasource.dart';  // Migrated
import 'package:am_common_ui/features/authentication/data/repositories/auth_repository_impl.dart';  // Migrated
import 'package:am_common_ui/features/authentication/data/services/google_signin_service.dart';  // Migrated
import 'package:am_common_ui/features/authentication/data/services/mock_data_service.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/repositories/auth_repository.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/check_auth_status_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/demo_login_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/email_login_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/get_current_user_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/google_login_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/logout_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/domain/usecases/register_usecase.dart';  // Migrated
import 'package:am_common_ui/features/authentication/presentation/cubit/auth_cubit.dart';  // Migrated
import '../features/authentication/presentation/cubit/feature_flag_cubit.dart'; // Local override
import 'package:am_common_ui/core/theme/cubit/theme_cubit.dart';
import 'package:am_common_ui/core/theme/theme_repository.dart';

class AuthProviders {
  static SecureStorageService? _secureStorageService;
  static MockDataService? _mockDataService;
  static Dio? _dio;
  static MockAuthDataSource? _mockAuthDataSource;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthRepository? _authRepository;
  static ThemeRepository? _themeRepository;


  static SecureStorageService get secureStorageService {
    _secureStorageService ??= SecureStorageService();
    return _secureStorageService!;
  }

  static MockDataService get mockDataService {
    _mockDataService ??= MockDataService();
    return _mockDataService!;
  }

  static Dio get dio {
    _dio ??= Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio!.interceptors.add(AuthInterceptor(secureStorageService));
    return _dio!;
  }

  static MockAuthDataSource get mockAuthDataSource {
    _mockAuthDataSource ??= MockAuthDataSource(mockDataService);
    return _mockAuthDataSource!;
  }

  static AuthRemoteDataSource get authRemoteDataSource {
    _authRemoteDataSource ??= AuthRemoteDataSource(dio);
    return _authRemoteDataSource!;
  }

  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(
      mockAuthDataSource,
      authRemoteDataSource,
      secureStorageService,
      GoogleSignInService(), // Added GoogleSignInService
    );
    return _authRepository!;
  }

  static ThemeRepository get themeRepository {
    _themeRepository ??= ThemeRepository();
    return _themeRepository!;
  }


  static EmailLoginUseCase get emailLoginUseCase =>
      EmailLoginUseCase(authRepository);

  static GoogleLoginUseCase get googleLoginUseCase =>
      GoogleLoginUseCase(authRepository);

  static DemoLoginUseCase get demoLoginUseCase =>
      DemoLoginUseCase(authRepository);

  static LogoutUseCase get logoutUseCase => LogoutUseCase(authRepository);

  static CheckAuthStatusUseCase get checkAuthStatusUseCase =>
      CheckAuthStatusUseCase(authRepository);

  static GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);

  static RegisterUseCase get registerUseCase => RegisterUseCase(authRepository);

  static AuthCubit createAuthCubit() => AuthCubit(
    emailLoginUseCase: emailLoginUseCase,
    googleLoginUseCase: googleLoginUseCase,
    demoLoginUseCase: demoLoginUseCase,
    logoutUseCase: logoutUseCase,
    checkAuthStatusUseCase: checkAuthStatusUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    registerUseCase: registerUseCase,
  );

  static List<BlocProvider> get providers => [
    BlocProvider<AuthCubit>(
      create: (context) => createAuthCubit()..checkAuthStatus(),
    ),
    BlocProvider<ThemeCubit>(
      create: (context) => ThemeCubit(themeRepository),
    ),
    BlocProvider<FeatureFlagCubit>(
      create: (context) => FeatureFlagCubit(),
    ),
  ];

}
