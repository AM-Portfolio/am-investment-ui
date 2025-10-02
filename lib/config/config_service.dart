import 'package:flutter/foundation.dart';
import 'app_config.dart';
import 'app_properties.dart';
import 'environment.dart' as env;
import '../core/constants/constants.dart';
import '../core/utils/logger.dart';

/// Configuration service that loads and manages application configuration
/// Similar to Spring Boot's configuration management
class ConfigService with PropertyInjection {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static AppConfig? _config;
  static bool _isInitialized = false;

  /// Map environment string to Environment enum and set it
  static void _setEnvironmentFromString(String environmentName) {
    env.Environment targetEnv;
    switch (environmentName.toLowerCase()) {
      case 'development':
      case 'dev':
        targetEnv = env.Environment.development;
        break;
      case 'preprod':
      case 'staging':
        targetEnv = env.Environment.preprod;
        break;
      case 'production':
      case 'prod':
        targetEnv = env.Environment.production;
        break;
      default:
        print('Unknown environment: $environmentName, defaulting to development');
        targetEnv = env.Environment.development;
        break;
    }
    
    env.EnvironmentConfig.environment = targetEnv;
    print('Environment set to: ${targetEnv.name}');
  }

  /// Initialize configuration from properties
  /// @param environment - Optional environment name (dev, prod, test, etc.)
  /// If not provided, will use ENV environment variable or default to 'dev'
  static Future<void> initialize({String? environment}) async {
    if (_isInitialized) return;

    // Load properties first with specified environment
    await AppProperties().loadProperties(environment: environment);

    final properties = AppProperties();

    // Set the environment in EnvironmentConfig based on properties
    final environmentName = properties.getValue(PropertyKeys.environmentName, defaultValue: AppConstants.defaultEnvironmentName);
    _setEnvironmentFromString(environmentName);

    // Create config from properties using constants for keys and defaults
    _config = AppConfig(
      defaultPort: properties.getIntValue(PropertyKeys.appDefaultPort, defaultValue: AppConstants.defaultPort),
      api: ApiConfig(
        baseUrl: properties.getValue(PropertyKeys.apiBaseUrl, defaultValue: AppConstants.defaultBaseUrl),
        timeout: properties.getIntValue(PropertyKeys.apiTimeout, defaultValue: AppConstants.defaultTimeout),
        useMockData: properties.getBoolValue(PropertyKeys.mockDataEnabled, defaultValue: AppConstants.defaultUseMockData),
        portfolio: PortfolioApiConfig(
          baseUrl: properties.getValue(PropertyKeys.apiPortfolioBaseUrl, defaultValue: AppConstants.defaultPortfolioBaseUrl),
          holdingsResource: properties.getValue(PropertyKeys.apiPortfolioHoldingsResource, defaultValue: AppConstants.defaultHoldingsResource),
          summaryResource: properties.getValue(PropertyKeys.apiPortfolioSummaryResource, defaultValue: AppConstants.defaultSummaryResource),
          transactionsResource: properties.getValue(PropertyKeys.apiPortfolioTransactionsResource, defaultValue: AppConstants.defaultTransactionsResource),
        ),
        document: DocumentApiConfig(
          baseUrl: properties.getValue(PropertyKeys.apiDocumentBaseUrl, defaultValue: AppConstants.defaultDocumentBaseUrl),
          connectTimeout: properties.getIntValue(PropertyKeys.apiDocumentConnectTimeout, defaultValue: AppConstants.defaultConnectTimeout),
          receiveTimeout: properties.getIntValue(PropertyKeys.apiDocumentReceiveTimeout, defaultValue: AppConstants.defaultReceiveTimeout),
          sendTimeout: properties.getIntValue(PropertyKeys.apiDocumentSendTimeout, defaultValue: AppConstants.defaultSendTimeout),
          enabled: properties.getBoolValue(PropertyKeys.apiDocumentEnabled, defaultValue: AppConstants.defaultDocumentEnabled),
        ),
      ),
      environment: EnvironmentConfig(
        name: properties.getValue(PropertyKeys.environmentName, defaultValue: AppConstants.defaultEnvironmentName),
        debugMode: properties.getBoolValue(PropertyKeys.environmentDebugMode, defaultValue: AppConstants.defaultDebugMode),
        logLevel: properties.getValue(PropertyKeys.environmentLogLevel, defaultValue: AppConstants.defaultLogLevel),
      ),
    );

    // Initialize logger after configuration is loaded
    AppLogger.initialize();
    
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