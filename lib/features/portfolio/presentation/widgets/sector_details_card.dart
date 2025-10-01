import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';

/// Widget displaying detailed sector information with expandable stock lists
/// Shows sector rank, total value, weightage and expandable stock details
class SectorDetailsCard extends StatefulWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  const SectorDetailsCard({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
  });

  @override
  State<SectorDetailsCard> createState() => _SectorDetailsCardState();
}

class _SectorDetailsCardState extends State<SectorDetailsCard> {
  final Set<String> _expandedSectors = <String>{};

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
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
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.error != null) {
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

    return _buildSectorsList(context);
  }

  Widget _buildSectorsList(BuildContext context) {
    final sectors = widget.heatmap!.sectors;

    // Calculate total portfolio value using improved logic
    double totalValue = sectors.fold(0.0, (sum, sector) {
      // Try sector.totalValue first
      if (sector.totalValue > 0) {
        return sum + sector.totalValue;
      }
      // Fallback calculation
      double sectorValue = sector.stocks.fold(0.0, (sectorSum, stock) {
        if (stock.marketValue != null && stock.marketValue! > 0) {
          return sectorSum + stock.marketValue!;
        }
        if (stock.quantity != null && stock.quantity! > 0) {
          return sectorSum + (stock.quantity! * stock.lastPrice);
        }
        return sectorSum;
      });
      return sum + sectorValue;
    });

    // Create sector info with calculations
    List<SectorInfo> sectorInfos = sectors.map((sector) {
      // Use the same calculation logic
      double sectorValue = sector.totalValue > 0
          ? sector.totalValue
          : sector.stocks.fold(0.0, (sum, stock) {
              if (stock.marketValue != null && stock.marketValue! > 0) {
                return sum + stock.marketValue!;
              }
              if (stock.quantity != null && stock.quantity! > 0) {
                return sum + (stock.quantity! * stock.lastPrice);
              }
              return sum;
            });

      // Use sector.weightage if available, otherwise calculate
      double weightage = sector.weightage > 0
          ? sector.weightage
          : (totalValue > 0 ? (sectorValue / totalValue) * 100 : 0);

      double avgPerformance = _calculateSectorPerformance(sector);

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
                  // Rank badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

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
                                color: performanceColor.withOpacity(0.2),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Stock',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Qty',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Weight',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Change',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Stocks list
          ...stocks
              .map(
                (stock) =>
                    _buildStockRow(context, stock, sectorInfo.totalValue),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStockRow(
    BuildContext context,
    Stock stock,
    double sectorTotalValue,
  ) {
    // Use improved calculation for stock value
    final stockValue = stock.marketValue != null && stock.marketValue! > 0
        ? stock.marketValue!
        : (stock.quantity != null && stock.quantity! > 0
              ? stock.quantity! * stock.lastPrice
              : 0.0);

    final stockWeight = sectorTotalValue > 0
        ? (stockValue / sectorTotalValue) * 100
        : 0;
    final changeColor = stock.changePercent >= 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Stock symbol and name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    stock.symbol,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (stock.companyName.isNotEmpty)
                  Flexible(
                    child: Text(
                      stock.companyName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity (placeholder - need to get from actual data)
          Expanded(
            flex: 1,
            child: Text(
              '-', // Replace with actual quantity when available
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Value
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    '₹${_formatValue(stockValue)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '₹${stock.lastPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Weight
          Expanded(
            flex: 1,
            child: Text(
              '${stockWeight.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Change
          Expanded(
            flex: 1,
            child: Text(
              '${stock.changePercent >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSectorPerformance(Sector sector) {
    if (sector.stocks.isEmpty) return 0.0;

    double totalPerformance = sector.stocks.fold(
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
  final Sector sector;
  final double totalValue;
  final double weightage;
  final double performance;

  SectorInfo({
    required this.sector,
    required this.totalValue,
    required this.weightage,
    required this.performance,
  });
}
