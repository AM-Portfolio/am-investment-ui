import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';

/// Widget displaying sector allocation overview with visual heatmap
/// Shows sector performance with color-coded rectangles representing sector weightage
class SectorOverviewCard extends StatelessWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  const SectorOverviewCard({
    super.key,
    this.heatmap,
    this.isLoading = false,
    this.error,
  });

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
                  Icons.pie_chart,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sector Allocation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
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
              'Failed to load sector data',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (heatmap == null || heatmap!.sectors.isEmpty) {
      return Center(
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
              'No sector data available',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildColorLegend(context),
        const SizedBox(height: 16),
        Expanded(child: _buildSectorHeatmap(context)),
      ],
    );
  }

  Widget _buildColorLegend(BuildContext context) {
    return Row(
      children: [
        Text('Performance: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Row(
            children: [
              _buildLegendItem(context, 'Loss', Colors.red.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Neutral', Colors.grey.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Gain', Colors.green.shade300),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSectorHeatmap(BuildContext context) {
    final sectors = heatmap!.sectors;

    // Calculate total portfolio value - try multiple approaches
    double totalValue = sectors.fold(0.0, (sum, sector) {
      // Try sector.totalValue first (this should be provided by the API)
      if (sector.totalValue > 0) {
        return sum + sector.totalValue;
      }
      // Fallback: calculate from stocks if marketValue is available
      double sectorValue = sector.stocks.fold(0.0, (sectorSum, stock) {
        if (stock.marketValue != null && stock.marketValue! > 0) {
          return sectorSum + stock.marketValue!;
        }
        // Another fallback: quantity * lastPrice if available
        if (stock.quantity != null && stock.quantity! > 0) {
          return sectorSum + (stock.quantity! * stock.lastPrice);
        }
        return sectorSum;
      });
      return sum + sectorValue;
    }); // Sort sectors by value for better visualization
    final sortedSectors = List<Sector>.from(sectors)
      ..sort((a, b) {
        double aValue = a.stocks.fold(
          0.0,
          (sum, stock) => sum + (stock.marketValue ?? 0),
        );
        double bValue = b.stocks.fold(
          0.0,
          (sum, stock) => sum + (stock.marketValue ?? 0),
        );
        return bValue.compareTo(aValue);
      });

    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sortedSectors.map((sector) {
          // Use the same calculation logic as totalValue
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

          return _buildSectorTile(context, sector, weightage, avgPerformance);
        }).toList(),
      ),
    );
  }

  Widget _buildSectorTile(
    BuildContext context,
    Sector sector,
    double weightage,
    double performance,
  ) {
    final performanceColor = _getPerformanceColor(performance);
    final size = _getSectorSize(weightage);
    final textColor = _getTextColor(performanceColor);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: performanceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _getSectorDisplayName(sector.sectorName),
                style: TextStyle(
                  fontSize: size.width > 120 ? 12 : 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${weightage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: size.width > 120 ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (size.height > 65)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '${performance >= 0 ? '+' : ''}${performance.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: size.width > 120 ? 10 : 8,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
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
    final intensity = (changePercent.abs() / 5).clamp(0.3, 1.0);

    if (changePercent > 0) {
      return Color.lerp(
        Colors.green.shade100,
        Colors.green.shade600,
        intensity,
      )!;
    } else if (changePercent < 0) {
      return Color.lerp(Colors.red.shade100, Colors.red.shade600, intensity)!;
    } else {
      return Colors.grey.shade300;
    }
  }

  Size _getSectorSize(double weightage) {
    // Size rectangles based on sector weightage
    if (weightage > 20) return const Size(140, 100);
    if (weightage > 15) return const Size(120, 90);
    if (weightage > 10) return const Size(100, 80);
    if (weightage > 5) return const Size(90, 70);
    return const Size(80, 65);
  }

  String _getSectorDisplayName(String sectorName) {
    // Shorten long sector names for better display
    final Map<String, String> sectorAbbreviations = {
      'Information Technology': 'IT',
      'Financial Services': 'Finance',
      'Consumer Durables': 'Consumer Dur.',
      'Consumer Non-Durables': 'Consumer Non-Dur.',
      'Health Technology': 'Health Tech',
      'Electronic Technology': 'Electronic Tech',
      'Technology Services': 'Tech Services',
      'Producer Manufacturing': 'Manufacturing',
      'Process Industries': 'Process Ind.',
      'Transportation': 'Transport',
      'Commercial Services': 'Commercial',
      'Energy Minerals': 'Energy',
      'Non-Energy Minerals': 'Minerals',
    };

    return sectorAbbreviations[sectorName] ??
        (sectorName.length > 12
            ? '${sectorName.substring(0, 12)}...'
            : sectorName);
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
