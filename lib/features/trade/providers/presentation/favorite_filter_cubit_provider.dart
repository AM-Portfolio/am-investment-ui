/// Favorite filter cubit provider
/// 
/// This file contains the presentation layer provider for FavoriteFilterCubit.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/cubit/favorite_filter/favorite_filter_cubit.dart';
import '../domain/favorite_filter_providers.dart';

// ============================================================================
// Cubit Provider
// ============================================================================

/// Provider for FavoriteFilterCubit
/// 
/// Manages favorite filter state and operations in the UI.
final favoriteFilterCubitProvider = Provider<FavoriteFilterCubit>(
  (ref) => FavoriteFilterCubit(
    getFavoriteFilters: ref.watch(getFavoriteFiltersUseCaseProvider),
    createFavoriteFilter: ref.watch(createFavoriteFilterUseCaseProvider),
    deleteFavoriteFilter: ref.watch(deleteFavoriteFilterUseCaseProvider),
    setDefaultFilter: ref.watch(setDefaultFilterUseCaseProvider),
  ),
);
