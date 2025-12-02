/// Trade Providers - Main Barrel File
/// 
/// This is the main entry point for all trade-related providers.
/// Import this file to access all trade providers in a single import.
/// 
/// Example:
/// ```dart
/// import 'package:todo_app/features/trade/providers/trade_providers.dart';
/// 
/// // Use any provider
/// final portfolios = ref.watch(tradePortfoliosProvider(userId));
/// final cubit = ref.watch(favoriteFilterCubitProvider);
/// ```
library;

// ============================================================================
// Infrastructure (Internal - not exported)
// ============================================================================
// These are internal and should not be used directly by UI code

// ============================================================================
// Domain Providers (Public API)
// ============================================================================

// Favorite Filter Providers
export 'domain/favorite_filter_providers.dart' show
    favoriteFiltersProvider,
    favoriteFilterByIdProvider,
    watchFavoriteFiltersProvider;

// Journal Providers  
export 'domain/journal_providers.dart' show
    getJournalEntriesUseCaseProvider,
    createJournalEntryUseCaseProvider,
    updateJournalEntryUseCaseProvider,
    deleteJournalEntryUseCaseProvider;

// Calendar Providers
export 'domain/calendar_providers.dart' show
    getTradeCalendarProvider,
    getTradeCalendarByMonthProvider,
    getTradeCalendarByDayProvider,
    getTradeCalendarByDateRangeProvider,
    tradeCalendarProvider,
    tradeCalendarStreamProvider,
    tradeCalendarByMonthProvider;

// Controller Providers
export 'domain/controller_providers.dart' show
    // Query providers
    tradeDetailsByPortfolioProvider,
    watchTradesByPortfolioProvider,
    tradesByFiltersProvider,
    tradeDetailsByIdsProvider,
    filterTradeDetailsProvider,
    tradePortfoliosProvider,
    tradeHoldingsProvider,
    tradeSummaryProvider,
    tradeHoldingsStreamProvider,
    tradeSummaryStreamProvider,
    tradePortfoliosStreamProvider,
    // Action providers
    addTradeProvider,
    updateTradeProvider,
    batchUpdateTradesProvider,
    clearTradeCacheProvider,
    refreshPortfolioTradesProvider;

// ============================================================================
// Presentation Providers (Cubits)
// ============================================================================

export 'presentation/favorite_filter_cubit_provider.dart' show
    favoriteFilterCubitProvider;

export 'presentation/journal_cubit_provider.dart' show
    journalCubitProvider;

export 'presentation/calendar_cubit_provider.dart' show
    tradeCalendarCubitProvider;
