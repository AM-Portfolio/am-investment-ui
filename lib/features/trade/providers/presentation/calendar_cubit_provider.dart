/// Calendar cubit provider
/// 
/// This file contains the presentation layer provider for TradeCalendarCubit.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/cubit/trade_calendar_cubit.dart';
import '../domain/calendar_providers.dart';

// ============================================================================
// Cubit Provider
// ============================================================================

/// Provider for TradeCalendarCubit
/// 
/// Manages trade calendar state and operations in the UI.
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
