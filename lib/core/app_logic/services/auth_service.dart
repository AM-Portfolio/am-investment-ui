import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/asset_constants.dart';
import '../../utils/logger.dart';

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
  final Map<String, TestUser> _testUsers = {};
  bool _testUsersLoaded = false;

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadTestUsers();
  }

  /// Load test users from JSON file
  Future<void> _loadTestUsers() async {
    AppLogger.methodEntry('_loadTestUsers', tag: 'AuthService');
    
    try {
      AppLogger.info('Loading test users from asset file', tag: 'AuthService');
      
      final String jsonString = await rootBundle.loadString(
        AssetPaths.testUsers,
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersList = jsonData['users'];

      AppLogger.debug('Parsing ${usersList.length} test users', tag: 'AuthService');
      
      // Create a map for quick lookup by email, username, and phone
      for (var userData in usersList) {
        final testUser = TestUser.fromJson(userData);
        _testUsers[testUser.email] = testUser;
        _testUsers[testUser.username] = testUser;
        _testUsers[testUser.phone] = testUser;
      }

      _testUsersLoaded = true;
      AppLogger.info('Successfully loaded ${usersList.length} test users', tag: 'AuthService');
      AppLogger.methodExit('_loadTestUsers', tag: 'AuthService', result: 'success');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load test users from ${AssetPaths.testUsers}', 
          tag: 'AuthService', error: e, stackTrace: stackTrace);
      AppLogger.methodExit('_loadTestUsers', tag: 'AuthService', result: 'error');
    
      // Throw meaningful error with context
      if (e.toString().contains('Unable to load asset')) {
        final errorMsg = 'Failed to load test users: Asset file ${AssetPaths.testUsers} not found. Ensure the file exists and is properly listed in pubspec.yaml assets section.';
        AppLogger.error(errorMsg, tag: 'AuthService');
        throw Exception(errorMsg);
      } else if (e.toString().contains('FormatException')) {
        final errorMsg = 'Failed to load test users: Invalid JSON format in ${AssetPaths.testUsers}. Please check the file syntax.';
        AppLogger.error(errorMsg, tag: 'AuthService');
        throw Exception(errorMsg);
      } else {
        final errorMsg = 'Failed to load test users from ${AssetPaths.testUsers}: ${e.toString()}';
        AppLogger.error(errorMsg, tag: 'AuthService');
        throw Exception(errorMsg);
      }
    }
  }

  /// Initialize the auth service and restore session if available
  Future<void> initialize() async {
    AppLogger.methodEntry('initialize', tag: 'AuthService');
    
    try {
      AppLogger.info('Initializing AuthService', tag: 'AuthService');
      
      // Ensure test users are loaded
      if (!_testUsersLoaded) {
        AppLogger.debug('Test users not loaded, loading now', tag: 'AuthService');
        await _loadTestUsers();
      }

      AppLogger.debug('Checking for existing session', tag: 'AuthService');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null) {
        AppLogger.info('Found existing session, restoring user', tag: 'AuthService');
        final user = User.fromJson(jsonDecode(userData));
        _currentState = AuthState.authenticated(user, token);
        _authStateController.add(_currentState);
        AppLogger.info('Session restored successfully for user: ${user.email}', tag: 'AuthService');
      } else {
        AppLogger.debug('No existing session found', tag: 'AuthService');
      }
      
      AppLogger.methodExit('initialize', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error('Error initializing auth service', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      // Clear any potentially corrupted data
      await _clearAuthData();
      AppLogger.methodExit('initialize', tag: 'AuthService', result: 'error');
    }
  }

  /// Login with identifier (email, username, or phone) and password
  Future<AuthResult> login(String identifier, String password) async {
    AppLogger.methodEntry('login', tag: 'AuthService', params: {'identifier': identifier});
    AppLogger.userAction('User attempting login', tag: 'AuthService', 
        context: {'identifier': identifier, 'identifierType': _getIdentifierType(identifier)});
    
    try {
      AppLogger.info('Starting login process', tag: 'AuthService');
      _currentState = AuthState.loading();
      _authStateController.add(_currentState);
      AppLogger.stateChange('unauthenticated', 'loading', tag: 'AuthService');

      // Simulate network delay in debug mode
      if (kDebugMode) {
        AppLogger.debug('Debug mode: Adding network delay', tag: 'AuthService');
        await Future.delayed(const Duration(seconds: 1));
      }

      // Ensure test users are loaded
      if (!_testUsersLoaded) {
        AppLogger.debug('Test users not loaded, loading now', tag: 'AuthService');
        await _loadTestUsers();
      }

      // Check for test users first
      if (_testUsers.containsKey(identifier)) {
        AppLogger.info('Found test user for identifier', tag: 'AuthService');
        final testUser = _testUsers[identifier]!;
        if (testUser.password == password) {
          AppLogger.info('Test user authentication successful for user: ${testUser.email} (ID: ${testUser.id})', tag: 'AuthService');
          
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
          AppLogger.stateChange('loading', 'authenticated', tag: 'AuthService');
          AppLogger.userAction('User login successful', tag: 'AuthService', 
              context: {'userId': user.id, 'userEmail': user.email});
          AppLogger.methodExit('login', tag: 'AuthService', result: 'success');

          return AuthResult.success();
        } else {
          AppLogger.warning('Invalid password for test user', tag: 'AuthService');
          _currentState = AuthState.error('Invalid password');
          _authStateController.add(_currentState);
          AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'invalid_password');
          AppLogger.methodExit('login', tag: 'AuthService', result: 'failure');
          return AuthResult.failure('Invalid password');
        }
      }

      // Always use demo mode in debug builds to avoid network errors
      if (kDebugMode) {
        AppLogger.debug('Debug mode: Attempting demo authentication', tag: 'AuthService');
        // If not a test user but contains 'test', also allow login
        if (identifier.contains('test')) {
          AppLogger.info('Debug mode: Creating demo user for test identifier', tag: 'AuthService');
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
          AppLogger.stateChange('loading', 'authenticated', tag: 'AuthService', event: 'demo_mode');
          AppLogger.userAction('Demo user login successful', tag: 'AuthService');
          AppLogger.methodExit('login', tag: 'AuthService', result: 'success');

          return AuthResult.success();
        }

        AppLogger.warning('Debug mode: Invalid credentials for non-test identifier', tag: 'AuthService');
        _currentState = AuthState.error('Invalid credentials');
        _authStateController.add(_currentState);
        AppLogger.stateChange('loading', 'error', tag: 'AuthService');
        AppLogger.methodExit('login', tag: 'AuthService', result: 'failure');
        return AuthResult.failure('Invalid credentials');
      }

      // In production, make actual API call
      AppLogger.info('Production mode: Making API call for authentication', tag: 'AuthService');
      try {
        // Determine login type (email, username, or phone)
        final Map<String, String> requestBody = {'password': password};
        String identifierType;

        if (identifier.contains('@')) {
          requestBody['email'] = identifier;
          identifierType = 'email';
        } else if (identifier.startsWith('+')) {
          requestBody['phone'] = identifier;
          identifierType = 'phone';
        } else {
          requestBody['username'] = identifier;
          identifierType = 'username';
        }
        
        AppLogger.debug('API request prepared for $identifierType to $_baseUrl/auth/login', tag: 'AuthService');

        AppLogger.apiRequest('POST', '$_baseUrl/auth/login', tag: 'AuthService');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        AppLogger.apiResponse('POST', '$_baseUrl/auth/login', response.statusCode, tag: 'AuthService');

        if (response.statusCode == 200) {
          AppLogger.info('API authentication successful', tag: 'AuthService');
          final data = jsonDecode(response.body);
          final user = User.fromJson(data['user']);
          final token = data['token'];

          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          AppLogger.stateChange('loading', 'authenticated', tag: 'AuthService', event: 'api_success');
          AppLogger.userAction('API user login successful', tag: 'AuthService', 
              context: {'userId': user.id, 'userEmail': user.email});
          AppLogger.methodExit('login', tag: 'AuthService', result: 'success');

          return AuthResult.success();
        } else {
          final error = _parseErrorResponse(response);
          AppLogger.warning('API authentication failed: $error (Status: ${response.statusCode})', tag: 'AuthService');
          _currentState = AuthState.error(error);
          _authStateController.add(_currentState);
          AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'api_failure');
          AppLogger.methodExit('login', tag: 'AuthService', result: 'failure');

          return AuthResult.failure(error);
        }
      } catch (e) {
        final error = 'Network error: Unable to connect to server';
        AppLogger.error('Network error during login API call', tag: 'AuthService', 
            error: e, stackTrace: StackTrace.current);
        _currentState = AuthState.error(error);
        _authStateController.add(_currentState);
        AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'network_error');
        AppLogger.methodExit('login', tag: 'AuthService', result: 'network_error');

        return AuthResult.failure(error);
      }
    } catch (e) {
      final error = 'Login failed: ${e.toString()}';
      AppLogger.error('Unexpected error during login', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      _currentState = AuthState.error(error);
      _authStateController.add(_currentState);
      AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'unexpected_error');
      AppLogger.methodExit('login', tag: 'AuthService', result: 'unexpected_error');

      return AuthResult.failure(error);
    }
  }
  
  /// Helper method to determine identifier type for logging
  String _getIdentifierType(String identifier) {
    if (identifier.contains('@')) return 'email';
    if (identifier.startsWith('+')) return 'phone';
    return 'username';
  }

  /// Register a new user
  Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? username,
    String? phone,
  }) async {
    AppLogger.methodEntry('register', tag: 'AuthService', 
        params: {'name': name, 'email': email, 'username': username, 'phone': phone});
    AppLogger.userAction('User attempting registration', tag: 'AuthService', 
        context: {'email': email, 'name': name});
    
    try {
      AppLogger.info('Starting registration process', tag: 'AuthService');
      _currentState = AuthState.loading();
      _authStateController.add(_currentState);
      AppLogger.stateChange('unauthenticated', 'loading', tag: 'AuthService');

      // Simulate network delay in debug mode
      if (kDebugMode) {
        AppLogger.debug('Debug mode: Adding network delay', tag: 'AuthService');
        await Future.delayed(const Duration(seconds: 1));
      }

      // Always use demo mode in debug builds to avoid network errors
      if (kDebugMode) {
        AppLogger.info('Debug mode: Creating demo user for registration', tag: 'AuthService');
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
        AppLogger.stateChange('loading', 'authenticated', tag: 'AuthService', event: 'demo_registration');
        AppLogger.userAction('Demo user registration successful', tag: 'AuthService', 
            context: {'userId': user.id, 'userEmail': user.email});
        AppLogger.methodExit('register', tag: 'AuthService', result: 'success');

        return AuthResult.success();
      }

      // In production, make actual API call
      AppLogger.info('Production mode: Making API call for registration', tag: 'AuthService');
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

        AppLogger.apiRequest('POST', '$_baseUrl/auth/register', tag: 'AuthService');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        
        AppLogger.apiResponse('POST', '$_baseUrl/auth/register', response.statusCode, tag: 'AuthService');

        if (response.statusCode == 201) {
          AppLogger.info('API registration successful', tag: 'AuthService');
          final data = jsonDecode(response.body);
          final user = User.fromJson(data['user']);
          final token = data['token'];

          await _saveAuthData(user, token);
          _currentState = AuthState.authenticated(user, token);
          _authStateController.add(_currentState);
          AppLogger.stateChange('loading', 'authenticated', tag: 'AuthService', event: 'api_registration');
          AppLogger.userAction('API user registration successful', tag: 'AuthService', 
              context: {'userId': user.id, 'userEmail': user.email});
          AppLogger.methodExit('register', tag: 'AuthService', result: 'success');

          return AuthResult.success();
        } else {
          final error = _parseErrorResponse(response);
          AppLogger.warning('API registration failed: $error (Status: ${response.statusCode})', tag: 'AuthService');
          _currentState = AuthState.error(error);
          _authStateController.add(_currentState);
          AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'api_registration_failure');
          AppLogger.methodExit('register', tag: 'AuthService', result: 'failure');

          return AuthResult.failure(error);
        }
      } catch (e) {
        final error = 'Network error: Unable to connect to server';
        AppLogger.error('Network error during registration API call', tag: 'AuthService', 
            error: e, stackTrace: StackTrace.current);
        _currentState = AuthState.error(error);
        _authStateController.add(_currentState);
        AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'network_error');
        AppLogger.methodExit('register', tag: 'AuthService', result: 'network_error');

        return AuthResult.failure(error);
      }
    } catch (e) {
      final error = 'Registration failed: ${e.toString()}';
      AppLogger.error('Unexpected error during registration', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      _currentState = AuthState.error(error);
      _authStateController.add(_currentState);
      AppLogger.stateChange('loading', 'error', tag: 'AuthService', event: 'unexpected_error');
      AppLogger.methodExit('register', tag: 'AuthService', result: 'unexpected_error');

      return AuthResult.failure(error);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    AppLogger.methodEntry('logout', tag: 'AuthService');
    AppLogger.userAction('User logging out', tag: 'AuthService');
    
    try {
      AppLogger.info('Clearing authentication data', tag: 'AuthService');
      await _clearAuthData();
      _currentState = AuthState.unauthenticated();
      _authStateController.add(_currentState);
      AppLogger.stateChange('authenticated', 'unauthenticated', tag: 'AuthService');
      AppLogger.info('User logout successful', tag: 'AuthService');
      AppLogger.methodExit('logout', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error('Error during logout', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      // Still clear local state even if API call fails
      await _clearAuthData();
      _currentState = AuthState.unauthenticated();
      _authStateController.add(_currentState);
      AppLogger.stateChange('authenticated', 'unauthenticated', tag: 'AuthService', event: 'force_logout');
      AppLogger.methodExit('logout', tag: 'AuthService', result: 'error_but_cleared');
    }
  }

  /// Save authentication data to persistent storage
  Future<void> _saveAuthData(User user, String token) async {
    AppLogger.methodEntry('_saveAuthData', tag: 'AuthService', 
        params: {'userId': user.id, 'userEmail': user.email});
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      AppLogger.debug('Authentication data saved to persistent storage', tag: 'AuthService');
      AppLogger.methodExit('_saveAuthData', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error('Failed to save authentication data', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('_saveAuthData', tag: 'AuthService', result: 'error');
      rethrow;
    }
  }

  /// Clear authentication data from persistent storage
  Future<void> _clearAuthData() async {
    AppLogger.methodEntry('_clearAuthData', tag: 'AuthService');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      AppLogger.debug('Authentication data cleared from persistent storage', tag: 'AuthService');
      AppLogger.methodExit('_clearAuthData', tag: 'AuthService', result: 'success');
    } catch (e) {
      AppLogger.error('Failed to clear authentication data', tag: 'AuthService', 
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('_clearAuthData', tag: 'AuthService', result: 'error');
      rethrow;
    }
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

  AuthState._({required this.status, this.user, this.token, this.error});

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
    return AuthState._(status: AuthStatus.error, error: error);
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Authentication status
enum AuthStatus { unauthenticated, authenticated, loading, error }

/// Result of authentication operations
class AuthResult {
  final bool success;
  final String? error;

  AuthResult._({required this.success, this.error});

  factory AuthResult.success() {
    return AuthResult._(success: true);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}
