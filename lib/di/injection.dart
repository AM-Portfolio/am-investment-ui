import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../core/services/secure_storage_service.dart';
import '../features/authentication/data/datasources/mock_auth_datasource.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/data/services/mock_data_service.dart';
import '../features/authentication/data/services/google_signin_service.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/email_login_usecase.dart';
import '../features/authentication/domain/usecases/google_login_usecase.dart';
import '../features/authentication/domain/usecases/demo_login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/feature_flag_cubit.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupDependencyInjection() async {
  // Core services
  getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);

  // Dio client
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl =
        'https://api.aminvestment.com'; // Replace with actual API URL
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  // Authentication services
  getIt.registerLazySingleton<MockDataService>(MockDataService.new);
  getIt.registerLazySingleton<GoogleSignInService>(GoogleSignInService.new);

  // Authentication data sources
  getIt.registerLazySingleton<MockAuthDataSource>(
    () => MockAuthDataSource(getIt<MockDataService>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<Dio>()),
  );

  // Authentication repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<MockAuthDataSource>(),
      getIt<AuthRemoteDataSource>(),
      getIt<SecureStorageService>(),
    ),
  );

  // Authentication use cases
  getIt.registerLazySingleton<EmailLoginUseCase>(
    () => EmailLoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GoogleLoginUseCase>(
    () => GoogleLoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<DemoLoginUseCase>(
    () => DemoLoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
  );

  // Cubits - these should be factories so they can be provided per widget tree
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      emailLoginUseCase: getIt<EmailLoginUseCase>(),
      googleLoginUseCase: getIt<GoogleLoginUseCase>(),
      demoLoginUseCase: getIt<DemoLoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
    ),
  );

  getIt.registerFactory<FeatureFlagCubit>(FeatureFlagCubit.new);
}
