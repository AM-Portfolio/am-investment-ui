import '../../../../features/trade/internal/domain/entities/trade_calendar.dart';
import 'calendar_types.dart';

/// Converter to transform TradeCalendar entity to year calendar data
class YearCalendarConverter {
  /// Convert TradeCalendar entity to months data for year calendar
  static Map<int, CalendarMonthData> convertToMonthsData({
    required TradeCalendar entity,
    required String portfolioId,
    required int year,
  }) {
    final trades = entity.portfolioTrades[portfolioId] ?? [];

    // Filter trades for the specified year
    final yearTrades = trades.where((trade) => trade.tradeDate.year == year).toList();

    // Group trades by month and day
    final monthsMap = <int, Map<int, List<TradeDetail>>>{};
    for (final trade in yearTrades) {
      final month = trade.tradeDate.month;
      final day = trade.tradeDate.day;

      monthsMap.putIfAbsent(month, () => {});
      monthsMap[month]!.putIfAbsent(day, () => []).add(trade);
    }

    // Build calendar month data
    final months = <int, CalendarMonthData>{};

    for (var month = 1; month <= 12; month++) {
      final monthTrades = monthsMap[month] ?? {};

      // Build day data for this month
      final days = <int, CalendarDayData>{};
      for (final entry in monthTrades.entries) {
        final day = entry.key;
        final dayTrades = entry.value;

        var pnl = 0.0;
        for (final trade in dayTrades) {
          pnl += trade.metrics.profitLoss;
        }

        final status = _getDayStatus(pnl);

        days[day] = CalendarDayData(
          date: DateTime(year, month, day),
          status: status,
          pnl: pnl,
          tradeCount: dayTrades.length,
        );
      }

      months[month] = CalendarMonthData(year: year, month: month, days: days);
    }

    return months;
  }

  /// Get day status from P&L
  static TradeDayStatus _getDayStatus(double pnl) {
    if (pnl > 0) return TradeDayStatus.win;
    if (pnl < 0) return TradeDayStatus.loss;
    return TradeDayStatus.breakeven;
  }
}
