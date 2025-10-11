import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../../utils/logger.dart';
import '../mappers/auth_mapper.dart';
import 'auth_data_source.dart';

/// Remote data source for authentication operations
///
/// Handles API calls for authentication operations in production
class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource({required this.baseUrl, required this.httpClient});
  final String baseUrl;
  final http.Client httpClient;

  @override
  Future<AuthDataResponse> login(String identifier, String password) async {
    AppLogger.methodEntry(
      'login',
      tag: 'AuthRemoteDataSource',
      params: {'identifier': identifier},
    );

    try {
      // Use mapper to create login request
      final requestBody = AuthMapper.loginRequestToJson(identifier, password);
      final identifierType = identifier.contains('@')
          ? 'email'
          : identifier.startsWith('+')
          ? 'phone'
          : 'username';

      AppLogger.debug(
        'API request prepared for $identifierType to $baseUrl/auth/login',
        tag: 'AuthRemoteDataSource',
      );
      AppLogger.apiRequest(
        'POST',
        '$baseUrl/auth/login',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      AppLogger.apiResponse(
        'POST',
        '$baseUrl/auth/login',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Use mapper to convert JSON to AuthDataResponse
        final authResponse = AuthMapper.fromJson(data);

        AppLogger.info(
          'API authentication successful',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'login',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );

        return authResponse;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'API authentication failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'login',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during login API call',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'login',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<AuthDataResponse> register(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  }) async {
    AppLogger.methodEntry(
      'register',
      tag: 'AuthRemoteDataSource',
      params: {
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
      },
    );

    try {
      // Use mapper to create register request
      final requestBody = AuthMapper.registerRequestToJson(
        name,
        email,
        password,
        username: username,
        phone: phone,
      );

      AppLogger.apiRequest(
        'POST',
        '$baseUrl/auth/register',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      AppLogger.apiResponse(
        'POST',
        '$baseUrl/auth/register',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Use mapper to convert JSON to AuthDataResponse
        final authResponse = AuthMapper.fromJson(data);

        AppLogger.info(
          'API registration successful',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'register',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );

        return authResponse;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'API registration failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'register',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during registration API call',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'register',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<String> refreshToken(String token) async {
    AppLogger.methodEntry('refreshToken', tag: 'AuthRemoteDataSource');

    try {
      AppLogger.apiRequest(
        'POST',
        '$baseUrl/auth/refresh',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.apiResponse(
        'POST',
        '$baseUrl/auth/refresh',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;

        AppLogger.info('Token refresh successful', tag: 'AuthRemoteDataSource');
        AppLogger.methodExit(
          'refreshToken',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );

        return newToken;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'Token refresh failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'refreshToken',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during token refresh',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'refreshToken',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<bool> isIdentifierTaken(String identifier, String type) async {
    AppLogger.methodEntry(
      'isIdentifierTaken',
      tag: 'AuthRemoteDataSource',
      params: {'identifier': identifier, 'type': type},
    );

    try {
      AppLogger.apiRequest(
        'GET',
        '$baseUrl/auth/check-identifier',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.get(
        Uri.parse('$baseUrl/auth/check-identifier?$type=$identifier'),
        headers: {'Content-Type': 'application/json'},
      );

      AppLogger.apiResponse(
        'GET',
        '$baseUrl/auth/check-identifier',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exists = data['exists'] as bool;

        AppLogger.methodExit(
          'isIdentifierTaken',
          tag: 'AuthRemoteDataSource',
          result: exists ? 'taken' : 'available',
        );
        return exists;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'Identifier check failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'isIdentifierTaken',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during identifier check',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'isIdentifierTaken',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    AppLogger.methodEntry('changePassword', tag: 'AuthRemoteDataSource');

    try {
      // Use mapper to create change password request
      final requestBody = AuthMapper.changePasswordRequestToJson(
        oldPassword,
        newPassword,
      );

      AppLogger.apiRequest(
        'PUT',
        '$baseUrl/auth/change-password',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      AppLogger.apiResponse(
        'PUT',
        '$baseUrl/auth/change-password',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Password change successful',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'changePassword',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );
        return true;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'Password change failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'changePassword',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during password change',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'changePassword',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    AppLogger.methodEntry(
      'requestPasswordReset',
      tag: 'AuthRemoteDataSource',
      params: {'email': email},
    );

    try {
      // Use mapper to create password reset request
      final requestBody = AuthMapper.passwordResetRequestToJson(email);

      AppLogger.apiRequest(
        'POST',
        '$baseUrl/auth/password-reset',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      AppLogger.apiResponse(
        'POST',
        '$baseUrl/auth/password-reset',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Password reset request successful',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'requestPasswordReset',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );
        return true;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'Password reset request failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'requestPasswordReset',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during password reset request',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'requestPasswordReset',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    AppLogger.methodEntry(
      'resetPassword',
      tag: 'AuthRemoteDataSource',
      params: {'resetToken': resetToken},
    );

    try {
      final requestBody = {
        'resetToken': resetToken,
        'newPassword': newPassword,
      };

      AppLogger.apiRequest(
        'POST',
        '$baseUrl/auth/password-reset/confirm',
        tag: 'AuthRemoteDataSource',
      );

      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/password-reset/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      AppLogger.apiResponse(
        'POST',
        '$baseUrl/auth/password-reset/confirm',
        response.statusCode,
        tag: 'AuthRemoteDataSource',
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Password reset successful',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'resetPassword',
          tag: 'AuthRemoteDataSource',
          result: 'success',
        );
        return true;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = AuthMapper.parseApiError(errorData);
        AppLogger.warning(
          'Password reset failed: $error (Status: ${response.statusCode})',
          tag: 'AuthRemoteDataSource',
        );
        AppLogger.methodExit(
          'resetPassword',
          tag: 'AuthRemoteDataSource',
          result: 'api_error',
        );
        throw Exception(error);
      }
    } catch (e) {
      if (e is Exception) rethrow;

      AppLogger.error(
        'Network error during password reset',
        tag: 'AuthRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.methodExit(
        'resetPassword',
        tag: 'AuthRemoteDataSource',
        result: 'network_error',
      );
      throw Exception('Network error: Unable to connect to server');
    }
  }

  @override
  Future<List<User>> getTestUsers() async {
    AppLogger.methodEntry('getTestUsers', tag: 'AuthRemoteDataSource');

    // Remote data source doesn't provide test users
    AppLogger.info(
      'Remote data source does not provide test users',
      tag: 'AuthRemoteDataSource',
    );
    AppLogger.methodExit(
      'getTestUsers',
      tag: 'AuthRemoteDataSource',
      result: 'empty',
    );

    return [];
  }
}
