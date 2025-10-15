import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/converters/trade_calendar_converter.dart';
import 'presentation/cubit/trade_calendar_cubit.dart';
import 'presentation/cubit/trade_calendar_state.dart';
import 'providers/trade_internal_providers.dart';

/// Provider for TradeCalendarUniversalMapper
final tradeCalendarMapperProvider = Provider<TradeCalendarUniversalMapper>(
  (ref) => TradeCalendarUniversalMapper(),
);

/// Provider for TradeCalendarCubit
final tradeCalendarCubitProvider =
    Provider.family<TradeCalendarCubit, ({String userId, String portfolioId})>((
      ref,
      params,
    ) {
      final getTradeCalendar = ref.watch(_getTradeCalendarProvider);
      final mapper = ref.watch(tradeCalendarMapperProvider);

      return TradeCalendarCubit(getTradeCalendar, mapper);
    });
