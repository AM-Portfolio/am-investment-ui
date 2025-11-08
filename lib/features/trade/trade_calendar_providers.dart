import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/cubit/trade_calendar_cubit.dart';
import 'providers/trade_internal_providers.dart';

/// Provider for TradeCalendarCubit
final tradeCalendarCubitProvider = Provider.family<TradeCalendarCubit, ({String userId, String portfolioId})>((
  ref,
  params,
) {
  final getTradeCalendar = ref.watch(getTradeCalendarProvider);
  final getTradeCalendarByMonth = ref.watch(getTradeCalendarByMonthProvider);
  final getTradeCalendarByDay = ref.watch(getTradeCalendarByDayProvider);
  final getTradeCalendarByDateRange = ref.watch(getTradeCalendarByDateRangeProvider);

  return TradeCalendarCubit(
    getTradeCalendar,
    getTradeCalendarByMonth,
    getTradeCalendarByDay,
    getTradeCalendarByDateRange,
  );
});
