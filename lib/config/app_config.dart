import '../core/constants/constants.dart';

/// Application configuration
class AppConfig {
  const AppConfig({
    required this.api,
    required this.environment,
    this.appName = AppConstants.appName,
    this.version = AppConstants.appVersion,
    this.debugMode = AppConstants.defaultDebugMode,
    this.defaultPort = AppConstants.defaultPort,
  });
  final String appName;
  final String version;
  final bool debugMode;
  final int defaultPort;
  final ApiConfig api;
  final EnvironmentConfig environment;
}

/// API configuration
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.timeout,
    required this.useMockData,
    required this.portfolio,
    this.document,
  });
  final String baseUrl;
  final int timeout;
  final bool useMockData;
  final PortfolioApiConfig portfolio;
  final DocumentApiConfig? document;
}

/// Portfolio API configuration
class PortfolioApiConfig {
  const PortfolioApiConfig({
    required this.baseUrl,
    required this.holdingsResource,
    required this.summaryResource,
    required this.transactionsResource,
  });
  final String baseUrl;
  final String holdingsResource;
  final String summaryResource;
  final String transactionsResource;
}

/// Document API configuration
/// Note: With Retrofit, only baseUrl and client settings can be configured dynamically
/// API endpoints are hardcoded in @RestApi() annotations
class DocumentApiConfig {
  const DocumentApiConfig({
    required this.baseUrl,
    this.connectTimeout = 30,
    this.receiveTimeout = 60,
    this.sendTimeout = 60,
    this.enabled = true,
  });
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;
  final bool enabled;
}

/// Environment configuration
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.name,
    required this.debugMode,
    required this.logLevel,
  });
  final String name;
  final bool debugMode;
  final String logLevel;
}
