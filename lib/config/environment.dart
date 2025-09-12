import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

enum Environment {
  development,
  preprod,
  production,
}

class EnvironmentConfig {
  static Environment environment = kDebugMode ? Environment.development : Environment.production;
  
  // API URLs
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        // For development, use platform-specific URLs
        if (kIsWeb) {
          return 'http://localhost:8082'; // Web uses localhost directly
        } else if (Platform.isAndroid) {
          return 'http://10.0.2.2:8082'; // Android emulator special IP for host machine
        } else {
          return 'http://localhost:8082'; // iOS simulator and desktop
        }
      case Environment.preprod:
        return 'https://preprod-api.example.com';
      case Environment.production:
        return 'http://10.0.2.2:8082';
    }
  }
  
  // Feature flags
  static bool get enableDebugFeatures {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.preprod:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  // Environment-specific settings
  static Map<String, dynamic> get settings {
    switch (environment) {
      case Environment.development:
        return {
          'appTitle': '[DEV] AM Investment',
          'analyticsEnabled': false,
          'refreshInterval': 30, // seconds
          'useMockData': true,
        };
      case Environment.preprod:
        return {
          'appTitle': '[PREPROD] AM Investment',
          'analyticsEnabled': false,
          'refreshInterval': 60, // seconds
          'useMockData': false,
        };
      case Environment.production:
        return {
          'appTitle': 'AM Investment',
          'analyticsEnabled': true,
          'refreshInterval': 300, // seconds
          'useMockData': false,
        };
    }
  }
  
  // Initialize environment based on build arguments
  static void setEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'development':
        environment = Environment.development;
        break;
      case 'preprod':
        environment = Environment.preprod;
        break;
      case 'production':
      default:
        environment = Environment.production;
        break;
    }
    
    debugPrint('Environment set to: ${environment.toString().split('.').last}');
    debugPrint('API URL: $apiBaseUrl');
  }
}
