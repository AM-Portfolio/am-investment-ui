import 'package:dio/dio.dart';

import '../../../../config/environment.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_result_model.dart';
import '../models/auth_tokens_model.dart';
import 'auth_data_source.dart';

/// Real API implementation of authentication data source
class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<AuthResultModel> emailLogin(String email, String password) async {
    try {
      final fullUrl =
          '${EnvironmentConfig.apiBaseUrl}${AuthConstants.loginEndpoint}';
      final response = await _dio.post(
        fullUrl,
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Log the response for debugging
        print('Login API Response: ${response.data}');
        return AuthResultModel.fromJson(response.data);
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
        errorMessage = e.response!.data['message'] ?? errorMessage;
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
      final fullUrl =
          '${EnvironmentConfig.apiBaseUrl}${AuthConstants.googleLoginEndpoint}';
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
      final fullUrl =
          '${EnvironmentConfig.apiBaseUrl}${AuthConstants.logoutEndpoint}';
      await _dio.post(fullUrl);
    } on DioException catch (e) {
      // Log but don't throw - logout should always succeed locally
      print('Logout API call failed: ${e.message}');
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final fullUrl =
          '${EnvironmentConfig.apiBaseUrl}${AuthConstants.refreshTokenEndpoint}';
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
  Future<bool> isAuthenticated() async {
    // Check with backend
    try {
      final response = await _dio.get('/api/auth/status');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
