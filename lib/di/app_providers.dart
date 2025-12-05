import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../config/config_service.dart';
import '../config/environment_config.dart' as env_config;
import '../core/network/api_client.dart';

part 'app_providers.g.dart';

// Configuration Providers - Keep alive (singleton instances)
@riverpod
Future<AppConfig> appConfig(Ref ref) async {
  // Initialize ConfigService if not already done
  await ConfigService.initialize();

  // Get configuration from ConfigService
  return ConfigService.config;
}

@riverpod
Future<String> apiBaseUrl(Ref ref) async {
  final config = await ref.watch(appConfigProvider.future);
  return config.api.baseUrl;
}

@Riverpod(keepAlive: true)
env_config.Environment environmentConfig(Ref ref) {
  return env_config.EnvironmentConfig.current; // Get current environment
}

@riverpod
Future<ApiClient> apiClient(Ref ref) async {
  // Keep HTTP client alive to maintain connections
  final config = await ref.watch(appConfigProvider.future);
  return ApiClient(baseUrl: config.api.baseUrl);
}

@riverpod
Future<PortfolioApiConfig> portfolioApiConfig(Ref ref) async {
  final config = await ref.watch(appConfigProvider.future);
  return config.api.portfolio;
}
