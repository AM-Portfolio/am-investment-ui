import 'package:flutter/foundation.dart';
import 'app_config.dart';
import 'app_properties.dart';

/// Configuration service that loads and manages application configuration
/// Similar to Spring Boot's configuration management
class ConfigService with PropertyInjection {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static AppConfig? _config;
  static bool _isInitialized = false;

  /// Initialize configuration from properties
  /// @param environment - Optional environment name (dev, prod, test, etc.)
  /// If not provided, will use ENV environment variable or default to 'dev'
  static Future<void> initialize({String? environment}) async {
    if (_isInitialized) return;

    // Load properties first with specified environment
    await AppProperties().loadProperties(environment: environment);

    final properties = AppProperties();

    // Create config from properties
    _config = AppConfig(
      defaultPort: properties.getIntValue('app.default.port', defaultValue: 3000),
      api: ApiConfig(
        baseUrl: properties.getValue('api.baseUrl'),
        timeout: properties.getIntValue('api.timeout'),
        useMockData: properties.getBoolValue('mock.data.enabled'),
        portfolio: PortfolioApiConfig(
          baseUrl: properties.getValue('api.portfolio.baseUrl'),
          holdingsResource: properties.getValue('api.portfolio.holdingsResource'),
          summaryResource: properties.getValue('api.portfolio.summaryResource'),
          transactionsResource: properties.getValue('api.portfolio.transactionsResource'),
        ),
        document: DocumentApiConfig(
          baseUrl: properties.getValue('api.document.baseUrl', defaultValue: 'http://localhost:8070'),
          connectTimeout: properties.getIntValue('api.document.connectTimeout', defaultValue: 30),
          receiveTimeout: properties.getIntValue('api.document.receiveTimeout', defaultValue: 60),
          sendTimeout: properties.getIntValue('api.document.sendTimeout', defaultValue: 60),
          enabled: properties.getBoolValue('api.document.enabled', defaultValue: true),
        ),
      ),
      environment: EnvironmentConfig(
        name: properties.getValue('environment.name'),
        debugMode: properties.getBoolValue('environment.debugMode'),
        logLevel: properties.getValue('environment.logLevel'),
      ),
    );

    _isInitialized = true;

    if (kDebugMode) {
      print('ConfigService initialized with properties:');
      printConfig();
    }
  }

  /// Get current configuration
  static AppConfig get config {
    if (!_isInitialized || _config == null) {
      throw Exception('ConfigService not initialized. Call ConfigService.initialize() first.');
    }
    return _config!;
  }

  /// Check if using mock data
  static bool get useMockData => config.api.useMockData;

  /// Get default port for application
  static int get defaultPort => config.defaultPort;

  /// Get Flutter run command with configured port
  static String getFlutterRunCommand({String device = 'chrome'}) {
    return 'flutter run -d $device --web-port ${config.defaultPort}';
  }

  /// Get local URL with configured port
  static String getLocalUrl() {
    return 'http://localhost:${config.defaultPort}';
  }

  /// Get property value directly
  static String getProperty(String key, {String? defaultValue}) {
    return AppProperties().getValue(key, defaultValue: defaultValue);
  }

  /// Get portfolio holdings URL
  static String getPortfolioHoldingsUrl({required String userId}) {
    final portfolioConfig = config.api.portfolio;
    return '${portfolioConfig.baseUrl}${portfolioConfig.holdingsResource}/$userId';
  }

  /// Get portfolio summary URL
  static String getPortfolioSummaryUrl({required String userId}) {
    final portfolioConfig = config.api.portfolio;
    return '${portfolioConfig.baseUrl}${portfolioConfig.summaryResource}/$userId';
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (!kDebugMode) return;

    print('=== Configuration ===');
    print('Default Port: ${config.defaultPort}');
    print('Local URL: ${getLocalUrl()}');
    print('Flutter Command: ${getFlutterRunCommand()}');
    print('API Base URL: ${config.api.baseUrl}');
    print('API Timeout: ${config.api.timeout}ms');
    print('Mock Data: ${config.api.useMockData}');
    print('Portfolio Base URL: ${config.api.portfolio.baseUrl}');
    print('Holdings Resource: ${config.api.portfolio.holdingsResource}');
    print('Summary Resource: ${config.api.portfolio.summaryResource}');
    print('Environment: ${config.environment.name}');
    print('Debug Mode: ${config.environment.debugMode}');
    print('Log Level: ${config.environment.logLevel}');
    print('====================');
  }

  /// Reload configuration
  /// @param environment - Optional environment name to reload with
  static Future<void> reload({String? environment}) async {
    _isInitialized = false;
    _config = null;
    await AppProperties().reload(environment: environment);
    await initialize(environment: environment);
  }


}

/// Example usage with @Value-like annotation
class ExampleService with PropertyInjection {
  // Using the mixin for property injection
  String get apiUrl => property('api.baseUrl');
  int get timeout => intProperty('api.timeout');
  bool get mockEnabled => boolProperty('mock.data.enabled');
  
  void printConfig() {
    print('API URL: $apiUrl');
    print('Timeout: $timeout');
    print('Mock Enabled: $mockEnabled');
  }
}