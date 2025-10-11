import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../constants/asset_constants.dart';
import '../../../utils/logger.dart';
import '../../domain/entities/user.dart';
import '../mappers/user_mapper.dart';
import 'auth_data_source.dart';

/// Local data source for authentication operations
///
/// Handles test user data and local authentication for development/demo purposes
class AuthLocalDataSource implements AuthDataSource {
  final Map<String, User> _testUsers = {};
  bool _testUsersLoaded = false;

  /// Load test users from JSON asset file
  Future<void> _loadTestUsers() async {
    AppLogger.methodEntry('_loadTestUsers', tag: 'AuthLocalDataSource');

    if (_testUsersLoaded) {
      AppLogger.debug('Test users already loaded', tag: 'AuthLocalDataSource');
      return;
    }

    try {
      AppLogger.info(
        'Loading test users from asset file',
        tag: 'AuthLocalDataSource',
      );

      final jsonString = await rootBundle.loadString(AssetPaths.testUsers);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersList = jsonData['users'];

      AppLogger.debug(
        'Parsing ${usersList.length} test users',
        tag: 'AuthLocalDataSource',
      );

      // Create a map for quick lookup by email, username, and phone
      _testUsers.clear();
      for (final userData in usersList) {
        // Use mapper to convert test user JSON to User entity
        final testUser = UserMapper.fromJson(userData as Map<String, dynamic>);
        _testUsers[testUser.email] = testUser;
        _testUsers[testUser.userName] = testUser;
        _testUsers[testUser.phoneNumber] = testUser;
      }

      _testUsersLoaded = true;
      AppLogger.info(
        'Successfully loaded ${usersList.length} test users',
        tag: 'AuthLocalDataSource',
      );
      AppLogger.methodExit(
        '_loadTestUsers',
        tag: 'AuthLocalDataSource',
        result: 'success',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load test users from ${AssetPaths.testUsers}',
        tag: 'AuthLocalDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.methodExit(
        '_loadTestUsers',
        tag: 'AuthLocalDataSource',
        result: 'error',
      );

      // Throw meaningful error with context
      if (e.toString().contains('Unable to load asset')) {
        throw Exception(
          'Failed to load test users: Asset file ${AssetPaths.testUsers} not found. '
          'Ensure the file exists and is properly listed in pubspec.yaml assets section.',
        );
      } else if (e.toString().contains('FormatException')) {
        throw Exception(
          'Failed to load test users: Invalid JSON format in ${AssetPaths.testUsers}. '
          'Please check the file syntax.',
        );
      } else {
        throw Exception(
          'Failed to load test users from ${AssetPaths.testUsers}: ${e.toString()}',
        );
      }
    }
  }

  @override
  Future<AuthDataResponse> login(String identifier, String password) async {
    AppLogger.methodEntry(
      'login',
      tag: 'AuthLocalDataSource',
      params: {'identifier': identifier},
    );

    await _loadTestUsers();

    // Check for test users
    if (_testUsers.containsKey(identifier)) {
      final testUser = _testUsers[identifier]!;
      if (testUser.password == password) {
        AppLogger.info(
          'Test user authentication successful for user: ${testUser.email}',
          tag: 'AuthLocalDataSource',
        );

        // Create user with password cleared for security
        final userJson = UserMapper.toJson(testUser);
        userJson['password'] = ''; // Don't include password in response
        final user = UserMapper.fromJson(userJson);

        AppLogger.methodExit(
          'login',
          tag: 'AuthLocalDataSource',
          result: 'success',
        );
        return AuthDataResponse(
          user: user,
          token: 'demo_token_${testUser.id}',
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
      } else {
        AppLogger.warning(
          'Invalid password for test user',
          tag: 'AuthLocalDataSource',
        );
        AppLogger.methodExit(
          'login',
          tag: 'AuthLocalDataSource',
          result: 'invalid_password',
        );
        throw Exception('Invalid password');
      }
    }

    // For demo mode, allow test identifiers
    if (identifier.contains('test') || identifier.contains('demo')) {
      AppLogger.info(
        'Demo mode: Creating demo user for test identifier',
        tag: 'AuthLocalDataSource',
      );
      final user = UserMapper.fromJson({
        'id': '999',
        'email': identifier.contains('@') ? identifier : 'test@example.com',
        'name': 'Test User',
        'password': '',
      });

      AppLogger.methodExit(
        'login',
        tag: 'AuthLocalDataSource',
        result: 'demo_success',
      );
      return AuthDataResponse(
        user: user,
        token: 'demo_token_999',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    }

    AppLogger.warning(
      'Invalid credentials for identifier',
      tag: 'AuthLocalDataSource',
    );
    AppLogger.methodExit(
      'login',
      tag: 'AuthLocalDataSource',
      result: 'invalid_credentials',
    );
    throw Exception('Invalid credentials');
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
      tag: 'AuthLocalDataSource',
      params: {
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
      },
    );

    // For demo mode, always allow registration
    AppLogger.info(
      'Demo mode: Creating demo user for registration',
      tag: 'AuthLocalDataSource',
    );
    final user = UserMapper.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'name': name,
      'username': username ?? '',
      'phone': phone ?? '',
      'password': '',
    });

