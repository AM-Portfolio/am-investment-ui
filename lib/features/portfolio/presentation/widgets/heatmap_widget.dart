import 'package:flutter/material.dart';
import '../../internal/domain/entities/portfolio_analytics.dart';

/// Widget displaying portfolio heatmap visualization
/// Shows sector performance with color-coded rectangles representing stocks
class HeatmapWidget extends StatelessWidget {
  final Heatmap? heatmap;
  final bool isLoading;
  final String? error;

  const HeatmapWidget({
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
                  Icons.grid_view,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Portfolio Heatmap',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 350, child: _buildContent(context)),
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
              'Failed to load heatmap data',
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
              'No heatmap data available',
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
        Expanded(child: _buildHeatmapGrid(context)),
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
              _buildLegendItem(context, 'Negative', Colors.red.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Neutral', Colors.grey.shade300),
              const SizedBox(width: 8),
              _buildLegendItem(context, 'Positive', Colors.green.shade300),
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

  Widget _buildHeatmapGrid(BuildContext context) {
    final sectors = heatmap!.sectors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sectors.map((sector) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    sector.sectorName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSectorStocks(context, sector),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectorStocks(BuildContext context, Sector sector) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: sector.stocks.map((stock) {
        final performanceColor = _getPerformanceColor(stock.changePercent);
        final sizeMultiplier = _getSizeMultiplier(stock.marketValue ?? 1000);

        return Tooltip(
          message:
              '${stock.symbol}\n${stock.companyName}\n${stock.changePercent >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%\n₹${stock.lastPrice.toStringAsFixed(2)}',
          child: Container(
            width: 40 * sizeMultiplier,
            height: 40 * sizeMultiplier,
            decoration: BoxDecoration(
              color: performanceColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                stock.symbol.length > 4
                    ? stock.symbol.substring(0, 4)
                    : stock.symbol,
                style: TextStyle(
                  fontSize: 9 * sizeMultiplier,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(performanceColor),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPerformanceColor(double changePercent) {
    final intensity = (changePercent.abs() / 10).clamp(0.3, 1.0);

    if (changePercent > 0) {
      return Color.lerp(
        Colors.green.shade100,
        Colors.green.shade700,
        intensity,
      )!;
    } else if (changePercent < 0) {
      return Color.lerp(Colors.red.shade100, Colors.red.shade700, intensity)!;
    } else {
      return Colors.grey.shade300;
    }
  }

  double _getSizeMultiplier(double marketValue) {
    // Normalize market value to get size multiplier between 0.8 and 1.4
    if (marketValue > 100000) return 1.4;
    if (marketValue > 50000) return 1.2;
    if (marketValue > 10000) return 1.0;
    return 0.8;
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be dark or light
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
