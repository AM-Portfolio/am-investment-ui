/// Repository providers for the trade feature
/// 
/// This file contains all Repository providers that implement
/// business logic and data access for trade operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/data/repositories/favorite_filter_repository_impl.dart';
import '../../internal/data/repositories/journal_repository_impl.dart';
import '../../internal/data/repositories/trade_controller_repository_impl.dart';
import '../../internal/data/repositories/trade_repository_impl.dart';
import '../../internal/domain/repositories/favorite_filter_repository.dart';
import '../../internal/domain/repositories/journal_repository.dart';
import '../../internal/domain/repositories/trade_controller_repository.dart';
import '../../internal/domain/repositories/trade_repository.dart';
import 'data_source_providers.dart';

// ============================================================================
// Repositories
// ============================================================================

/// Provider for TradeRepository
/// 
/// Manages trade portfolios, holdings, summaries, and calendar data.
final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  final remoteDataSource = ref.watch(tradeRemoteDataSourceProvider);
  return TradeRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for TradeControllerRepository
/// 
/// Manages trade CRUD operations, filtering, and batch updates.
final tradeControllerRepositoryProvider = Provider<TradeControllerRepository>((ref) {
  final remoteDataSource = ref.watch(tradeControllerRemoteDataSourceProvider);
  return TradeControllerRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for FavoriteFilterRepository
/// 
/// Manages favorite filter creation, retrieval, and deletion.
final favoriteFilterRepositoryProvider = Provider<FavoriteFilterRepository>((ref) {
  final remoteDataSource = ref.watch(favoriteFilterRemoteDataSourceProvider);
  return FavoriteFilterRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for JournalRepository
/// 
/// Manages journal entry CRUD operations.
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final remoteDataSource = ref.watch(journalRemoteDataSourceProvider);
  return JournalRepositoryImpl(remoteDataSource: remoteDataSource);
});
