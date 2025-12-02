/// Calendar domain providers
/// 
/// This file contains use case providers and public API providers
/// for trade calendar functionality.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/domain/entities/trade_calendar.dart';
import '../../internal/domain/usecases/get_trade_calendar.dart';
import '../../internal/domain/usecases/get_trade_calendar_by_date_range.dart';
import '../../internal/domain/usecases/get_trade_calendar_by_day.dart';
import '../../internal/domain/usecases/get_trade_calendar_by_month.dart';
import '../../presentation/models/trade_calendar_view_model.dart';
import '../infrastructure/repository_providers.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTradeCalendar use case
final getTradeCalendarProvider = Provider<GetTradeCalendar>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeCalendar(repository);
});

/// Provider for GetTradeCalendarByMonth use case
final getTradeCalendarByMonthProvider = Provider<GetTradeCalendarByMonth>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeCalendarByMonth(repository);
});

/// Provider for GetTradeCalendarByDay use case
final getTradeCalendarByDayProvider = Provider<GetTradeCalendarByDay>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeCalendarByDay(repository);
});

/// Provider for GetTradeCalendarByDateRange use case
final getTradeCalendarByDateRangeProvider = Provider<GetTradeCalendarByDateRange>((ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeCalendarByDateRange(repository);
});

// ============================================================================
// Public API Providers
// ============================================================================

/// Provider for trade calendar
final tradeCalendarProvider = FutureProvider.family<TradeCalendar, ({String userId, String portfolioId})>((
  ref,
  params,
) async {
  final useCase = ref.watch(getTradeCalendarProvider);
  return useCase(params.userId, params.portfolioId);
});

/// Provider for watching trade calendar (stream) - returns view models
final tradeCalendarStreamProvider =
    StreamProvider.family<TradeCalendarViewModel, ({String userId, String portfolioId})>((ref, params) {
      final useCase = ref.watch(getTradeCalendarProvider);
      return useCase.watch(params.userId, params.portfolioId).map(TradeCalendarViewModel.fromEntity);
    });

/// Provider for trade calendar by month - returns view model
final tradeCalendarByMonthProvider =
    FutureProvider.family<TradeCalendarViewModel, ({String userId, String portfolioId, int year, int month})>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(getTradeCalendarByMonthProvider);
      final result = await useCase(params.userId, params.portfolioId, year: params.year, month: params.month);
      return TradeCalendarViewModel.fromEntity(result);
    });
