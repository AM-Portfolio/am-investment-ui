/// Shared infrastructure providers for the trade feature
/// 
/// This file contains common infrastructure providers used across
/// all trade-related functionality.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_config.dart';
import '../../../../config/config_service.dart';
import '../../../../core/network/api_client.dart';

// ============================================================================
// API Infrastructure
// ============================================================================

/// Provider for ApiClient instance
/// 
/// Provides a singleton instance of ApiClient for making HTTP requests.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for ApiConfig
/// 
/// Provides the API configuration from ConfigService.
final apiConfigProvider = Provider<ApiConfig>((ref) => ConfigService.config.api);
