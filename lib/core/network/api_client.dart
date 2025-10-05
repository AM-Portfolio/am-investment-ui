import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/errors/exception.dart';
import '../utils/logger.dart';

/// Base API client for handling HTTP requests
class ApiClient {
  /// Constructor
  ApiClient({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? _defaultBaseUrl,
      _client = client ?? http.Client();

  /// Default base URL for API requests
  static const String _defaultBaseUrl = 'http://localhost:8080';

  /// Base URL for API requests
  final String baseUrl;

  /// HTTP client for making requests
  final http.Client _client;

  /// Token key in shared preferences
  static const String _tokenKey = 'auth_token';

  /// Get authentication token from shared preferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Build URI from endpoint, handling both complete URLs and relative paths
  /// Automatically replaces localhost with 10.0.2.2 for Android emulator compatibility
  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    var finalEndpoint = endpoint;
    var finalBaseUrl = baseUrl;

    AppLogger.debug(
      '🌐 URI Building - Original endpoint: $endpoint, baseUrl: $baseUrl',
      tag: 'ApiClient',
    );

    // Replace localhost with 10.0.2.2 for Android platform (mobile/emulator)
    if (!kIsWeb && Platform.isAndroid) {
      finalEndpoint = _replaceLocalhostForAndroid(finalEndpoint);
      finalBaseUrl = _replaceLocalhostForAndroid(finalBaseUrl);
      AppLogger.debug(
        '🌐 Android detected - Transformed endpoint: $finalEndpoint, baseUrl: $finalBaseUrl',
        tag: 'ApiClient',
      );
    }

    Uri finalUri;
    // Check if endpoint is already a complete URL (contains protocol)
    if (finalEndpoint.startsWith('http://') ||
        finalEndpoint.startsWith('https://')) {
      finalUri = Uri.parse(finalEndpoint).replace(queryParameters: queryParams);
      AppLogger.debug(
        '🌐 Complete URL detected - Final URI: $finalUri',
        tag: 'ApiClient',
      );
    } else {
      // For relative endpoints, combine with base URL
      final cleanEndpoint = finalEndpoint.startsWith('/')
          ? finalEndpoint.substring(1)
          : finalEndpoint;
      final combinedUrl = '$finalBaseUrl/$cleanEndpoint';
      finalUri = Uri.parse(combinedUrl).replace(queryParameters: queryParams);
      AppLogger.debug(
        '🌐 Relative endpoint - Combined URL: $combinedUrl, Final URI: $finalUri',
        tag: 'ApiClient',
      );
    }

    return finalUri;
  }

  /// Replace localhost with 10.0.2.2 for Android emulator compatibility
  String _replaceLocalhostForAndroid(String url) =>
      url.replaceAll('localhost', '10.0.2.2');

  /// Create headers with authentication token
  Future<Map<String, String>> _createHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await _getAuthToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (additionalHeaders != null) ...additionalHeaders,
    };
  }

  /// Handle HTTP response
  T _handleResponse<T>(http.Response response, T Function(dynamic data) parser) {
    AppLogger.debug(
      '📥 Response received - Status: ${response.statusCode}, Body length: ${response.body.length}',
      tag: 'ApiClient',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final dynamic data = jsonDecode(response.body);
        AppLogger.debug(
          '✅ Response parsed successfully - Data type: ${data.runtimeType}',
          tag: 'ApiClient',
        );
        return parser(data);
      } catch (e) {
        AppLogger.error(
          '❌ JSON parsing failed - Response body: ${response.body}',
          tag: 'ApiClient',
          error: e,
        );
        rethrow;
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      } catch (_) {
        throw ApiException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    }
  }

  /// Make GET request
  Future<T> get<T>(
    String endpoint, {
    required T Function(dynamic data) parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    late Uri uri; // Declare uri outside try block for catch block access
    final stopwatch = Stopwatch()..start();
    try {
      uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);

      AppLogger.info(
        '🚀 GET Request - Full endpoint: ${uri.toString()}',
        tag: 'ApiClient',
      );
      AppLogger.apiRequest(
        'GET',
        uri.toString(),
        tag: 'ApiClient',
        headers: requestHeaders,
      );

      final response = await _client.get(uri, headers: requestHeaders);
      stopwatch.stop();

      AppLogger.apiResponse(
        'GET',
        uri.toString(),
        response.statusCode,
        tag: 'ApiClient',
        duration: stopwatch.elapsedMilliseconds,
      );

      return _handleResponse(response, parser);
    } catch (e) {
      stopwatch.stop();
      AppLogger.error(
        'GET request failed - Endpoint: $endpoint, Full URI: ${uri.toString()}',
        tag: 'ApiClient',
        error: e,
        stackTrace: StackTrace.current,
      );

      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Make POST request
  Future<T> post<T>(
    String endpoint, {
    required T Function(dynamic data) parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    body,
  }) async {
    final stopwatch = Stopwatch()..start();
    late Uri uri; // Declare uri outside try block for catch block access
    try {
      uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);

      AppLogger.info(
        '🚀 POST Request - Full endpoint: ${uri.toString()}',
        tag: 'ApiClient',
      );
      AppLogger.apiRequest(
        'POST',
        uri.toString(),
        tag: 'ApiClient',
        headers: requestHeaders,
        body: body,
      );

      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      stopwatch.stop();
      AppLogger.apiResponse(
        'POST',
        uri.toString(),
        response.statusCode,
        tag: 'ApiClient',
        duration: stopwatch.elapsedMilliseconds,
      );

      return _handleResponse(response, parser);
    } catch (e) {
      stopwatch.stop();
      AppLogger.error(
        'POST request failed - Endpoint: $endpoint, Full URI: ${uri.toString()}',
        tag: 'ApiClient',
        error: e,
        stackTrace: StackTrace.current,
      );

      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Make PUT request
  Future<T> put<T>(
    String endpoint, {
    required T Function(dynamic data) parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    body,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);

      final response = await _client.put(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, parser);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Make DELETE request
  Future<T> delete<T>(
    String endpoint, {
    required T Function(dynamic data) parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    body,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);

      final response = await _client.delete(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, parser);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

// ApiException is now imported from api_exception.dart

/// API response wrapper
class ApiResponse<T> {
  /// Constructor for successful response
  ApiResponse.success(this.data) : error = null;

  /// Constructor for error response
  ApiResponse.error(this.error) : data = null;

  /// Response data
  final T? data;

  /// Error message if request failed
  final String? error;

  /// Whether the request was successful
  bool get isSuccess => error == null && data != null;
}
