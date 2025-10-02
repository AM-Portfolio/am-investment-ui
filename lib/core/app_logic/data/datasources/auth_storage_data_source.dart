import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_state.dart';
import '../../../utils/logger.dart';

/// Local storage data source for authentication persistence
/// 
/// Handles saving and retrieving authentication data from device storage
class AuthStorageDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userKey = 'user_data';
  static const String _expiresAtKey = 'token_expires_at';

  /// Save authentication data to persistent storage
  Future<void> saveAuthData({
    required User user,
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    AppLogger.methodEntry('saveAuthData', tag: 'AuthStorageDataSource',
        params: {'userId': user.id, 'userEmail': user.email});
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.setString(_tokenKey, token),
        prefs.setString(_userKey, jsonEncode(user.toJson())),
        if (refreshToken != null) prefs.setString(_refreshTokenKey, refreshToken),
        if (expiresAt != null) prefs.setString(_expiresAtKey, expiresAt.toIso8601String()),
      ]);
      
      AppLogger.debug('Authentication data saved to persistent storage', tag: 'AuthStorageDataSource');
      AppLogger.methodExit('saveAuthData', tag: 'AuthStorageDataSource', result: 'success');
    } catch (e) {
      AppLogger.error('Failed to save authentication data', tag: 'AuthStorageDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('saveAuthData', tag: 'AuthStorageDataSource', result: 'error');
      rethrow;
    }
  }

  /// Load authentication data from persistent storage
  Future<AuthState?> loadAuthData() async {
    AppLogger.methodEntry('loadAuthData', tag: 'AuthStorageDataSource');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final expiresAtString = prefs.getString(_expiresAtKey);
      
      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        final expiresAt = expiresAtString != null 
            ? DateTime.parse(expiresAtString)
            : null;
        
        final authState = AuthState(
          isAuthenticated: true,
          currentUser: user,
          accessToken: token,
          refreshToken: refreshToken,
          tokenExpiresAt: expiresAt,
        );
        
        AppLogger.info('Authentication data loaded from storage for user: ${user.email}',
            tag: 'AuthStorageDataSource');
        AppLogger.methodExit('loadAuthData', tag: 'AuthStorageDataSource', result: 'success');
        
        return authState;
      } else {
        AppLogger.debug('No authentication data found in storage', tag: 'AuthStorageDataSource');
        AppLogger.methodExit('loadAuthData', tag: 'AuthStorageDataSource', result: 'no_data');
        return null;
      }
    } catch (e) {
      AppLogger.error('Failed to load authentication data', tag: 'AuthStorageDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('loadAuthData', tag: 'AuthStorageDataSource', result: 'error');
      
      // Clear potentially corrupted data
      await clearAuthData();
      return null;
    }
  }

  /// Clear authentication data from persistent storage
  Future<void> clearAuthData() async {
    AppLogger.methodEntry('clearAuthData', tag: 'AuthStorageDataSource');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userKey),
        prefs.remove(_expiresAtKey),
      ]);
      
      AppLogger.debug('Authentication data cleared from persistent storage', tag: 'AuthStorageDataSource');
      AppLogger.methodExit('clearAuthData', tag: 'AuthStorageDataSource', result: 'success');
    } catch (e) {
      AppLogger.error('Failed to clear authentication data', tag: 'AuthStorageDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('clearAuthData', tag: 'AuthStorageDataSource', result: 'error');
      rethrow;
    }
  }

  /// Update token data (useful for token refresh)
  Future<void> updateTokenData({
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    AppLogger.methodEntry('updateTokenData', tag: 'AuthStorageDataSource');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final updates = <Future<bool>>[
        prefs.setString(_tokenKey, token),
      ];
      
      if (refreshToken != null) {
        updates.add(prefs.setString(_refreshTokenKey, refreshToken));
      }
      
      if (expiresAt != null) {
        updates.add(prefs.setString(_expiresAtKey, expiresAt.toIso8601String()));
      }
      
      await Future.wait(updates);
      
      AppLogger.debug('Token data updated in persistent storage', tag: 'AuthStorageDataSource');
      AppLogger.methodExit('updateTokenData', tag: 'AuthStorageDataSource', result: 'success');
    } catch (e) {
      AppLogger.error('Failed to update token data', tag: 'AuthStorageDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('updateTokenData', tag: 'AuthStorageDataSource', result: 'error');
      rethrow;
    }
  }

  /// Check if authentication data exists in storage
  Future<bool> hasAuthData() async {
    AppLogger.methodEntry('hasAuthData', tag: 'AuthStorageDataSource');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey(_tokenKey) && prefs.containsKey(_userKey);
      
      AppLogger.methodExit('hasAuthData', tag: 'AuthStorageDataSource', 
          result: hasData ? 'has_data' : 'no_data');
      return hasData;
    } catch (e) {
      AppLogger.error('Failed to check authentication data', tag: 'AuthStorageDataSource',
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('hasAuthData', tag: 'AuthStorageDataSource', result: 'error');
      return false;
    }
  }
}