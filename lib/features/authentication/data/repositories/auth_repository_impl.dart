import 'package:dartz/dartz.dart';

import '../../../../core/config/feature_flags.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/mock_auth_datasource.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._mockDataSource, this._remoteDataSource, this._storageService);
  final MockAuthDataSource _mockDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;
  final FeatureFlags _featureFlags = FeatureFlags();

  /// Get the appropriate data source based on feature flags
  AuthDataSource get _dataSource => _featureFlags.useRealBackendAPI ? _remoteDataSource : _mockDataSource;

  @override
  Future<Either<Failure, AuthResultEntity>> emailLogin({required String email, required String password}) async {
    try {
      final result = await _dataSource.emailLogin(email, password);

      // Save tokens to secure storage
      await _storageService.saveAccessToken(result.tokens.accessToken);
      await _storageService.saveRefreshToken(result.tokens.refreshToken);
      await _storageService.saveUserId(result.user.id);
      await _storageService.saveUserEmail(result.user.email);
      await _storageService.saveTokenExpiry(result.tokens.expiresAt);

      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode.toString()));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResultEntity>> googleLogin() async {
    try {
      final result = await _dataSource.googleLogin();

      // Save tokens to secure storage
      await _storageService.saveAccessToken(result.tokens.accessToken);
      await _storageService.saveRefreshToken(result.tokens.refreshToken);
      await _storageService.saveUserId(result.user.id);
      await _storageService.saveUserEmail(result.user.email);
      await _storageService.saveTokenExpiry(result.tokens.expiresAt);

      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode.toString()));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResultEntity>> demoLogin() async {
    try {
      final result = await _dataSource.demoLogin();

      // Save tokens to secure storage
      await _storageService.saveAccessToken(result.tokens.accessToken);
      await _storageService.saveRefreshToken(result.tokens.refreshToken);
      await _storageService.saveUserId(result.user.id);
      await _storageService.saveUserEmail(result.user.email);
      await _storageService.saveTokenExpiry(result.tokens.expiresAt);

      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.logout();
      await _storageService.clearAuthData();
      return const Right(null);
    } catch (e) {
      // Even if API call fails, clear local data
      await _storageService.clearAuthData();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> refreshToken(String refreshToken) async {
    try {
      final result = await _dataSource.refreshToken(refreshToken);

      // Save new tokens
      await _storageService.saveAccessToken(result.accessToken);
      await _storageService.saveRefreshToken(result.refreshToken);
      await _storageService.saveTokenExpiry(result.expiresAt);

      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.statusCode.toString()));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) return const Right(false);

      final isExpired = await _storageService.isTokenExpired();
      if (isExpired) {
        // Try to refresh token
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken == null) return const Right(false);

        final result = await this.refreshToken(refreshToken);
        return result.fold((failure) => const Right(false), (tokens) => const Right(true));
      }

      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResultEntity?>> getCurrentUser() async {
    try {
      AppLogger.debug('📦 Retrieving stored credentials...', tag: 'AuthRepository');

      final userId = await _storageService.getUserId();
      final email = await _storageService.getUserEmail();
      final accessToken = await _storageService.getAccessToken();
      final refreshToken = await _storageService.getRefreshToken();
      final expiry = await _storageService.getTokenExpiry();

      AppLogger.debug(
        '🔍 Retrieved from storage - userId: "${userId ?? 'NULL'}" (length: ${userId?.length ?? 0}), email: "${email ?? 'NULL'}"',
        tag: 'AuthRepository',
      );

      // CRITICAL: Validate all required fields including non-empty strings
      if (userId == null ||
          userId.isEmpty ||
          email == null ||
          email.isEmpty ||
          accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          expiry == null) {
        AppLogger.warning(
          '⚠️ Validation failed - userId: ${userId == null
              ? 'NULL'
              : userId.isEmpty
              ? 'EMPTY'
              : 'OK'}, '
          'email: ${email == null
              ? 'NULL'
              : email.isEmpty
              ? 'EMPTY'
              : 'OK'}, '
          'accessToken: ${accessToken == null
              ? 'NULL'
              : accessToken.isEmpty
              ? 'EMPTY'
              : 'OK'}',
          tag: 'AuthRepository',
        );

        return const Right(null);
      }

      AppLogger.info('✅ All stored credentials validated successfully', tag: 'AuthRepository');

      // Reconstruct user and auth result from stored data
      final userEntity = UserEntity(
        id: userId,
        email: email,
        authMethod: 'stored', // Could be tracked separately if needed
      );

      final tokensEntity = AuthTokensEntity(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiry);

      final authResult = AuthResultEntity(user: userEntity, tokens: tokensEntity);

      AppLogger.debug('✅ Returning AuthResultEntity with userId: "$userId"', tag: 'AuthRepository');

      return Right(authResult);
    } catch (e) {
      AppLogger.error('❌ Error in getCurrentUser', tag: 'AuthRepository', error: e);
      return Left(UnknownFailure(e.toString()));
    }
  }
}
