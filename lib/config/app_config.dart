import '../core/constants/constants.dart';

/// Application configuration
class AppConfig {
  const AppConfig({
    required this.api,
    required this.environment,
    required this.google,
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
  final GoogleConfig google;
}

/// API configuration
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.timeout,
    required this.useMockData,
    required this.portfolio,
    required this.trade,
    this.document,
  });
  final String baseUrl;
  final int timeout;
  final bool useMockData;
  final PortfolioApiConfig portfolio;
  final TradeApiConfig trade;
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

/// Trade API configuration
class TradeApiConfig {
  const TradeApiConfig({
    required this.baseUrl,
    required this.portfolioListResource,
    required this.portfolioSummaryResource,
    required this.holdingsResource,
    required this.tradeDetailsResource,
    required this.calendarMonthResource,
    required this.calendarDayResource,
    required this.calendarQuarterResource,
    required this.calendarFinancialYearResource,
    required this.searchResource,
    this.connectTimeout = 30,
    this.receiveTimeout = 60,
    this.sendTimeout = 60,
    this.enabled = true,
  });
  final String baseUrl;
  final String portfolioListResource;
  final String portfolioSummaryResource;
  final String holdingsResource;
  final String tradeDetailsResource;
  final String calendarMonthResource;
  final String calendarDayResource;
  final String calendarQuarterResource;
  final String calendarFinancialYearResource;
  final String searchResource;
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;
  final bool enabled;
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

/// Google Sign-In configuration
class GoogleConfig {
  const GoogleConfig({
    required this.webClientId,
  });
  final String webClientId;
  
  /// Check if Google Sign-In is configured
  bool get isConfigured => webClientId.isNotEmpty;
}
