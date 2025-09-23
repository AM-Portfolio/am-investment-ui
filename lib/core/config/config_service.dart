import 'dart:convert';
import 'package:flutter/services.dart';
import 'app_config.dart';

/// Configuration service to load and manage app configuration
/// Similar to Spring Boot's configuration management
class ConfigService {
  static ConfigService? _instance;
  static AppConfig? _config;

  ConfigService._();

  /// Singleton instance
  static ConfigService get instance {
    _instance ??= ConfigService._();
    return _instance!;
  }

  /// Get current configuration
  static AppConfig get config {
    if (_config == null) {
      print('Configuration not loaded, initializing with defaults...');
      _config = _getDefaultConfig();
    }
    return _config!;
  }

  /// Check if configuration is loaded
  static bool get isConfigLoaded => _config != null;

  /// Initialize configuration from asset file
  static Future<void> initialize({String environment = 'development'}) async {
    try {
      // Try to load environment-specific config first
      String configPath = 'assets/config/application-$environment.json';
      String? configString;
      
      try {
        configString = await rootBundle.loadString(configPath);
      } catch (e) {
        // Fallback to default config
        configPath = 'assets/config/application.json';
        configString = await rootBundle.loadString(configPath);
      }

      final Map<String, dynamic> configJson = json.decode(configString);
      _config = AppConfig.fromJson(configJson);
      
      print('Configuration loaded from: $configPath');
      print('API Base URL: ${_config!.api.baseUrl}');
      print('Environment: ${_config!.environment.name}');
      print('Use Mock Data: ${_config!.api.useMockData}');
      print('Portfolio Holdings Endpoint: ${_config!.api.portfolio.holdingsEndpoint}');
      print('Portfolio Summary Endpoint: ${_config!.api.portfolio.summaryEndpoint}');
      
    } catch (e) {
      print('Failed to load configuration: $e');
      // Fallback to default configuration
      //_config = _getDefaultConfig();
      print('Using default configuration');
    }
  }

  /// Get default configuration as fallback
  static AppConfig _getDefaultConfig() {
    return const AppConfig(
      api: ApiConfig(
        baseUrl: 'http://localhost:8072',
        timeout: 30000,
        useMockData: false,
        portfolio: PortfolioApiConfig(),
      ),
      environment: EnvironmentConfig(
        name: 'development',
        debugMode: true,
        logLevel: 'debug',
      ),
    );
  }

  /// Get full URL for a given endpoint
  static String getApiUrl(String endpoint) {
    return '${config.api.baseUrl}$endpoint';
  }

  /// Get portfolio holdings URL
  static String getPortfolioHoldingsUrl({required String userId}) {
    return getApiUrl('${config.api.portfolio.holdingsEndpoint}?userId=$userId');
  }

  /// Get portfolio summary URL
  static String getPortfolioSummaryUrl({required String userId}) {
    return getApiUrl('${config.api.portfolio.summaryEndpoint}?userId=$userId');
  }

  /// Get portfolio transactions URL
  static String getPortfolioTransactionsUrl({required String userId}) {
    return getApiUrl('${config.api.portfolio.transactionsEndpoint}?userId=$userId');
  }

  /// Check if mock data should be used
  static bool get useMockData => config.api.useMockData;

  /// Get API timeout
  static int get apiTimeout => config.api.timeout;

  /// Check if debug mode is enabled
  static bool get isDebugMode => config.environment.debugMode;

  /// Print current configuration for debugging
  static void printConfig() {
    final cfg = config;
    print('=== Current Configuration ===');
    print('Base URL: ${cfg.api.baseUrl}');
    print('Timeout: ${cfg.api.timeout}');
    print('Use Mock Data: ${cfg.api.useMockData}');
    print('Environment: ${cfg.environment.name}');
    print('Debug Mode: ${cfg.environment.debugMode}');
    print('Holdings Endpoint: ${cfg.api.portfolio.holdingsEndpoint}');
    print('Summary Endpoint: ${cfg.api.portfolio.summaryEndpoint}');
    print('Transactions Endpoint: ${cfg.api.portfolio.transactionsEndpoint}');
    print('==============================');
  }
}