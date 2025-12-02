/// Data source providers for the trade feature
/// 
/// This file contains all RemoteDataSource providers that handle
/// API communication for trade-related operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/data/datasources/favorite_filter_remote_data_source.dart';
import '../../internal/data/datasources/journal_remote_data_source.dart';
import '../../internal/data/datasources/trade_controller_remote_data_source.dart';
import '../../internal/data/datasources/trade_remote_data_source.dart';
import 'api_providers.dart';

// ============================================================================
// Remote Data Sources
// ============================================================================

/// Provider for TradeRemoteDataSource
/// 
/// Handles API calls for trade portfolios, holdings, summaries, and calendar.
final tradeRemoteDataSourceProvider = Provider<TradeRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiConfig = ref.watch(apiConfigProvider);
  return TradeRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for TradeControllerRemoteDataSource
/// 
/// Handles API calls for trade CRUD operations and filtering.
final tradeControllerRemoteDataSourceProvider = Provider<TradeControllerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiConfig = ref.watch(apiConfigProvider);
  return TradeControllerRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for FavoriteFilterRemoteDataSource
/// 
/// Handles API calls for favorite filter management.
final favoriteFilterRemoteDataSourceProvider = Provider<FavoriteFilterRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiConfig = ref.watch(apiConfigProvider);
  return FavoriteFilterRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for JournalRemoteDataSource
/// 
/// Handles API calls for journal entry management.
final journalRemoteDataSourceProvider = Provider<JournalRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiConfig = ref.watch(apiConfigProvider);
  return JournalRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});
