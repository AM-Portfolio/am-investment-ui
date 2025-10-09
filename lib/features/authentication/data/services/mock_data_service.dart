import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/config/feature_flags.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/auth_result_model.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Service for providing mock authentication data
class MockDataService {
  final FeatureFlags _featureFlags = FeatureFlags();

  /// Load mock users from JSON
  Future<List<UserModel>> loadMockUsers() async {
    final response = await rootBundle.loadString(
      'assets/mock-data/users/auth_users.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> authUsers = data['auth_users'];
    return authUsers.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Load mock Google users from JSON
  Future<List<UserModel>> loadMockGoogleUsers() async {
    final response = await rootBundle.loadString(
      'assets/mock-data/google/oauth_profiles.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> googleProfiles = data['google_profiles'];
    return googleProfiles.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Authenticate user with email and password (mock)
  Future<AuthResultModel?> authenticateEmailPassword(
    String email,
    String password,
  ) async {
    // Simulate API delay
    if (_featureFlags.enableMockDelays) {
      await Future.delayed(
        Duration(milliseconds: _featureFlags.mockApiDelayMs),
      );
    }

    // Simulate error if enabled
    if (_featureFlags.enableErrorSimulation &&
        _shouldSimulateError(_featureFlags.authErrorRate)) {
      return null;
    }

    final users = await loadMockUsers();
    final user = users.cast<UserModel?>().firstWhere(
      (u) => u!.email == email,
      orElse: () => null,
    );

    if (user != null) {
      // In a real implementation, verify password hash
      // For mock, we'll use simple comparison
      final tokens = _generateMockTokens();
      return AuthResultModel(user: user, tokens: tokens);
    }

    return null;
  }

  /// Authenticate with Google (mock)
  Future<AuthResultModel> authenticateGoogle() async {
    // Simulate API delay
    if (_featureFlags.enableMockDelays) {
      await Future.delayed(
        Duration(milliseconds: _featureFlags.mockApiDelayMs),
      );
    }

    final googleUsers = await loadMockGoogleUsers();
    final user = googleUsers.first; // Use first Google user for mock
    final tokens = _generateMockTokens();

    return AuthResultModel(user: user, tokens: tokens);
  }

  /// Authenticate demo user
  Future<AuthResultModel> authenticateDemo() async {
    // Simulate API delay
    if (_featureFlags.enableMockDelays) {
      await Future.delayed(
        Duration(milliseconds: _featureFlags.mockApiDelayMs),
      );
    }

    final user = UserModel(
      id: 'demo_001',
      email: AuthConstants.demoEmail,
      displayName: 'Demo User',
      authMethod: AuthConstants.authMethodDemo,
      isDemo: true,
    );

    final tokens = _generateMockTokens();

    return AuthResultModel(user: user, tokens: tokens);
  }

  /// Generate mock authentication tokens
  AuthTokensModel _generateMockTokens() {
    final now = DateTime.now();
    final expiresAt = now.add(AuthConstants.tokenExpiryDuration);

    return AuthTokensModel(
      accessToken: _generateMockToken('access'),
      refreshToken: _generateMockToken('refresh'),
      expiresAt: expiresAt,
    );
  }

  /// Generate a mock token string
  String _generateMockToken(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_${type}_token_$timestamp';
  }

  /// Simulate error based on error rate
  bool _shouldSimulateError(double errorRate) {
    if (errorRate <= 0) return false;
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return random < (errorRate * 100);
  }
}
