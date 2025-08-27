import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for handling user login, registration, and session management.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Base API URL - would come from environment config in a real app
  final String _baseUrl = 'https://api.example.com';
  
  // Stream controller for auth state changes
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateChanges => _authStateController.stream;
  
  // Current auth state
  AuthState _currentState = AuthState.unauthenticated();
  AuthState get currentState => _currentState;
  
  // Test users loaded from JSON
  Map<String, TestUser> _testUsers = {};
  bool _testUsersLoaded = false;
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadTestUsers();
  }
  
  /// Load test users from JSON file
  Future<void> _loadTestUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/test_users.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersList = jsonData['users'];
      
      // Create a map for quick lookup by email, username, and phone
      for (var userData in usersList) {
        final testUser = TestUser.fromJson(userData);
        _testUsers[testUser.email] = testUser;
        _testUsers[testUser.username] = testUser;
        _testUsers[testUser.phone] = testUser;
      }
      
      _testUsersLoaded = true;
      debugPrint('Loaded ${usersList.length} test users');
    } catch (e) {
      debugPrint('Error loading test users: $e');
      // Fallback to hardcoded test user if JSON loading fails
      _addFallbackTestUser();
    }
  }
  
  /// Add a fallback test user if JSON loading fails
  void _addFallbackTestUser() {
    final testUser = TestUser(
      id: '123',
      email: 'demo@example.com',
      username: 'demouser',
      phone: '+1234567890',
      name: 'Demo User',
      password: 'password123',
    );
    
    _testUsers[testUser.email] = testUser;
    _testUsers[testUser.username] = testUser;
    _testUsers[testUser.phone] = testUser;
    _testUsersLoaded = true;
  }
  
  /// Initialize the auth service and restore session if available
  Future<void> initialize() async {
    try {
      // Ensure test users are loaded
      if (!_testUsersLoaded) {
        await _loadTestUsers();
      }
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      
      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        _currentState = AuthState.authenticated(user, token);
        _authStateController.add(_currentState);
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
      // Clear any potentially corrupted data
      await _clearAuthData();
    }
  }
  
  /// Login with identifier (email, username, or phone) and password
  Future<AuthResult> login(String identifier, String password) async {
    try {
      _currentState = AuthState.loading();
      _authStateController.add(_currentState);
      
      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // Ensure test users are loaded
      if (!_testUsersLoaded) {
        await _loadTestUsers();
      }
      
      // Check for test users first
      if (_testUsers.containsKey(identifier)) {
        final testUser = _testUsers[identifier]!;
        if (testUser.password == password) {
          final user = User(
            id: testUser.id,
            email: testUser.email,
            name: testUser.name,
            username: testUser.username,
            phone: testUser.phone,
          );
          const token = 'demo_token_12345';
          
          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          
          return AuthResult.success();
        } else {
          _currentState = AuthState.error('Invalid password');
          _authStateController.add(_currentState);
          return AuthResult.failure('Invalid password');
        }
      }
      
      // Always use demo mode in debug builds to avoid network errors
      if (kDebugMode) {
        // If not a test user but contains 'test', also allow login
        if (identifier.contains('test')) {
          final user = User(
            id: '999',
            email: identifier.contains('@') ? identifier : 'test@example.com',
            name: 'Test User',
            username: identifier.contains('@') ? null : identifier,
            phone: identifier.startsWith('+') ? identifier : null,
          );
          const token = 'demo_token_12345';
          
          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          
          return AuthResult.success();
        }
        
        _currentState = AuthState.error('Invalid credentials');
        _authStateController.add(_currentState);
        return AuthResult.failure('Invalid credentials');
      }
      
      // In production, make actual API call
      try {
        // Determine login type (email, username, or phone)
        final Map<String, String> requestBody = {'password': password};
        
        if (identifier.contains('@')) {
          requestBody['email'] = identifier;
        } else if (identifier.startsWith('+')) {
          requestBody['phone'] = identifier;
        } else {
          requestBody['username'] = identifier;
        }
        
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final user = User.fromJson(data['user']);
          final token = data['token'];
          
          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          
          return AuthResult.success();
        } else {
          final error = _parseErrorResponse(response);
          _currentState = AuthState.error(error);
          _authStateController.add(_currentState);
          
          return AuthResult.failure(error);
        }
      } catch (e) {
        final error = 'Network error: Unable to connect to server';
        _currentState = AuthState.error(error);
        _authStateController.add(_currentState);
        
        return AuthResult.failure(error);
      }
    } catch (e) {
      final error = 'Login failed: ${e.toString()}';
      _currentState = AuthState.error(error);
      _authStateController.add(_currentState);
      
      return AuthResult.failure(error);
    }
  }
  
  /// Register a new user
  Future<AuthResult> register(String name, String email, String password, {String? username, String? phone}) async {
    try {
      _currentState = AuthState.loading();
      _authStateController.add(_currentState);
      
      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // Always use demo mode in debug builds to avoid network errors
      if (kDebugMode) {
        final user = User(
          id: '456',
          email: email,
          name: name,
          username: username,
          phone: phone,
        );
        const token = 'demo_token_67890';
        
        await _saveAuthData(user, token);
        _currentState = AuthState.authenticated(user, token);
        _authStateController.add(_currentState);
        
        return AuthResult.success();
      }
      
      // In production, make actual API call
      try {
        final requestBody = {
          'name': name,
          'email': email,
          'password': password,
        };
        
        if (username != null) {
          requestBody['username'] = username;
        }
        
        if (phone != null) {
          requestBody['phone'] = phone;
        }
        
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final user = User.fromJson(data['user']);
          final token = data['token'];
          
          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          
          return AuthResult.success();
        } else {
          final error = _parseErrorResponse(response);
          _currentState = AuthState.error(error);
          _authStateController.add(_currentState);
          
          return AuthResult.failure(error);
        }
      } catch (e) {
        final error = 'Network error: Unable to connect to server';
        _currentState = AuthState.error(error);
        _authStateController.add(_currentState);
        
        return AuthResult.failure(error);
      }
    } catch (e) {
      final error = 'Registration failed: ${e.toString()}';
      _currentState = AuthState.error(error);
      _authStateController.add(_currentState);
      
      return AuthResult.failure(error);
    }
  }
  
  /// Logout the current user
  Future<void> logout() async {
    try {
      await _clearAuthData();
      _currentState = AuthState.unauthenticated();
      _authStateController.add(_currentState);
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Still clear local state even if API call fails
      await _clearAuthData();
      _currentState = AuthState.unauthenticated();
      _authStateController.add(_currentState);
    }
  }
  
  /// Save authentication data to persistent storage
  Future<void> _saveAuthData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  /// Clear authentication data from persistent storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  /// Parse error response from API
  String _parseErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Unknown error occurred';
    } catch (_) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }
  
  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Test user data for easy login
