/// Favorite filter domain providers
/// 
/// This file contains use case providers and public API providers
/// for favorite filter functionality.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/domain/entities/favorite_filter.dart';
import '../../internal/domain/usecases/create_favorite_filter_usecase.dart';
import '../../internal/domain/usecases/delete_favorite_filter_usecase.dart';
import '../../internal/domain/usecases/get_favorite_filters_usecase.dart';
import '../../internal/domain/usecases/set_default_filter_usecase.dart';
import '../infrastructure/repository_providers.dart';

// ============================================================================
// Use Case Providers (Private)
// ============================================================================

/// Provider for GetFavoriteFiltersUseCase
final getFavoriteFiltersUseCaseProvider = Provider<GetFavoriteFiltersUseCase>((ref) {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return GetFavoriteFiltersUseCase(repository);
});

/// Provider for CreateFavoriteFilterUseCase
final createFavoriteFilterUseCaseProvider = Provider<CreateFavoriteFilterUseCase>((ref) {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return CreateFavoriteFilterUseCase(repository);
});

/// Provider for DeleteFavoriteFilterUseCase
final deleteFavoriteFilterUseCaseProvider = Provider<DeleteFavoriteFilterUseCase>((ref) {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return DeleteFavoriteFilterUseCase(repository);
});

/// Provider for SetDefaultFilterUseCase
final setDefaultFilterUseCaseProvider = Provider<SetDefaultFilterUseCase>((ref) {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return SetDefaultFilterUseCase(repository);
});

// ============================================================================
// Public API Providers
// ============================================================================

/// Provider to get all favorite filters for a user
final favoriteFiltersProvider = FutureProvider.family<FavoriteFilterList, String>((ref, userId) async {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return repository.getFavoriteFilters(userId);
});

/// Provider to get a specific favorite filter by ID
final favoriteFilterByIdProvider = FutureProvider.family<FavoriteFilter, ({String userId, String filterId})>((
  ref,
  params,
) async {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return repository.getFavoriteFilterById(params.userId, params.filterId);
});

/// Provider to watch favorite filters stream for real-time updates
final watchFavoriteFiltersProvider = StreamProvider.family<FavoriteFilterList, String>((ref, userId) {
  final repository = ref.watch(favoriteFilterRepositoryProvider);
  return repository.watchFavoriteFilters(userId);
});
