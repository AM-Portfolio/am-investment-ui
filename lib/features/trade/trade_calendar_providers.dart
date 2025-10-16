import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/cubit/trade_calendar_cubit.dart';
import 'providers/trade_internal_providers.dart';

/// Provider for TradeCalendarCubit
final tradeCalendarCubitProvider =
    Provider.family<TradeCalendarCubit, ({String userId, String portfolioId})>((
      ref,
      params,
    ) {
      final getTradeCalendar = ref.watch(getTradeCalendarProvider);

      return TradeCalendarCubit(getTradeCalendar);
    });
