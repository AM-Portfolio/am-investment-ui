import 'dart:convert';
import 'package:http/http.dart' as http;

/// Remote data source for login operations
class LoginRemoteDataSource {
  final http.Client httpClient;
  final String baseUrl;

  LoginRemoteDataSource({
    required this.httpClient,
    this.baseUrl = 'https://api.investment-app.com',
  });

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  /// Logout user
  Future<void> logout(String token) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Token refresh failed: ${response.body}');
    }
  }

  /// Get current user
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Get user failed: ${response.body}');
    }
  }

  /// Check email availability
  Future<bool> isEmailAvailable(String email) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/auth/check-email?email=${Uri.encodeComponent(email)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['available'] as bool;
    } else {
      throw Exception('Email check failed: ${response.body}');
    }
  }
}