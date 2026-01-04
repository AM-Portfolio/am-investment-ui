import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/auth_interceptor.dart';
import 'package:am_common_ui/am_common_ui.dart';

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
