import '../../../../../../core/app_logic/domain/entities/heatmap/heatmap_entities.dart';

/// Portfolio-specific heatmap tile entity that extends the core entity
/// Contains portfolio-specific data like sector, market cap, etc.
class PortfolioHeatmapTileEntity extends HeatmapTileEntity {
  final String symbol;
  final String? sector;
  final String? industry;
  final String? marketCap;
  final double? currentPrice;
  final double? quantity;
  final double? totalValue;
  final double? dayChange;
  final double? dayChangePercent;
  final String? currency;
  final String? exchange;

  const PortfolioHeatmapTileEntity({
    required super.id,
    required super.name,
    required super.displayName,
    required super.weightage,
    required super.performance,
    super.value,
    super.metadata,
    required this.symbol,
    this.sector,
    this.industry,
    this.marketCap,
    this.currentPrice,
    this.quantity,
    this.totalValue,
    this.dayChange,
    this.dayChangePercent,
    this.currency,
    this.exchange,
  });

  /// Create from core entity with additional portfolio data
  factory PortfolioHeatmapTileEntity.fromEntity(
    HeatmapTileEntity entity, {
    required String symbol,
    String? sector,
    String? industry,
    String? marketCap,
    double? currentPrice,
    double? quantity,
    double? totalValue,
    double? dayChange,
    double? dayChangePercent,
    String? currency,
    String? exchange,
  }) {
    return PortfolioHeatmapTileEntity(
      id: entity.id,
      name: entity.name,
      displayName: entity.displayName,
      weightage: entity.weightage,
      performance: entity.performance,
      value: entity.value,
      metadata: entity.metadata,
      symbol: symbol,
      sector: sector,
      industry: industry,
      marketCap: marketCap,
      currentPrice: currentPrice,
      quantity: quantity,
      totalValue: totalValue,
      dayChange: dayChange,
      dayChangePercent: dayChangePercent,
      currency: currency,
      exchange: exchange,
    );
  }

  /// Convert to core entity
  @override
  HeatmapTileEntity toEntity() {
    return HeatmapTileEntity(
      id: id,
      name: name,
      displayName: displayName,
      weightage: weightage,
      performance: performance,
      value: value,
      metadata: metadata,
    );
  }

  /// Get formatted current price
  String get formattedCurrentPrice {
    if (currentPrice == null) return '';
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${currentPrice!.toStringAsFixed(2)}';
  }

  /// Get formatted total value
  String get formattedTotalValue {
    if (totalValue == null) return '';
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${totalValue!.toStringAsFixed(2)}';
  }

  /// Get formatted day change
  String get formattedDayChange {
    if (dayChange == null) return '';
    final currencySymbol = _getCurrencySymbol();
    final sign = dayChange! >= 0 ? '+' : '';
    return '$sign$currencySymbol${dayChange!.toStringAsFixed(2)}';
  }

  /// Get formatted day change percentage
  String get formattedDayChangePercent {
    if (dayChangePercent == null) return '';
    final sign = dayChangePercent! >= 0 ? '+' : '';
    return '$sign${dayChangePercent!.toStringAsFixed(2)}%';
  }

  /// Get formatted quantity
  String get formattedQuantity {
    if (quantity == null) return '';
    return quantity!.toStringAsFixed(0);
  }

  /// Helper to get currency symbol
  String _getCurrencySymbol() {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currency != null ? '$currency ' : '\$';
    }
  }

  /// Check if day change is positive
  bool get isDayChangePositive => (dayChange ?? 0) >= 0;

  /// Check if day change is negative
  bool get isDayChangeNegative => (dayChange ?? 0) < 0;

  /// Get market cap category
  MarketCapCategory get marketCapCategory {
    if (marketCap == null) return MarketCapCategory.unknown;

    switch (marketCap!.toLowerCase()) {
      case 'large':
      case 'large cap':
        return MarketCapCategory.largeCap;
      case 'mid':
      case 'mid cap':
        return MarketCapCategory.midCap;
      case 'small':
      case 'small cap':
        return MarketCapCategory.smallCap;
      default:
        return MarketCapCategory.unknown;
    }
  }

  @override
  PortfolioHeatmapTileEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    double? weightage,
    double? performance,
    double? value,
    Map<String, dynamic>? metadata,
    String? symbol,
    String? sector,
    String? industry,
    String? marketCap,
    double? currentPrice,
    double? quantity,
    double? totalValue,
    double? dayChange,
    double? dayChangePercent,
    String? currency,
    String? exchange,
  }) {
    return PortfolioHeatmapTileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      weightage: weightage ?? this.weightage,
      performance: performance ?? this.performance,
      value: value ?? this.value,
      metadata: metadata ?? this.metadata,
      symbol: symbol ?? this.symbol,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      marketCap: marketCap ?? this.marketCap,
      currentPrice: currentPrice ?? this.currentPrice,
      quantity: quantity ?? this.quantity,
      totalValue: totalValue ?? this.totalValue,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
      currency: currency ?? this.currency,
      exchange: exchange ?? this.exchange,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'symbol': symbol,
      'sector': sector,
      'industry': industry,
      'marketCap': marketCap,
      'currentPrice': currentPrice,
      'quantity': quantity,
      'totalValue': totalValue,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'currency': currency,
      'exchange': exchange,
    });
    return map;
  }

  factory PortfolioHeatmapTileEntity.fromMap(Map<String, dynamic> map) {
    return PortfolioHeatmapTileEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      weightage: map['weightage']?.toDouble() ?? 0.0,
      performance: map['performance']?.toDouble() ?? 0.0,
      value: map['value']?.toDouble(),
      metadata: map['metadata'],
      symbol: map['symbol'] ?? '',
      sector: map['sector'],
      industry: map['industry'],
      marketCap: map['marketCap'],
      currentPrice: map['currentPrice']?.toDouble(),
      quantity: map['quantity']?.toDouble(),
      totalValue: map['totalValue']?.toDouble(),
      dayChange: map['dayChange']?.toDouble(),
      dayChangePercent: map['dayChangePercent']?.toDouble(),
      currency: map['currency'],
      exchange: map['exchange'],
    );
  }

  @override
  String toString() {
    return 'PortfolioHeatmapTileEntity(symbol: $symbol, sector: $sector, performance: $performance, weightage: $weightage)';
  }
}

/// Market cap categories for portfolio holdings
enum MarketCapCategory { largeCap, midCap, smallCap, unknown }
