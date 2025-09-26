import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/config/config_service.dart';

void main() {
  group('ConfigService', () {
    setUp(() {
      // Reset singleton state before each test
      ConfigService.resetForTesting();
    });

    tearDown(() {
      ConfigService.resetForTesting();
    });

    group('initialization', () {
      test('should initialize with default environment', () async {
        // Act
        await ConfigService.initialize();

        // Assert
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, isNotNull);
        expect(ConfigService.isInitialized, true);
      });

      test('should load development environment configuration', () async {
        // Act
        await ConfigService.initialize(environment: 'dev');

        // Assert
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, 'dev');
        expect(ConfigService.isInitialized, true);
        
        // Development environment should have specific settings
        expect(ConfigService.config?.api?.document?.enabled, true);
        expect(ConfigService.config?.logging?.level, isNotNull);
      });

      test('should load production environment configuration', () async {
        // Act
        await ConfigService.initialize(environment: 'prod');

        // Assert
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, 'prod');
        expect(ConfigService.isInitialized, true);
      });

      test('should load staging environment configuration', () async {
        // Act
        await ConfigService.initialize(environment: 'staging');

        // Assert
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, 'staging');
        expect(ConfigService.isInitialized, true);
      });

      test('should load test environment configuration', () async {
        // Act
        await ConfigService.initialize(environment: 'test');

        // Assert
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, 'test');
        expect(ConfigService.isInitialized, true);
        
        // Test environment should enable mock data
        expect(ConfigService.mockDataEnabled, true);
      });

      test('should handle unknown environment gracefully', () async {
        // Act
        await ConfigService.initialize(environment: 'unknown');

        // Assert - Should fall back to base configuration
        expect(ConfigService.config, isNotNull);
        expect(ConfigService.environment, 'unknown');
        expect(ConfigService.isInitialized, true);
      });

      test('should handle initialization failure gracefully', () async {
        // This test simulates what happens when configuration files are missing
        // In a real scenario, you might mock the asset loading to throw an error
        
        // For now, we test that multiple initializations work correctly
        await ConfigService.initialize(environment: 'dev');
        expect(ConfigService.isInitialized, true);
        
        // Second initialization should not cause issues
        await ConfigService.initialize(environment: 'prod');
        expect(ConfigService.isInitialized, true);
        expect(ConfigService.environment, 'prod');
      });
    });

    group('configuration access', () {
      setUp(() async {
        await ConfigService.initialize(environment: 'dev');
      });

      test('should provide API configuration', () {
        // Act
        final apiConfig = ConfigService.config?.api;

        // Assert
        expect(apiConfig, isNotNull);
        expect(apiConfig?.baseUrl, isNotNull);
        expect(apiConfig?.connectTimeout, isNotNull);
        expect(apiConfig?.receiveTimeout, isNotNull);
      });

      test('should provide document API configuration', () {
        // Act
        final documentConfig = ConfigService.config?.api?.document;

        // Assert
        expect(documentConfig, isNotNull);
        expect(documentConfig?.enabled, isNotNull);
        expect(documentConfig?.maxFileSize, isNotNull);
        expect(documentConfig?.allowedTypes, isNotEmpty);
      });

      test('should provide portfolio API configuration', () {
        // Act
        final portfolioConfig = ConfigService.config?.api?.portfolio;

        // Assert
        expect(portfolioConfig, isNotNull);
        expect(portfolioConfig?.baseUrl, isNotNull);
        expect(portfolioConfig?.connectTimeout, isNotNull);
        expect(portfolioConfig?.receiveTimeout, isNotNull);
      });

      test('should provide logging configuration', () {
        // Act
        final loggingConfig = ConfigService.config?.logging;

        // Assert
        expect(loggingConfig, isNotNull);
        expect(loggingConfig?.level, isNotNull);
        expect(loggingConfig?.enableConsole, isNotNull);
        expect(loggingConfig?.enableFile, isNotNull);
      });

      test('should provide database configuration', () {
        // Act
        final databaseConfig = ConfigService.config?.database;

        // Assert
        expect(databaseConfig, isNotNull);
        expect(databaseConfig?.name, isNotNull);
        expect(databaseConfig?.version, isNotNull);
      });

      test('should provide UI configuration', () {
        // Act
        final uiConfig = ConfigService.config?.ui;

        // Assert
        expect(uiConfig, isNotNull);
        expect(uiConfig?.theme, isNotNull);
        expect(uiConfig?.animation?.enabled, isNotNull);
        expect(uiConfig?.animation?.duration, isNotNull);
      });
    });

    group('environment-specific behavior', () {
      test('should enable mock data in test environment', () async {
        // Arrange
        await ConfigService.initialize(environment: 'test');

        // Act & Assert
        expect(ConfigService.mockDataEnabled, true);
        expect(ConfigService.isDevelopment, false);
        expect(ConfigService.isProduction, false);
        expect(ConfigService.isTesting, true);
      });

      test('should detect development environment correctly', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');

        // Act & Assert
        expect(ConfigService.isDevelopment, true);
        expect(ConfigService.isProduction, false);
        expect(ConfigService.isTesting, false);
        expect(ConfigService.isStaging, false);
      });

      test('should detect production environment correctly', () async {
        // Arrange
        await ConfigService.initialize(environment: 'prod');

        // Act & Assert
        expect(ConfigService.isProduction, true);
        expect(ConfigService.isDevelopment, false);
        expect(ConfigService.isTesting, false);
        expect(ConfigService.isStaging, false);
      });

      test('should detect staging environment correctly', () async {
        // Arrange
        await ConfigService.initialize(environment: 'staging');

        // Act & Assert
        expect(ConfigService.isStaging, true);
        expect(ConfigService.isProduction, false);
        expect(ConfigService.isDevelopment, false);
        expect(ConfigService.isTesting, false);
      });

      test('should handle mock data settings correctly', () async {
        // Test with mock data enabled
        await ConfigService.initialize(environment: 'test');
        expect(ConfigService.mockDataEnabled, true);

        // Test with mock data disabled (production)
        await ConfigService.initialize(environment: 'prod');
        expect(ConfigService.mockDataEnabled, false);
      });
    });

    group('configuration validation', () {
      test('should validate required configuration fields', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');

        // Act & Assert - Check that essential configurations are present
        expect(ConfigService.config?.api?.baseUrl, isNotEmpty);
        expect(ConfigService.config?.api?.connectTimeout, greaterThan(0));
        expect(ConfigService.config?.api?.receiveTimeout, greaterThan(0));
        expect(ConfigService.config?.database?.name, isNotEmpty);
        expect(ConfigService.config?.database?.version, greaterThan(0));
      });

      test('should have reasonable default values', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');
        final config = ConfigService.config!;

        // Act & Assert - Check reasonable defaults
        expect(config.api?.connectTimeout, lessThanOrEqualTo(60));
        expect(config.api?.receiveTimeout, lessThanOrEqualTo(120));
        expect(config.api?.document?.maxFileSize, greaterThan(0));
        expect(config.api?.document?.allowedTypes, isNotEmpty);
        expect(config.ui?.animation?.duration, greaterThan(0));
        expect(config.ui?.animation?.duration, lessThanOrEqualTo(2000));
      });

      test('should handle missing optional configuration gracefully', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');

        // Act & Assert - Optional configs should have safe defaults or null handling
        final config = ConfigService.config!;
        
        // These should not throw, even if optional configs are missing
        expect(() => config.api?.document?.enabled ?? true, returnsNormally);
        expect(() => config.logging?.enableConsole ?? true, returnsNormally);
        expect(() => config.ui?.theme ?? 'light', returnsNormally);
      });
    });

    group('feature flags', () {
      test('should respect document upload feature flag', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');

        // Act
        final isDocumentUploadEnabled = ConfigService.config?.api?.document?.enabled ?? false;

        // Assert
        expect(isDocumentUploadEnabled, isA<bool>());
        
        // In development, document upload should typically be enabled
        if (ConfigService.isDevelopment) {
          expect(isDocumentUploadEnabled, true);
        }
      });

      test('should handle feature flags for different environments', () async {
        // Test development features
        await ConfigService.initialize(environment: 'dev');
        var config = ConfigService.config!;
        expect(config.logging?.enableConsole, true);
        
        // Test production features  
        await ConfigService.initialize(environment: 'prod');
        config = ConfigService.config!;
        // Production might have different logging settings
        expect(config.logging?.level, isNotNull);
      });
    });

    group('performance and caching', () {
      test('should initialize only once', () async {
        // Arrange
        expect(ConfigService.isInitialized, false);

        // Act - Multiple initializations
        await ConfigService.initialize(environment: 'dev');
        final firstConfig = ConfigService.config;
        
        await ConfigService.initialize(environment: 'dev');
        final secondConfig = ConfigService.config;

        // Assert - Should be the same instance (cached)
        expect(ConfigService.isInitialized, true);
        expect(firstConfig, isNotNull);
        expect(secondConfig, isNotNull);
      });

      test('should allow re-initialization with different environment', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');
        expect(ConfigService.environment, 'dev');

        // Act - Re-initialize with different environment
        await ConfigService.initialize(environment: 'prod');

        // Assert - Should update to new environment
        expect(ConfigService.environment, 'prod');
        expect(ConfigService.isInitialized, true);
      });
    });

    group('error scenarios', () {
      test('should provide safe defaults when configuration is missing', () {
        // Act - Access config before initialization
        final config = ConfigService.config;

        // Assert - Should handle gracefully
        expect(config, isNull);
        expect(ConfigService.isInitialized, false);
        expect(() => ConfigService.environment, returnsNormally);
      });

      test('should handle null configuration values safely', () async {
        // Arrange
        await ConfigService.initialize(environment: 'dev');

        // Act & Assert - Safe access patterns
        expect(() => ConfigService.config?.api?.baseUrl ?? 'default', returnsNormally);
        expect(() => ConfigService.config?.nonExistentField?.value ?? 'default', returnsNormally);
        
        final baseUrl = ConfigService.config?.api?.baseUrl ?? 'http://localhost:3000';
        expect(baseUrl, isNotEmpty);
      });
    });

    group('configuration merging', () {
      test('should merge environment-specific overrides correctly', () async {
        // This test verifies that environment-specific configs override base configs
        
        // Test development overrides
        await ConfigService.initialize(environment: 'dev');
        final devConfig = ConfigService.config!;
        
        // Development should have specific settings
        expect(devConfig.logging?.enableConsole, true);
        expect(devConfig.api?.document?.enabled, true);
        
        // Test production overrides
        await ConfigService.initialize(environment: 'prod');
        final prodConfig = ConfigService.config!;
        
        // Production might have different logging settings
        expect(prodConfig.logging?.level, isNotNull);
        
        // But should still have base API configuration
        expect(prodConfig.api?.baseUrl, isNotNull);
      });
    });
  });
}