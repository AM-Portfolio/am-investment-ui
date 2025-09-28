import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../../domain/entities/portfolio_summary.dart';

part 'portfolio_dto.freezed.dart';
part 'portfolio_dto.g.dart';

/// Data Transfer Object for Portfolio Holdings
@freezed
class PortfolioHoldingsDto with _$PortfolioHoldingsDto {
  const factory PortfolioHoldingsDto({
    required String userId,
    required List<PortfolioHoldingDto> holdings,
    required DateTime lastUpdated,
  }) = _PortfolioHoldingsDto;

  factory PortfolioHoldingsDto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioHoldingsDtoFromJson(json);
}

/// Data Transfer Object for Portfolio Holding
@freezed
class PortfolioHoldingDto with _$PortfolioHoldingDto {
  const factory PortfolioHoldingDto({
    required String id,
    required String symbol,
    required String companyName,
    required String sector,
    required String industry,
    required double quantity,
    required double avgPrice,
    required double currentPrice,
    required double investedAmount,
    required double currentValue,
    required double todayChange,
    required double todayChangePercentage,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double portfolioWeight,
    @Default([]) List<BrokerHoldingDto> brokerHoldings,
  }) = _PortfolioHoldingDto;

  factory PortfolioHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioHoldingDtoFromJson(json);
}

/// Data Transfer Object for Broker Holding
@freezed
class BrokerHoldingDto with _$BrokerHoldingDto {
  const factory BrokerHoldingDto({
    required String brokerId,
    required String brokerName,
    required double quantity,
    required double avgPrice,
    required double investedAmount,
    required DateTime? lastUpdated,
  }) = _BrokerHoldingDto;

  factory BrokerHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerHoldingDtoFromJson(json);
}

/// Data Transfer Object for Portfolio Summary
@freezed
class PortfolioSummaryDto with _$PortfolioSummaryDto {
  const factory PortfolioSummaryDto({
    required String userId,
    required double totalValue,
    required double totalInvested,
    required double totalGainLoss,
    required double totalGainLossPercentage,
    required double todayChange,
    required double todayChangePercentage,
    required int totalHoldings,
    required DateTime lastUpdated,
    @Default([]) List<SectorAllocationDto> sectorAllocation,
    @Default([]) List<TopPerformerDto> topPerformers,
    @Default([]) List<TopPerformerDto> worstPerformers,
  }) = _PortfolioSummaryDto;

  factory PortfolioSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryDtoFromJson(json);
}

/// Data Transfer Object for Sector Allocation
@freezed
class SectorAllocationDto with _$SectorAllocationDto {
  const factory SectorAllocationDto({
    required String sector,
    required double value,
    required double percentage,
    required int holdings,
  }) = _SectorAllocationDto;

  factory SectorAllocationDto.fromJson(Map<String, dynamic> json) =>
      _$SectorAllocationDtoFromJson(json);
}

/// Data Transfer Object for Top Performer
@freezed
class TopPerformerDto with _$TopPerformerDto {
  const factory TopPerformerDto({
    required String symbol,
    required String companyName,
    required double gainLoss,
    required double gainLossPercentage,
    required double currentValue,
  }) = _TopPerformerDto;

  factory TopPerformerDto.fromJson(Map<String, dynamic> json) =>
      _$TopPerformerDtoFromJson(json);
}

/// Extension methods for converting DTOs to domain entities
extension PortfolioHoldingsDtoX on PortfolioHoldingsDto {
  PortfolioHoldings toDomain() {
    return PortfolioHoldings(
      userId: userId,
      holdings: holdings.map((dto) => dto.toDomain()).toList(),
      lastUpdated: lastUpdated,
    );
  }
}

extension PortfolioHoldingDtoX on PortfolioHoldingDto {
  PortfolioHolding toDomain() {
    return PortfolioHolding(
      id: id,
      symbol: symbol,
      companyName: companyName,
      sector: sector,
      industry: industry,
      quantity: quantity,
      avgPrice: avgPrice,
      currentPrice: currentPrice,
      investedAmount: investedAmount,
      currentValue: currentValue,
      todayChange: todayChange,
      todayChangePercentage: todayChangePercentage,
      totalGainLoss: totalGainLoss,
      totalGainLossPercentage: totalGainLossPercentage,
      portfolioWeight: portfolioWeight,
      brokerHoldings: brokerHoldings.map((dto) => dto.toDomain()).toList(),
    );
  }
}

extension BrokerHoldingDtoX on BrokerHoldingDto {
  BrokerHolding toDomain() {
    return BrokerHolding(
      brokerId: brokerId,
      brokerName: brokerName,
      quantity: quantity,
      avgPrice: avgPrice,
      investedAmount: investedAmount,
      lastUpdated: lastUpdated,
    );
  }
}

extension PortfolioSummaryDtoX on PortfolioSummaryDto {
  PortfolioSummary toDomain() {
    return PortfolioSummary(
      userId: userId,
      totalValue: totalValue,
      totalInvested: totalInvested,
      totalGainLoss: totalGainLoss,
      totalGainLossPercentage: totalGainLossPercentage,
      todayChange: todayChange,
      todayChangePercentage: todayChangePercentage,
      totalHoldings: totalHoldings,
      lastUpdated: lastUpdated,
      sectorAllocation: sectorAllocation.map((dto) => dto.toDomain()).toList(),
      topPerformers: topPerformers.map((dto) => dto.toDomain()).toList(),
      worstPerformers: worstPerformers.map((dto) => dto.toDomain()).toList(),
    );
  }
}

extension SectorAllocationDtoX on SectorAllocationDto {
  SectorAllocation toDomain() {
    return SectorAllocation(
      sector: sector,
      value: value,
      percentage: percentage,
      holdings: holdings,
    );
  }
}

extension TopPerformerDtoX on TopPerformerDto {
  TopPerformer toDomain() {
    return TopPerformer(
      symbol: symbol,
      companyName: companyName,
      gainLoss: gainLoss,
      gainLossPercentage: gainLossPercentage,
      currentValue: currentValue,
    );
  }
}