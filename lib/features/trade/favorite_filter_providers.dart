import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/config_service.dart';
import '../../core/network/api_client.dart';
import 'internal/data/datasources/favorite_filter_remote_data_source.dart';
import 'internal/data/repositories/favorite_filter_repository_impl.dart';
import 'internal/domain/entities/favorite_filter.dart';
import 'internal/domain/repositories/favorite_filter_repository.dart';

// Infrastructure Providers

/// Provider for ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provider for FavoriteFilterRemoteDataSource
final _favoriteFilterRemoteDataSourceProvider = Provider<FavoriteFilterRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  final apiConfig = ConfigService.config.api;
  return FavoriteFilterRemoteDataSourceImpl(apiClient: apiClient, apiConfig: apiConfig);
});

/// Provider for FavoriteFilterRepository
final _favoriteFilterRepositoryProvider = Provider<FavoriteFilterRepository>((ref) {
  final remoteDataSource = ref.watch(_favoriteFilterRemoteDataSourceProvider);
  return FavoriteFilterRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Public Providers for UI

/// Provider to get all favorite filters for a user
final favoriteFiltersProvider = FutureProvider.family<FavoriteFilterList, String>((ref, userId) async {
  final repository = ref.watch(_favoriteFilterRepositoryProvider);
  return repository.getFavoriteFilters(userId);
});

/// Provider to get a specific favorite filter by ID
final favoriteFilterByIdProvider = FutureProvider.family<FavoriteFilter, ({String userId, String filterId})>((
  ref,
  params,
) async {
  final repository = ref.watch(_favoriteFilterRepositoryProvider);
  return repository.getFavoriteFilterById(params.userId, params.filterId);
});

/// Provider to watch favorite filters stream for real-time updates
final watchFavoriteFiltersProvider = StreamProvider.family<FavoriteFilterList, String>((ref, userId) {
  final repository = ref.watch(_favoriteFilterRepositoryProvider);
  return repository.watchFavoriteFilters(userId);
});

/// Provider to get the repository instance for direct method calls
final favoriteFilterRepositoryProvider = Provider<FavoriteFilterRepository>(
  (ref) => ref.watch(_favoriteFilterRepositoryProvider),
);
