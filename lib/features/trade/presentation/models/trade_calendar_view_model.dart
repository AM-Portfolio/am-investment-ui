import '../../../../../shared/widgets/calendar/universal_calendar/card_types.dart';
import '../../../../../shared/widgets/calendar/universal_calendar/types.dart';

/// View model for trade calendar data optimized for UI consumption
class TradeCalendarViewModel {
  const TradeCalendarViewModel({
    required this.portfolioId,
    required this.calendarData,
    this.dateFilter,
    this.selectedDate,
    this.lastUpdated,
  });

  /// Portfolio ID this calendar represents
  final String portfolioId;

  /// Calendar data organized by date
  final Map<String, List<CardData>> calendarData;

  /// Applied date filter
  final DateSelection? dateFilter;

  /// Currently selected date
  final DateTime? selectedDate;

  /// When this data was last updated
  final DateTime? lastUpdated;

  /// Get all available dates from calendar data
  List<DateTime> get availableDates =>
      calendarData.keys.map(DateTime.parse).toList()..sort();

  /// Get all events (deprecated, use calendarData instead)
  @deprecated
  List<Map<String, dynamic>> get events => calendarData.entries
      .map((entry) => {'date': entry.key, 'cards': entry.value})
      .toList();

  /// Get date range from available data
  DateSelection? get dateRange {
    if (calendarData.isEmpty) return null;

    final dates = availableDates;
    if (dates.isEmpty) return null;

    return DateSelection(
      startDate: dates.first,
      endDate: dates.last,
      description: 'Trade Calendar Range',
      filterType: DateFilterMode.custom,
    );
  }

  /// Get total number of trade days
  int get totalTradeDays => calendarData.length;

  /// Get total P&L across all dates
  double get totalPnL {
    var total = 0.0;
    for (final cards in calendarData.values) {
      for (final card in cards) {
        if (card is TradeCardData) {
          total += card.pnl;
        }
      }
    }
    return total;
  }

  /// Get total trade count across all dates
  int get totalTradeCount {
    var total = 0;
    for (final cards in calendarData.values) {
      for (final card in cards) {
        if (card is TradeCardData) {
          total += card.tradeCount;
        }
      }
    }
    return total;
  }

  /// Get overall win rate
  double get overallWinRate {
    var totalWins = 0;
    var totalTrades = 0;

    for (final cards in calendarData.values) {
      for (final card in cards) {
        if (card is TradeCardData) {
          totalWins += card.winCount;
          totalTrades += card.tradeCount;
        }
      }
    }

    return totalTrades > 0 ? totalWins / totalTrades : 0.0;
  }

  /// Copy with new parameters
  TradeCalendarViewModel copyWith({
    String? portfolioId,
    Map<String, List<CardData>>? calendarData,
    DateSelection? dateFilter,
    DateTime? selectedDate,
    DateTime? lastUpdated,
  }) => TradeCalendarViewModel(
    portfolioId: portfolioId ?? this.portfolioId,
    calendarData: calendarData ?? this.calendarData,
    dateFilter: dateFilter ?? this.dateFilter,
    selectedDate: selectedDate ?? this.selectedDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
