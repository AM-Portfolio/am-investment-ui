import 'package:flutter/foundation.dart';

enum Environment {
  preprod,
  production,
}

class EnvironmentConfig {
  static Environment environment = Environment.production;
  
  // API URLs
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.preprod:
        return 'https://preprod-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }
  
  // Feature flags
  static bool get enableDebugFeatures {
    switch (environment) {
      case Environment.preprod:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  // Environment-specific settings
  static Map<String, dynamic> get settings {
    switch (environment) {
      case Environment.preprod:
        return {
          'appTitle': '[PREPROD] AM Investment',
          'analyticsEnabled': false,
          'refreshInterval': 60, // seconds
        };
      case Environment.production:
        return {
          'appTitle': 'AM Investment',
          'analyticsEnabled': true,
          'refreshInterval': 300, // seconds
        };
    }
  }
  
  // Initialize environment based on build arguments
  static void setEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'preprod':
        environment = Environment.preprod;
        break;
      case 'production':
      default:
        environment = Environment.production;
        break;
    }
    
    debugPrint('Environment set to: ${environment.toString().split('.').last}');
  }
}
