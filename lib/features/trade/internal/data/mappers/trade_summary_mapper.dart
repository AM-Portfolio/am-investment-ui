import '../../domain/entities/trade_summary.dart';
import '../dtos/trade_summary_dto.dart';

/// Mapper for trade summary between DTO and domain entity
class TradeSummaryMapper {
  /// Convert TradeSectorAllocationDto to TradeSectorAllocation domain entity
  static TradeSectorAllocation fromSectorDto(TradeSectorAllocationDto dto) {
    return TradeSectorAllocation(
      sector: dto.sector,
      value: dto.value,
      percentage: dto.percentage,
      holdingsCount: dto.holdingsCount ?? 0,
    );
  }

  /// Convert TradeTopMoverDto to TradeTopMover domain entity
  static TradeTopMover fromTopMoverDto(TradeTopMoverDto dto) {
    return TradeTopMover(
      symbol: dto.symbol,
      name: dto.name,
      change: dto.change,
      changePercentage: dto.changePercentage,
      currentPrice: dto.currentPrice,
    );
  }

  /// Convert TradeSummaryDto to TradeSummary domain entity
  static TradeSummary fromDto(
    TradeSummaryDto dto,
    String userId,
    String portfolioId,
  ) {
    return TradeSummary(
      userId: userId,
      portfolioId: portfolioId,
      totalValue: dto.totalValue,
      totalInvested: dto.totalInvested,
      totalGainLoss: dto.totalGainLoss,
      totalGainLossPercentage: dto.totalGainLossPercentage,
      todayChange: dto.todayChange,
      todayChangePercentage: dto.todayChangePercentage,
      sectorAllocation: dto.sectorAllocation
              ?.map((s) => fromSectorDto(s))
              .toList() ??
          [],
      topGainers:
          dto.topGainers?.map((t) => fromTopMoverDto(t)).toList() ?? [],
      topLosers: dto.topLosers?.map((t) => fromTopMoverDto(t)).toList() ?? [],
      holdingsCount: dto.holdingsCount,
    );
  }

  /// Convert TradeSummary domain entity to TradeSummaryDto
  static TradeSummaryDto toDto(TradeSummary entity) {
    return TradeSummaryDto(
      totalValue: entity.totalValue,
      totalInvested: entity.totalInvested,
      totalGainLoss: entity.totalGainLoss,
      totalGainLossPercentage: entity.totalGainLossPercentage,
      todayChange: entity.todayChange,
      todayChangePercentage: entity.todayChangePercentage,
      sectorAllocation: entity.sectorAllocation
          .map(
            (s) => TradeSectorAllocationDto(
              sector: s.sector,
              value: s.value,
              percentage: s.percentage,
              holdingsCount: s.holdingsCount,
            ),
          )
          .toList(),
      topGainers: entity.topGainers
          .map(
            (t) => TradeTopMoverDto(
              symbol: t.symbol,
              name: t.name,
              change: t.change,
              changePercentage: t.changePercentage,
              currentPrice: t.currentPrice,
            ),
          )
          .toList(),
      topLosers: entity.topLosers
          .map(
            (t) => TradeTopMoverDto(
              symbol: t.symbol,
              name: t.name,
              change: t.change,
              changePercentage: t.changePercentage,
              currentPrice: t.currentPrice,
            ),
          )
          .toList(),
      holdingsCount: entity.holdingsCount,
    );
  }
}
