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
  final String endpoint;
  final Map<String, String> headers;

  const PortfolioApiConfig({
    required this.endpoint,
    required this.headers,
  });
}

/// Environment configuration
class EnvironmentConfig {
  final String name;
  final bool isProduction;
  final bool enableLogging;

  const EnvironmentConfig({
    required this.name,
    required this.isProduction,
    required this.enableLogging,
  });
}