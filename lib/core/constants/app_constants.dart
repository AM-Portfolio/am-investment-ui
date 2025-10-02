/// Application configuration constants
/// All configuration values should be defined here instead of passing as parameters
class AppConstants {
  /// Application Information
  static const String appName = 'AM Investment';
  static const String appVersion = '1.0.0';
  static const int defaultPort = 3000;
  
  /// Asset Paths
  static const String assetsPath = 'lib/assets';
  static const String imagesPath = '$assetsPath/images';
  static const String mockDataPath = '$assetsPath/mock_data';
  
  /// Configuration Files
  static const String mainPropertiesFile = 'lib/assets/application.properties';
  static const String devPropertiesFile = 'lib/assets/application-dev.properties';
  static const String prodPropertiesFile = 'lib/assets/application-prod.properties';
  static const String testPropertiesFile = 'lib/assets/application-test.properties';
  static const String stagingPropertiesFile = 'lib/assets/application-staging.properties';
  
  /// Default Environment
  static const String defaultEnvironment = 'dev';
  
  /// API Configuration
  static const String defaultBaseUrl = 'http://localhost:8072';
  static const int defaultTimeout = 30000;
  static const bool defaultUseMockData = true;
  
  /// Portfolio API Defaults
  static const String defaultPortfolioBaseUrl = 'http://localhost:8072';
  static const String defaultHoldingsResource = '/api/v1/portfolios/holdings';
  static const String defaultSummaryResource = '/api/v1/portfolios/summary';
  static const String defaultTransactionsResource = '/api/v1/portfolios/transactions';
  
  /// Document API Defaults
  static const String defaultDocumentBaseUrl = 'http://localhost:8070';
  static const int defaultConnectTimeout = 30;
  static const int defaultReceiveTimeout = 60;
  static const int defaultSendTimeout = 60;
  static const bool defaultDocumentEnabled = true;
  
  /// Environment Configuration
  static const String defaultEnvironmentName = 'development';
  static const bool defaultDebugMode = true;
  static const String defaultLogLevel = 'debug';
}

/// Property keys used in configuration files
class PropertyKeys {
  // Application properties
  static const String appDefaultPort = 'app.default.port';
  
  // API properties
  static const String apiBaseUrl = 'api.baseUrl';
  static const String apiTimeout = 'api.timeout';
  static const String mockDataEnabled = 'mock.data.enabled';
  
  // Portfolio API properties
  static const String apiPortfolioBaseUrl = 'api.portfolio.baseUrl';
  static const String apiPortfolioHoldingsResource = 'api.portfolio.holdingsResource';
  static const String apiPortfolioSummaryResource = 'api.portfolio.summaryResource';
  static const String apiPortfolioTransactionsResource = 'api.portfolio.transactionsResource';
  
  // Document API properties
  static const String apiDocumentBaseUrl = 'api.document.baseUrl';
  static const String apiDocumentConnectTimeout = 'api.document.connectTimeout';
  static const String apiDocumentReceiveTimeout = 'api.document.receiveTimeout';
  static const String apiDocumentSendTimeout = 'api.document.sendTimeout';
  static const String apiDocumentEnabled = 'api.document.enabled';
  
  // Environment properties
  static const String environmentName = 'environment.name';
  static const String environmentDebugMode = 'environment.debugMode';
  static const String environmentLogLevel = 'environment.logLevel';
}

/// Environment variables keys
class EnvironmentKeys {
  static const String env = 'ENV';
  static const String flutterEnv = 'FLUTTER_ENV';
  static const String defaultEnvVar = 'DEFAULT_ENV_VAR';
}