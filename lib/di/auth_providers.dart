import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/secure_storage_service.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/datasources/mock_auth_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/data/services/mock_data_service.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/demo_login_usecase.dart';
import '../features/authentication/domain/usecases/email_login_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/google_login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';

class AuthProviders {
  static SecureStorageService? _secureStorageService;
  static MockDataService? _mockDataService;
  static Dio? _dio;
  static MockAuthDataSource? _mockAuthDataSource;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static AuthRepository? _authRepository;

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
    );
    return _authRepository!;
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

  static AuthCubit createAuthCubit() => AuthCubit(
        emailLoginUseCase: emailLoginUseCase,
        googleLoginUseCase: googleLoginUseCase,
        demoLoginUseCase: demoLoginUseCase,
        logoutUseCase: logoutUseCase,
        checkAuthStatusUseCase: checkAuthStatusUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      );

  static List<BlocProvider> get providers => [
        BlocProvider<AuthCubit>(
          create: (context) => createAuthCubit()..checkAuthStatus(),
        ),
      ];
}
