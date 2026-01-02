import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../../features/trade/providers/trade_internal_providers.dart';
import '../../features/portfolio/providers/portfolio_providers.dart';

/// Service to preload essential data when the app starts
/// Loads authentication, trade portfolios, and normal portfolios for instant access
class AppPreloadService {
  /// Preload essential data after authentication
  /// 
  /// This method should be called immediately after successful login to:
  /// 1. Warm up Riverpod providers
  /// 2. Cache data for instant access
  /// 3. Improve user experience with faster page loads
  static Future<void> preloadEssentialData(WidgetRef ref, String userId) async {
    if (userId.isEmpty) {
      AppLogger.warning(
        'Cannot preload data: userId is empty',
        tag: 'AppPreloadService',
      );
      return;
    }

    AppLogger.info(
      'Starting preload of essential data for userId: $userId',
      tag: 'AppPreloadService',
    );

    try {
      // Preload in parallel for faster loading
      await Future.wait([
        _preloadTradePortfolios(ref, userId),
        _preloadPortfolioData(ref, userId),
      ]);

      AppLogger.info(
        'Successfully preloaded all essential data',
        tag: 'AppPreloadService',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to preload essential data',
        tag: 'AppPreloadService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - preloading is not critical
      // Data will be loaded on-demand when user navigates
    }
  }

  /// Preload trade portfolios
  static Future<void> _preloadTradePortfolios(WidgetRef ref, String userId) async {
    AppLogger.debug(
      'Preloading trade portfolios...',
      tag: 'AppPreloadService',
    );

    try {
      // Watch the stream provider to trigger initial load
      // The stream provider will cache the data in Riverpod
      ref.read(tradePortfoliosStreamProvider(userId));

      AppLogger.debug(
        'Trade portfolios preload initiated',
        tag: 'AppPreloadService',
      );
    } catch (e) {
      AppLogger.warning(
        'Trade portfolios preload failed: $e',
        tag: 'AppPreloadService',
      );
      rethrow;
    }
  }

  /// Preload portfolio summary and holdings
  static Future<void> _preloadPortfolioData(WidgetRef ref, String userId) async {
    AppLogger.debug(
      'Preloading portfolio data...',
      tag: 'AppPreloadService',
    );

    try {
      // Preload portfolio summary
      ref.read(portfolioSummaryProvider(userId));

      // Preload portfolio holdings
      ref.read(portfolioHoldingsProvider(userId));

      AppLogger.debug(
        'Portfolio data preload initiated',
        tag: 'AppPreloadService',
      );
    } catch (e) {
      AppLogger.warning(
        'Portfolio data preload failed: $e',
        tag: 'AppPreloadService',
      );
      rethrow;
    }
  }

  /// Invalidate preloaded data (useful for logout or data refresh)
  static void invalidatePreloadedData(WidgetRef ref, String userId) {
    AppLogger.info(
      'Invalidating preloaded data for userId: $userId',
      tag: 'AppPreloadService',
    );

    // Invalidate trade portfolios
    ref.invalidate(tradePortfoliosStreamProvider(userId));

    // Invalidate portfolio data
    ref.invalidate(portfolioSummaryProvider(userId));
    ref.invalidate(portfolioHoldingsProvider(userId));

    AppLogger.debug(
      'Preloaded data invalidated',
      tag: 'AppPreloadService',
    );
  }
}
