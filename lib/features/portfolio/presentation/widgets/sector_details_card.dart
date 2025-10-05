import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';
import '../../../../shared/widgets/cards/investment_card.dart';
import '../../../../shared/models/investment_card/models.dart';
import '../../../../core/utils/logger.dart';

/// Widget displaying detailed sector information with expandable stock lists
/// Shows sector rank, total value, weightage and expandable stock details
class SectorDetailsCard extends StatefulWidget {
  const SectorDetailsCard({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
  });
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  @override
  State<SectorDetailsCard> createState() => _SectorDetailsCardState();
}

class _SectorDetailsCardState extends State<SectorDetailsCard> {
  final Set<String> _expandedSectors = <String>{};

  @override
  Widget build(BuildContext context) => Card(
    elevation: 4,
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sector Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    ),
  );

  Widget _buildContent(BuildContext context) {
    AppLogger.debug(
      'Building content - isLoading: ${widget.isLoading}, '
      'hasError: ${widget.error != null}, '
      'hasHeatmap: ${widget.heatmap != null}, '
      'sectorsCount: ${widget.heatmap?.sectors.length ?? 0}',
      tag: 'SectorDetailsCard',
    );

    if (widget.isLoading) {
      AppLogger.info('Showing loading state', tag: 'SectorDetailsCard');
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.error != null) {
      AppLogger.error(
        'Showing error state: ${widget.error}',
        tag: 'SectorDetailsCard',
      );
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load sector details',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.heatmap == null || widget.heatmap!.sectors.isEmpty) {
      AppLogger.warning(
        'No sector details available',
        tag: 'SectorDetailsCard',
      );
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.data_usage_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No sector details available',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    AppLogger.info(
      'Building sectors list with valid heatmap data',
      tag: 'SectorDetailsCard',
    );
    return _buildSectorsList(context);
  }

  Widget _buildSectorsList(BuildContext context) {
    final sectors = widget.heatmap!.sectors;

    AppLogger.info(
      'Building sectors list with ${sectors.length} sectors',
      tag: 'SectorDetailsCard',
    );

    // Log each sector's raw data
    for (var i = 0; i < sectors.length; i++) {
      final sector = sectors[i];
      AppLogger.debug(
        'Sector ${i + 1}: ${sector.sectorName} - '
        'totalValue: ${sector.totalValue}, '
        'weightage: ${sector.weightage}, '
        'stocks count: ${sector.stocks.length}',
        tag: 'SectorDetailsCard',
      );

      // Log individual stock data in this sector
      for (var j = 0; j < sector.stocks.length && j < 3; j++) {
        // Log first 3 stocks
        final stock = sector.stocks[j];
        AppLogger.debug(
          'Stock ${j + 1} in ${sector.sectorName}: ${stock.symbol} - '
          'lastPrice: ${stock.lastPrice}, '
          'marketValue: ${stock.marketValue}, '
          'quantity: ${stock.quantity}, '
          'avgPrice: ${stock.avgPrice}, '
          'changeAmount: ${stock.changeAmount}, '
          'changePercent: ${stock.changePercent}',
          tag: 'SectorDetailsCard',
        );
      }
    }

    // Calculate total portfolio value using improved logic
    final totalValue = sectors.fold(0.0, (sum, sector) {
      AppLogger.debug(
        'Processing sector ${sector.sectorName} with totalValue: ${sector.totalValue}',
        tag: 'SectorDetailsCard',
      );

      // Try sector.totalValue first
      if (sector.totalValue > 0) {
        AppLogger.debug(
          'Using sector.totalValue: ${sector.totalValue} for ${sector.sectorName}',
          tag: 'SectorDetailsCard',
        );
        return sum + sector.totalValue;
      }

      // Fallback calculation
      final sectorValue = sector.stocks.fold(0.0, (sectorSum, stock) {
        var stockValue = 0.0;

        if (stock.marketValue != null && stock.marketValue! > 0) {
          stockValue = stock.marketValue!;
          AppLogger.debug(
            'Using marketValue $stockValue for ${stock.symbol}',
            tag: 'SectorDetailsCard',
          );
        } else if (stock.quantity != null &&
            stock.quantity! > 0 &&
            stock.lastPrice > 0) {
          stockValue = stock.quantity! * stock.lastPrice;
          AppLogger.debug(
            'Calculated value $stockValue (qty: ${stock.quantity} × price: ${stock.lastPrice}) for ${stock.symbol}',
            tag: 'SectorDetailsCard',
          );
        } else {
          AppLogger.warning(
            'No valid value calculation for ${stock.symbol} - '
            'marketValue: ${stock.marketValue}, quantity: ${stock.quantity}, lastPrice: ${stock.lastPrice}',
            tag: 'SectorDetailsCard',
          );
        }

        return sectorSum + stockValue;
      });

      AppLogger.debug(
        'Calculated fallback sectorValue: $sectorValue for ${sector.sectorName}',
        tag: 'SectorDetailsCard',
      );

      return sum + sectorValue;
    });

    AppLogger.info(
      'Total portfolio value calculated: $totalValue',
      tag: 'SectorDetailsCard',
    );

    // Create sector info with calculations
    final sectorInfos = sectors.map((sector) {
      AppLogger.debug(
        'Creating SectorInfo for ${sector.sectorName}',
        tag: 'SectorDetailsCard',
      );

      // Use the same calculation logic
      final sectorValue = sector.totalValue > 0
          ? sector.totalValue
          : sector.stocks.fold(0.0, (sum, stock) {
              var stockValue = 0.0;
              if (stock.marketValue != null && stock.marketValue! > 0) {
                stockValue = stock.marketValue!;
              } else if (stock.quantity != null && stock.quantity! > 0) {
                stockValue = stock.quantity! * stock.lastPrice;
              }
              return sum + stockValue;
            });

      AppLogger.debug(
        'Sector ${sector.sectorName} calculated value: $sectorValue',
        tag: 'SectorDetailsCard',
      );

      // Use sector.weightage if available, otherwise calculate
      final weightage = sector.weightage > 0
          ? sector.weightage
          : (totalValue > 0 ? (sectorValue / totalValue) * 100 : 0);

      AppLogger.debug(
        'Sector ${sector.sectorName} weightage: $weightage% '
        '(raw: ${sector.weightage}, calculated: ${totalValue > 0 ? (sectorValue / totalValue) * 100 : 0})',
        tag: 'SectorDetailsCard',
      );

      final avgPerformance = _calculateSectorPerformance(sector);

      AppLogger.debug(
        'Sector ${sector.sectorName} average performance: $avgPerformance%',
        tag: 'SectorDetailsCard',
      );

      return SectorInfo(
        sector: sector,
        totalValue: sectorValue,
        weightage: weightage,
        performance: avgPerformance,
      );
    }).toList();

    // Sort by value (rank)
    sectorInfos.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    return Column(
      children: List.generate(sectorInfos.length, (index) {
        final sectorInfo = sectorInfos[index];
        final rank = index + 1;
        return _buildSectorTile(context, sectorInfo, rank);
      }),
    );
  }

  Widget _buildSectorTile(
    BuildContext context,
    SectorInfo sectorInfo,
    int rank,
  ) {
    final isExpanded = _expandedSectors.contains(sectorInfo.sector.sectorName);
    final performanceColor = _getPerformanceColor(sectorInfo.performance);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSectors.remove(sectorInfo.sector.sectorName);
                } else {
                  _expandedSectors.add(sectorInfo.sector.sectorName);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Sector info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sectorInfo.sector.sectorName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: performanceColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: performanceColor),
                              ),
                              child: Text(
                                '${sectorInfo.performance >= 0 ? '+' : ''}${sectorInfo.performance.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: performanceColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${sectorInfo.sector.stocks.length} stocks',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Value and weightage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_formatValue(sectorInfo.totalValue)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sectorInfo.weightage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded) _buildStocksList(context, sectorInfo),
        ],
      ),
    );
  }

  Widget _buildStocksList(BuildContext context, SectorInfo sectorInfo) {
    final stocks = sectorInfo.sector.stocks;

    AppLogger.info(
      'Building stocks list for sector ${sectorInfo.sector.sectorName} '
      'with ${stocks.length} stocks',
      tag: 'SectorDetailsCard',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: stocks
              .map(
                (stock) =>
                    _buildStockCard(context, stock, sectorInfo.totalValue),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStockCard(
    BuildContext context,
    Stock stock,
    double sectorTotalValue,
  ) {
    // Log detailed stock information for debugging
    AppLogger.debug(
      'Building stock card for ${stock.symbol}',
      tag: 'SectorDetailsCard',
    );

    AppLogger.debug(
      'Stock data - Symbol: ${stock.symbol}, '
      'Company: ${stock.companyName}, '
      'LastPrice: ${stock.lastPrice}, '
      'MarketValue: ${stock.marketValue}, '
      'Quantity: ${stock.quantity}, '
      'AvgPrice: ${stock.avgPrice}, '
      'ChangeAmount: ${stock.changeAmount}, '
      'ChangePercent: ${stock.changePercent}',
      tag: 'SectorDetailsCard',
    );

    // Check for missing critical values
    if (stock.marketValue == null || stock.marketValue == 0) {
      AppLogger.warning(
        'Missing marketValue for ${stock.symbol} - using calculated value',
        tag: 'SectorDetailsCard',
      );
    }

    if (stock.quantity == null || stock.quantity == 0) {
      AppLogger.warning(
        'Missing quantity for ${stock.symbol}',
        tag: 'SectorDetailsCard',
      );
    }

    if (stock.companyName.isEmpty) {
      AppLogger.warning(
        'Missing company name for ${stock.symbol}',
        tag: 'SectorDetailsCard',
      );
    }

    // Use weight directly from backend
    final stockWeight = stock.weight ?? 0.0;

    AppLogger.debug(
      'Stock weight for ${stock.symbol}: ${stockWeight.toStringAsFixed(2)}% '
      '(directly from backend: ${stock.weight != null ? stock.weight!.toStringAsFixed(2) : "null"})',
      tag: 'SectorDetailsCard',
    );

    // Use market value directly from backend
    final currentValue = stock.marketValue ?? 0.0;

    AppLogger.debug(
      'Using currentValue: ${currentValue.toStringAsFixed(2)} for ${stock.symbol}',
      tag: 'SectorDetailsCard',
    );

    return InvestmentCard(
      data: InvestmentData(
        symbol: stock.symbol,
        name: stock.companyName.isNotEmpty ? stock.companyName : stock.symbol,
        currentValue: currentValue, // Direct from backend
        investedAmount: 0, // Stock entity doesn't have investedAmount
        avgPrice: stock.avgPrice ?? 0, // Direct from backend with null handling
        quantity: stock.quantity?.toInt() ?? 0, // Direct from backend
        currentPrice: stock.lastPrice, // Direct from backend
        changeValue: stock.changeAmount, // Direct from backend
        changePercent: stock.changePercent, // Direct from backend
        isPositive: stock.changeAmount >= 0, // Based on backend change amount
      ),
      config: InvestmentCardConfig(
        trailingWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              '${stockWeight.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹${currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      style: InvestmentCardStyle.compact, // Use compact style
      displayOptions: InvestmentDisplayOptions
          .sectorStock, // Use clean sector stock display
    );
  }

  double _calculateSectorPerformance(Sector sector) {
    if (sector.stocks.isEmpty) return 0.0;

    final totalPerformance = sector.stocks.fold(
      0.0,
      (sum, stock) => sum + stock.changePercent,
    );
    return totalPerformance / sector.stocks.length;
  }

  Color _getPerformanceColor(double changePercent) {
    if (changePercent > 0) {
      return Colors.green.shade600;
    } else if (changePercent < 0) {
      return Colors.red.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  String _formatValue(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class SectorInfo {
  SectorInfo({
    required this.sector,
    required this.totalValue,
    required this.weightage,
    required this.performance,
  });
  final Sector sector;
  final double totalValue;
  final double weightage;
  final double performance;
}
