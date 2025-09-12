import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base API client for handling HTTP requests
class ApiClient {
  /// Base URL for API requests
  final String baseUrl;
  
  /// HTTP client for making requests
  final http.Client _client;
  
  /// Token key in shared preferences
  static const String _tokenKey = 'auth_token';
  
  /// Constructor
  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  /// Get authentication token from shared preferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
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
  T _handleResponse<T>(http.Response response, T Function(dynamic data) parser) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic data = jsonDecode(response.body);
      return parser(data);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Unknown error',
          code: response.statusCode,
        );
      } catch (_) {
        throw ApiException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          code: response.statusCode,
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
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final requestHeaders = await _createHeaders(
        additionalHeaders: headers,
      );
      
      final response = await _client.get(uri, headers: requestHeaders);
      return _handleResponse(response, parser);
    } catch (e) {
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
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final requestHeaders = await _createHeaders(
        additionalHeaders: headers,
      );
      
      final response = await _client.post(
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
  
  /// Make PUT request
  Future<T> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final requestHeaders = await _createHeaders(
        additionalHeaders: headers,
      );
      
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
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final requestHeaders = await _createHeaders(
        additionalHeaders: headers,
      );
      
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

/// Exception thrown when API requests fail
class ApiException implements Exception {
  /// Error message
  final String message;
  
  /// HTTP status code
  final int? code;
  
  /// Constructor
  ApiException(this.message, {this.code});
  
  @override
  String toString() => 'ApiException: $message (code: $code)';
}

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
