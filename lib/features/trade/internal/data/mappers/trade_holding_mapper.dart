import '../../domain/entities/trade_holding.dart';
import '../dtos/trade_holding_dto.dart';

/// Mapper for trade holding between DTO and domain entity
class TradeHoldingMapper {
  /// Convert TradeHoldingDto to TradeHolding domain entity
  static TradeHolding fromDto(TradeHoldingDto dto) {
    return TradeHolding(
      symbol: dto.symbol,
      companyName: dto.companyName,
      quantity: dto.quantity,
      currentPrice: dto.currentPrice,
      avgPrice: dto.avgPrice,
      currentValue: dto.currentValue,
      investedAmount: dto.investedAmount,
      totalGainLoss: dto.totalGainLoss,
      totalGainLossPercentage: dto.totalGainLossPercentage,
      todayChange: dto.todayChange,
      todayChangePercentage: dto.todayChangePercentage,
      weight: dto.weight ?? 0.0,
      sector: dto.sector,
      industry: dto.industry,
      exchange: dto.exchange,
    );
  }

  /// Convert TradeHoldingsDto to TradeHoldings domain entity
  static TradeHoldings fromListDto(
    TradeHoldingsDto dto,
    String userId,
    String portfolioId,
  ) {
    return TradeHoldings(
      userId: userId,
      portfolioId: portfolioId,
      holdings: dto.holdings.map((h) => fromDto(h)).toList(),
      totalCount: dto.totalCount ?? dto.holdings.length,
      totalValue: dto.totalValue,
      totalGainLoss: dto.totalGainLoss,
    );
  }

  /// Convert TradeHolding domain entity to TradeHoldingDto
  static TradeHoldingDto toDto(TradeHolding entity) {
    return TradeHoldingDto(
      symbol: entity.symbol,
      companyName: entity.companyName,
      quantity: entity.quantity,
      currentPrice: entity.currentPrice,
      avgPrice: entity.avgPrice,
      currentValue: entity.currentValue,
      investedAmount: entity.investedAmount,
      totalGainLoss: entity.totalGainLoss,
      totalGainLossPercentage: entity.totalGainLossPercentage,
      todayChange: entity.todayChange,
      todayChangePercentage: entity.todayChangePercentage,
      weight: entity.weight,
      sector: entity.sector,
      industry: entity.industry,
      exchange: entity.exchange,
    );
  }
}
