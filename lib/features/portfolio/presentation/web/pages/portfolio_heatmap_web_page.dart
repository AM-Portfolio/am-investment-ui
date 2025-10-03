import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/portfolio_providers.dart';
import '../../../../../shared/widgets/selectors/selectors.dart';
import '../../../../../shared/widgets/heatmap/configurable_heatmap_widget.dart';
import '../../../../../shared/widgets/heatmap/heatmap_config.dart';
import '../../../../../shared/models/heatmap.dart';

/// Web-specific portfolio heatmap page with market visualization
class PortfolioHeatmapWebPage extends ConsumerStatefulWidget {
  final String userId;
  final String portfolioId;
  final String? portfolioName;

  const PortfolioHeatmapWebPage({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.portfolioName,
  });

  @override
  ConsumerState<PortfolioHeatmapWebPage> createState() =>
      _PortfolioHeatmapWebPageState();
}

class _PortfolioHeatmapWebPageState
    extends ConsumerState<PortfolioHeatmapWebPage> {
  TimeFrame _selectedTimeframe = TimeFrame.oneDay;
  MetricType _selectedMetric = MetricType.changePercent;
  SectorType _selectedSector = SectorType.all;
  MarketCapType _selectedMarketCap = MarketCapType.all;

  @override
  Widget build(BuildContext context) {
    final holdingsAsync = ref.watch(
      portfolioHoldingsProvider(widget.portfolioId),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConfigurableHeatmapWidget.web(
          data: holdingsAsync.when(
            data: (holdings) => _convertHoldingsToHeatmapData(holdings),
            loading: () => null,
            error: (error, stack) => null,
          ),
          isLoading: holdingsAsync.isLoading,
          error: holdingsAsync.hasError ? holdingsAsync.error.toString() : null,
          title: widget.portfolioName != null 
                 ? '${widget.portfolioName} Heatmap' 
                 : 'Portfolio Heatmap',
          onSelectorsChanged: ({timeFrame, metric, sector, marketCap}) {
            setState(() {
              if (timeFrame != null) _selectedTimeframe = timeFrame;
              if (metric != null) _selectedMetric = metric;
              if (sector != null) _selectedSector = sector;
              if (marketCap != null) _selectedMarketCap = marketCap;
            });
          },
          initialTimeFrame: _selectedTimeframe,
          initialMetric: _selectedMetric,
          initialSector: _selectedSector,
          initialMarketCap: _selectedMarketCap,
          onTilePressed: () {
            // Handle tile press - could navigate to holding details
                _selectedMetric = MetricType.changePercent;
                _selectedSector = SectorType.all;
                _selectedMarketCap = MarketCapType.all;
              });
            },
          ),

          // Main Heatmap Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: holdingsAsync.when(
                data: (holdings) => _buildHeatmapContent(context, holdings),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorContent(
                  context,
                  'Failed to load heatmap data',
                  error.toString(),
                  () => ref.invalidate(
                    portfolioHoldingsProvider(widget.portfolioId),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapContent(BuildContext context, dynamic holdings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.grid_view,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Portfolio Heatmap - $_selectedMetric ($_selectedTimeframe)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildLegend(context),
              ],
            ),
            const SizedBox(height: 24),

            // Heatmap Visualization
            Expanded(child: _buildHeatmapVisualization(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        Text(
          'Legend:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        _buildLegendItem(context, 'High', Colors.green),
        const SizedBox(width: 8),
        _buildLegendItem(context, 'Medium', Colors.yellow),
        const SizedBox(width: 8),
        _buildLegendItem(context, 'Low', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildHeatmapVisualization(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Interactive Portfolio Heatmap',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Visualizing $_selectedMetric over $_selectedTimeframe',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Heatmap visualization will be implemented here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sample Grid Layout (placeholder)
            _buildSampleHeatmapGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleHeatmapGrid(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          final colors = [Colors.green, Colors.yellow, Colors.red, Colors.blue];
          final color = colors[index % colors.length];

          return Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
