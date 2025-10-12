import 'package:json_annotation/json_annotation.dart';

part 'trade_holding_dto.g.dart';

/// DTO for trade holding from API
@JsonSerializable()
class TradeHoldingDto {
  const TradeHoldingDto({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.currentPrice,
    required this.avgPrice,
    required this.currentValue,
    required this.investedAmount,
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.todayChange,
    required this.todayChangePercentage,
    this.weight,
    this.sector,
    this.industry,
    this.exchange,
  });

  factory TradeHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingDtoFromJson(json);

  final String symbol;
  final String companyName;
  final double quantity;
  final double currentPrice;
  final double avgPrice;
  final double currentValue;
  final double investedAmount;
  final double totalGainLoss;
  final double totalGainLossPercentage;
  final double todayChange;
  final double todayChangePercentage;
  final double? weight;
  final String? sector;
  final String? industry;
  final String? exchange;

  Map<String, dynamic> toJson() => _$TradeHoldingDtoToJson(this);
}

/// DTO for trade holdings collection from API
@JsonSerializable()
class TradeHoldingsDto {
  const TradeHoldingsDto({
    required this.holdings,
    this.totalCount,
    this.totalValue,
    this.totalGainLoss,
  });

  factory TradeHoldingsDto.fromJson(Map<String, dynamic> json) =>
      _$TradeHoldingsDtoFromJson(json);

  final List<TradeHoldingDto> holdings;
  final int? totalCount;
  final double? totalValue;
  final double? totalGainLoss;

  Map<String, dynamic> toJson() => _$TradeHoldingsDtoToJson(this);
}
