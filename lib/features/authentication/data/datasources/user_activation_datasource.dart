import 'package:dio/dio.dart';

import '../../../../config/config_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Data source for user activation operations
abstract class UserActivationDataSource {
  /// Activate a user by changing their status to 'active'
  Future<Map<String, dynamic>> activateUser(String userId);

  /// Get the current status of a user
  Future<Map<String, dynamic>> getUserStatus(String userId);
}

/// Remote implementation of user activation data source
class UserActivationRemoteDataSource implements UserActivationDataSource {
  UserActivationRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<Map<String, dynamic>> activateUser(String userId) async {
    try {
      final userConfig = ConfigService.config.api.user;
      if (userConfig == null) {
        throw ServerException('User API not configured', statusCode: 500);
      }

      final fullUrl = ApiEndpoints.userStatus(userId);

      final response = await _dio.patch(
        fullUrl,
        data: {'status': 'active'},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data as Map<String, dynamic>? ?? {'success': true};
      } else {
        throw ServerException(
          'Failed to activate user',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }

      var errorMessage = 'Failed to activate user';
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
  Future<Map<String, dynamic>> getUserStatus(String userId) async {
    try {
      final userConfig = ConfigService.config.api.user;
      if (userConfig == null) {
        throw ServerException('User API not configured', statusCode: 500);
      }

      final fullUrl = ApiEndpoints.userStatus(userId);

      final response = await _dio.get(fullUrl);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Failed to get user status',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(AuthConstants.networkError);
      }

      var errorMessage = 'Failed to get user status';
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
}
