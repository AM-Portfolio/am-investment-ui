import '../../domain/entities/trade_portfolio.dart';
import '../dtos/trade_portfolio_dto.dart';

/// Mapper for trade portfolio between DTO and domain entity
class TradePortfolioMapper {
  /// Convert TradePortfolioDto to TradePortfolio domain entity
  static TradePortfolio fromDto(TradePortfolioDto dto) {
    return TradePortfolio(
      id: dto.portfolioId,
      name: dto.name,
      ownerId: dto.ownerId ?? '',
      totalValue: dto.totalValue ?? 0.0,
      totalGainLoss: dto.totalGainLoss ?? 0.0,
      totalGainLossPercentage: dto.totalGainLossPercentage ?? 0.0,
      holdingsCount: dto.holdingsCount ?? 0,
      description: dto.description,
      lastUpdated: dto.lastUpdated != null
          ? DateTime.tryParse(dto.lastUpdated!)
          : null,
    );
  }

  /// Convert TradePortfolioListDto to TradePortfolioList domain entity
  static TradePortfolioList fromListDto(
    TradePortfolioListDto dto,
    String userId,
  ) {
    return TradePortfolioList(
      userId: userId,
      portfolios: dto.portfolios.map((p) => fromDto(p)).toList(),
      totalCount: dto.totalCount ?? dto.portfolios.length,
    );
  }

  /// Convert TradePortfolio domain entity to TradePortfolioDto
  static TradePortfolioDto toDto(TradePortfolio entity) {
    return TradePortfolioDto(
      portfolioId: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      totalValue: entity.totalValue,
      totalGainLoss: entity.totalGainLoss,
      totalGainLossPercentage: entity.totalGainLossPercentage,
      holdingsCount: entity.holdingsCount,
      description: entity.description,
      lastUpdated: entity.lastUpdated?.toIso8601String(),
    );
  }
}
