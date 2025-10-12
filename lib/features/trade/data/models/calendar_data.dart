import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_data.freezed.dart';
part 'calendar_data.g.dart';

@freezed
class CalendarData with _$CalendarData {
  const factory CalendarData({
    required Map<String, List<CalendarTrade>> portfolioTrades,
  }) = _CalendarData;

  factory CalendarData.fromJson(Map<String, dynamic> json) =>
      _$CalendarDataFromJson(json);
}

@freezed
class CalendarTrade with _$CalendarTrade {
  const factory CalendarTrade({
    required String tradeId,
    required String symbol,
    required String tradeDate,
    required String tradeType,
    required double profitLoss,
    double? profitLossPercentage,
    String? status,
  }) = _CalendarTrade;

  factory CalendarTrade.fromJson(Map<String, dynamic> json) =>
      _$CalendarTradeFromJson(json);
}
