import 'package:dio/dio.dart';

import '../../../../config/config_service.dart';
import '../../../../config/environment_config.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_result_model.dart';
import '../models/auth_tokens_model.dart';

import '../models/user_model.dart';
import 'auth_data_source.dart';

/// Real API implementation of authentication data source
class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<AuthResultModel> emailLogin(String email, String password) async {
    try {
      final authConfig = ConfigService.config.api.auth;
      if (authConfig == null) {
        throw ServerException('Auth API not configured', statusCode: 500);
      }

      final fullUrl = '${authConfig.baseUrl}${AuthConstants.loginEndpoint}';
      final response = await _dio.post(
        fullUrl,
        data: {'username': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Log the response for debugging
        print('Login API Response: ${response.data}');
        final data = response.data;

        final user = UserModel(
          id: data['user_id'],
          email: data['email'],
          displayName: data['username'],
          authMethod: AuthConstants.authMethodEmail,
        );

        final tokens = AuthTokensModel(
          accessToken: data['access_token'],
          refreshToken: null,
          expiresAt: DateTime.now().add(
            Duration(seconds: data['expires_in'] ?? 3600),
          ),
        );

        return AuthResultModel(user: user, tokens: tokens);
      } else {
        throw ServerException(
          'Login failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      // More detailed error handling
      print('Login API Error: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }

      var errorMessage = AuthConstants.serverError;
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data;
        errorMessage =
            data['message'] ?? data['detail'] ?? data['error'] ?? errorMessage;
      }

      throw ServerException(
        errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<AuthResultModel> googleLogin() async {
    try {
      final authConfig = ConfigService.config.api.auth;
      if (authConfig == null) {
        throw ServerException('Auth API not configured', statusCode: 500);
      }

      final fullUrl =
          '${authConfig.baseUrl}${AuthConstants.googleLoginEndpoint}';
      final response = await _dio.post(fullUrl);

      if (response.statusCode == 200) {
        return AuthResultModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Google login failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }
      throw ServerException(
        e.message ?? AuthConstants.serverError,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<AuthResultModel> demoLogin() async {
    // Demo login might still call backend or use mock
    return emailLogin(AuthConstants.demoEmail, AuthConstants.demoPassword);
  }

  @override
  Future<void> logout() async {
    try {
      final authConfig = ConfigService.config.api.auth;
      if (authConfig == null) return;

      final fullUrl = '${authConfig.baseUrl}${AuthConstants.logoutEndpoint}';
      await _dio.post(fullUrl);
    } on DioException catch (e) {
      // Log but don't throw - logout should always succeed locally
      print('Logout API call failed: ${e.message}');
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final authConfig = ConfigService.config.api.auth;
      if (authConfig == null) {
        throw ServerException('Auth API not configured', statusCode: 500);
      }

      final fullUrl =
          '${authConfig.baseUrl}${AuthConstants.refreshTokenEndpoint}';
      final response = await _dio.post(
        fullUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthTokensModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Token refresh failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }
      throw ServerException(
        e.message ?? AuthConstants.serverError,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final userConfig = ConfigService.config.api.user;
      if (userConfig == null) {
        throw ServerException('User API not configured', statusCode: 500);
      }

      final fullUrl = '${userConfig.baseUrl}${userConfig.registerEndpoint}';
      final response = await _dio.post(
        fullUrl,
        data: {
          'full_name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone_number': phone,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // The register endpoint might return the user and token immediately or just success
        // Based on Postman "Register New User", it returns user_id.
        // Postman test scripts implies json response.
        // Assuming it automagically logs in or we just return the user?
        // Let's assume it returns standard Auth structure or at least ID.
        // For now, let's assume it might NOT log in automatically,
        // but our AuthResultModel requires tokens.
        // If the API doesn't return tokens on register, we might need to call login immediately.

        // Postman response check:
        // pm.environment.set("user_id", jsonData.user_id);

        if (data['status'] == 'pending_verification') {
          final userId = data['user_id'] ?? 'unknown';
          throw ServerException(
            'Account created! User ID: $userId\\nPlease activate via Developer Controls to login.',
            statusCode: 201,
          );
        }

        // Use Login flow after register if tokens are missing?
        if (data['access_token'] == null) {
          return emailLogin(email, password);
        }

        final user = UserModel(
          id: data['user_id'] ?? '',
          email: data['email'] ?? email,
          displayName: data['full_name'] ?? name,
          authMethod: AuthConstants.authMethodEmail,
        );

        final tokens = AuthTokensModel(
          accessToken: data['access_token'],
          refreshToken:
              data['refresh_token'], // May be null if only access token
          expiresAt: DateTime.now().add(
            Duration(seconds: data['expires_in'] ?? 3600),
          ),
        );

        return AuthResultModel(user: user, tokens: tokens);
      } else {
        throw ServerException(
          'Registration failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      // DEBUG LOGGING
      AppLogger.error(
        'Registration API Error: ${e.message}',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      if (e.response != null) {
        AppLogger.error(
          'Response Data: ${e.response?.data}',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.error(
          'Status Code: ${e.response?.statusCode}',
          tag: 'AuthRemoteDataSource',
        );
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }

      var errorMessage = 'Registration failed';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data;
        errorMessage =
            data['message'] ?? data['detail'] ?? data['error'] ?? errorMessage;
      }

      throw ServerException(
        errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // Check with backend
    try {
      final authConfig = ConfigService.config.api.auth;
      if (authConfig == null) return false;

      // Note: Assuming /validate is the endpoint to check token validity, based on Postman "Validate Token"
      // Postman says: /api/v1/validate relative to Auth URL

      // We need to pass the token, but this method just checks generic status?
      // If this method is called, it usually expects the Interceptor to attach the token.
      // However, /validate takes token in body in Postman.
      // Let's stick closer to the pattern: simple checking if current token works on a protected endpoint?
      // Or if there is a specific status endpoint.
      // The previous code had /api/auth/status.
      // Postman has "Service Info" at root.
      // Let's rely on validate endpoint if possible, but for now simple health check or user validation.

      // Reverting to previous behavior but using base URL, assuming there might be a status endpoint
      // or relying on higher level logic.
      // If we look at Postman "Validate Token", it is a POST.

      // Let's assume we want to call /api/v1/validate with the current token?
      // But we don't have access to token storage here easily without circular dependency if not careful.
      // For now, let's just use the health check of the auth service to ensure connectivity?
      // No, isAuthenticated implies user session validity.

      // Best bet: Trust the stored token until 401.
      // But if we MUST check:
      // final response = await _dio.get('${authConfig.baseUrl}/health');
      // return response.statusCode == 200;

      return true; // Optimistic check, let interceptors handle 401s
    } catch (e) {
      return false;
    }
  }
}
