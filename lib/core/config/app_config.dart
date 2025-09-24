/// Application configuration
class AppConfig {
  final ApiConfig api;
  final EnvironmentConfig environment;

  const AppConfig({
    required this.api,
    required this.environment,
  });
}

/// API configuration
class ApiConfig {
  final String baseUrl;
  final int timeout;
  final bool useMockData;
  final PortfolioApiConfig portfolio;

  const ApiConfig({
    required this.baseUrl,
    required this.timeout,
    required this.useMockData,
    required this.portfolio,
  });
}

/// Portfolio API specific configuration
class PortfolioApiConfig {
  final String baseUrl;
  final String holdingsResource;
  final String summaryResource;
  final String transactionsResource;

  const PortfolioApiConfig({
    required this.baseUrl,
    required this.holdingsResource,
    required this.summaryResource,
    required this.transactionsResource,
  });
}

/// Environment configuration
class EnvironmentConfig {
  final String name;
  final bool debugMode;
  final String logLevel;

  const EnvironmentConfig({
    required this.name,
    required this.debugMode,
    required this.logLevel,
  });
}