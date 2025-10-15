import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/cubit/trade_calendar_cubit.dart';
import 'presentation/cubit/trade_calendar_state.dart';
import 'presentation/mappers/trade_calendar_universal_mapper.dart';
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
