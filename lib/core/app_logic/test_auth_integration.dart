import 'package:flutter/foundation.dart';

import 'services/auth_service.dart';
import '../utils/logger.dart';

/// Test integration for the clean architecture auth system
/// This demonstrates how all components work together
class AuthIntegrationTest {
  
  /// Test the complete auth flow with clean architecture
  static Future<void> testCompleteFlow() async {
    if (!kDebugMode) {
      AppLogger.info('Auth integration test skipped - not in debug mode', tag: 'AuthIntegrationTest');
      return;
    }

    AppLogger.info('Starting clean architecture auth integration test', tag: 'AuthIntegrationTest');
    
    try {
      // Initialize clean auth service (uses singleton pattern with dependency injection)
      final authService = AuthService();
      await authService.initialize();
      
      AppLogger.info('All components initialized successfully', tag: 'AuthIntegrationTest');
      
      // Test login flow
      AppLogger.info('Testing login flow...', tag: 'AuthIntegrationTest');
      final loginResult = await authService.login('demo@test.com', 'password123');
      
      if (loginResult.isSuccess) {
        AppLogger.info('✅ Login test passed!', tag: 'AuthIntegrationTest');
        
        // Test current user access
        final currentUser = authService.currentState.currentUser;
        AppLogger.info('✅ Current user retrieved: ${currentUser?.email}', tag: 'AuthIntegrationTest');
        
        // Test logout
        AppLogger.info('Testing logout flow...', tag: 'AuthIntegrationTest');
        await authService.logout();
        
        // Check if user is logged out
        final isLoggedOut = !authService.currentState.isAuthenticated;
        if (isLoggedOut) {
          AppLogger.info('✅ Logout test passed!', tag: 'AuthIntegrationTest');
        } else {
          AppLogger.warning('❌ Logout test failed - user still authenticated', tag: 'AuthIntegrationTest');
        }
        
      } else {
        AppLogger.warning('❌ Login test failed: ${loginResult.errorMessage}', tag: 'AuthIntegrationTest');
      }
      
      AppLogger.info('🎉 Clean architecture auth integration test completed!', tag: 'AuthIntegrationTest');
      
    } catch (e, stackTrace) {
      AppLogger.error('Integration test failed', tag: 'AuthIntegrationTest', 
          error: e, stackTrace: stackTrace);
    }
  }
}