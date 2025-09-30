import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/errors/exception.dart';
import '../utils/logger.dart';

/// Base API client for handling HTTP requests
class ApiClient {
  /// Default base URL for API requests
  static const String _defaultBaseUrl = 'http://localhost:8080';

  /// Base URL for API requests
  final String baseUrl;

  /// HTTP client for making requests
  final http.Client _client;

  /// Token key in shared preferences
  static const String _tokenKey = 'auth_token';

  /// Constructor
  ApiClient({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? _defaultBaseUrl,
      _client = client ?? http.Client();

  /// Get authentication token from shared preferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Build URI from endpoint, handling both complete URLs and relative paths
  /// Automatically replaces localhost with 10.0.2.2 for Android emulator compatibility
  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    String finalEndpoint = endpoint;
    String finalBaseUrl = baseUrl;
    
    // Replace localhost with 10.0.2.2 for Android platform (mobile/emulator)
    if (!kIsWeb && Platform.isAndroid) {
      finalEndpoint = _replaceLocalhostForAndroid(finalEndpoint);
      finalBaseUrl = _replaceLocalhostForAndroid(finalBaseUrl);
    }
    
    // Check if endpoint is already a complete URL (contains protocol)
    if (finalEndpoint.startsWith('http://') || finalEndpoint.startsWith('https://')) {
      return Uri.parse(finalEndpoint).replace(queryParameters: queryParams);
    }
    
    // For relative endpoints, combine with base URL
    final cleanEndpoint = finalEndpoint.startsWith('/') ? finalEndpoint.substring(1) : finalEndpoint;
    return Uri.parse('$finalBaseUrl/$cleanEndpoint').replace(queryParameters: queryParams);
  }
  
  /// Replace localhost with 10.0.2.2 for Android emulator compatibility
  String _replaceLocalhostForAndroid(String url) {
    return url.replaceAll('localhost', '10.0.2.2');
  }

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
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic data) parser,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic data = jsonDecode(response.body);
      return parser(data);
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
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic data) parser,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);
      
      AppLogger.apiRequest('GET', uri.toString(), tag: 'ApiClient', headers: requestHeaders);

      final response = await _client.get(uri, headers: requestHeaders);
      stopwatch.stop();
      
      AppLogger.apiResponse('GET', uri.toString(), response.statusCode, 
          tag: 'ApiClient', duration: stopwatch.elapsedMilliseconds);
      
      return _handleResponse(response, parser);
    } catch (e) {
      stopwatch.stop();
      AppLogger.error('GET request failed: $endpoint', 
          tag: 'ApiClient', error: e, stackTrace: StackTrace.current);
      
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Make POST request
  Future<T> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    required T Function(dynamic data) parser,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);

      final requestHeaders = await _createHeaders(additionalHeaders: headers);
      
      AppLogger.apiRequest('POST', uri.toString(), tag: 'ApiClient', 
          headers: requestHeaders, body: body);

      final response = await _client.post(
        uri,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      
      stopwatch.stop();
      AppLogger.apiResponse('POST', uri.toString(), response.statusCode, 
          tag: 'ApiClient', duration: stopwatch.elapsedMilliseconds);

      return _handleResponse(response, parser);
    } catch (e) {
      stopwatch.stop();
      AppLogger.error('POST request failed: $endpoint', 
          tag: 'ApiClient', error: e, stackTrace: StackTrace.current);
      
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Make PUT request
  Future<T> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    required T Function(dynamic data) parser,
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
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    required T Function(dynamic data) parser,
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
  /// Response data
  final T? data;

  /// Error message if request failed
  final String? error;

  /// Whether the request was successful
  bool get isSuccess => error == null && data != null;

  /// Constructor for successful response
  ApiResponse.success(this.data) : error = null;

  /// Constructor for error response
  ApiResponse.error(this.error) : data = null;
}