    AppLogger.methodExit(
      'register',
      tag: 'AuthLocalDataSource',
      result: 'success',
    );
    return AuthDataResponse(
      user: user,
      token: 'demo_token_${user.id}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  @override
  Future<String> refreshToken(String token) async {
    AppLogger.methodEntry('refreshToken', tag: 'AuthLocalDataSource');

    // For demo mode, return a new token
    final newToken =
        'demo_token_refreshed_${DateTime.now().millisecondsSinceEpoch}';

    AppLogger.methodExit(
      'refreshToken',
      tag: 'AuthLocalDataSource',
      result: 'success',
    );
    return newToken;
  }

  @override
  Future<bool> isIdentifierTaken(String identifier, String type) async {
    AppLogger.methodEntry(
      'isIdentifierTaken',
      tag: 'AuthLocalDataSource',
      params: {'identifier': identifier, 'type': type},
    );

    await _loadTestUsers();

    // Check if identifier exists in test users
    final exists = _testUsers.containsKey(identifier);

    AppLogger.methodExit(
      'isIdentifierTaken',
      tag: 'AuthLocalDataSource',
      result: exists ? 'taken' : 'available',
    );
    return exists;
  }

  @override
  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    AppLogger.methodEntry('changePassword', tag: 'AuthLocalDataSource');

    // For demo mode, always succeed
    AppLogger.info(
      'Demo mode: Password change simulated',
      tag: 'AuthLocalDataSource',
    );

    AppLogger.methodExit(
      'changePassword',
      tag: 'AuthLocalDataSource',
      result: 'success',
    );
    return true;
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    AppLogger.methodEntry(
      'requestPasswordReset',
      tag: 'AuthLocalDataSource',
      params: {'email': email},
    );

    // For demo mode, always succeed
    AppLogger.info(
      'Demo mode: Password reset request simulated',
      tag: 'AuthLocalDataSource',
    );

    AppLogger.methodExit(
      'requestPasswordReset',
      tag: 'AuthLocalDataSource',
      result: 'success',
    );
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    AppLogger.methodEntry(
      'resetPassword',
      tag: 'AuthLocalDataSource',
      params: {'resetToken': resetToken},
    );

    // For demo mode, always succeed
    AppLogger.info(
      'Demo mode: Password reset simulated',
      tag: 'AuthLocalDataSource',
    );

    AppLogger.methodExit(
      'resetPassword',
      tag: 'AuthLocalDataSource',
      result: 'success',
    );
    return true;
  }

  @override
  Future<List<User>> getTestUsers() async {
    AppLogger.methodEntry('getTestUsers', tag: 'AuthLocalDataSource');

    await _loadTestUsers();

    // Return unique test users (remove duplicates from lookup map)
    final uniqueUsers = <String, User>{};
    for (final user in _testUsers.values) {
      uniqueUsers[user.id] = user;
    }

    final userList = uniqueUsers.values.toList();
    AppLogger.methodExit(
      'getTestUsers',
      tag: 'AuthLocalDataSource',
      result: '${userList.length} users',
    );

    return userList;
  }
}