class TestUser {
  final String id;
  final String email;
  final String username;
  final String phone;
  final String name;
  final String password;
  
  TestUser({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.name,
    required this.password,
  });
  
  factory TestUser.fromJson(Map<String, dynamic> json) {
    return TestUser(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      name: json['name'],
      password: json['password'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'name': name,
      'password': password,
    };
  }
}

/// Represents a user in the system
class User {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? phone;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.phone,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
      phone: json['phone'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'phone': phone,
    };
  }
}

/// Authentication state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? error;
  
  AuthState._({
    required this.status,
    this.user,
    this.token,
    this.error,
  });
  
  factory AuthState.unauthenticated() {
    return AuthState._(status: AuthStatus.unauthenticated);
  }
  
  factory AuthState.authenticated(User user, String token) {
    return AuthState._(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
    );
  }
  
  factory AuthState.loading() {
    return AuthState._(status: AuthStatus.loading);
  }
  
  factory AuthState.error(String error) {
    return AuthState._(
      status: AuthStatus.error,
      error: error,
    );
  }
  
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Authentication status
enum AuthStatus {
  unauthenticated,
  authenticated,
  loading,
  error,
}

/// Result of authentication operations
class AuthResult {
  final bool success;
  final String? error;
  
  AuthResult._({
    required this.success,
    this.error,
  });
  
  factory AuthResult.success() {
    return AuthResult._(success: true);
  }
  
  factory AuthResult.failure(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}
