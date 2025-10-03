import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/investment/investment_heatmap_widget.dart';
import '../../../../../shared/models/investment/investment_types.dart';
import '../../../../../shared/converters/portfolio_analytics_converter.dart';
import '../../../providers/portfolio_providers.dart';
import '../../../../../core/utils/logger.dart';

/// Enhanced portfolio heatmap card that uses the investment pattern
/// for better flexibility and configuration management
class EnhancedPortfolioHeatmapCard extends ConsumerWidget {
  final String portfolioId;
  final String? title;
  final IconData? icon;
  final bool compact;
  final Function(InvestmentInputData)? onTilePressed;
  final Function({
    TimeFrame? timeFrame,
    MetricType? metric,
    SectorType? sector,
    MarketCapType? marketCap,
  })?
  onFiltersChanged;

  const EnhancedPortfolioHeatmapCard({
    super.key,
    required this.portfolioId,
    this.title,
    this.icon,
    this.compact = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug(
      'Building EnhancedPortfolioHeatmapCard for portfolioId: $portfolioId',
      tag: 'EnhancedPortfolioHeatmapCard',
    );

    // Watch the portfolio analytics provider
    final analyticsAsync = ref.watch(portfolioAnalyticsProvider(portfolioId));

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics == null) {
          return _buildEmptyState(context);
        }

        // Convert portfolio analytics to investment input data
        final inputData = PortfolioAnalyticsConverter.convertToInvestmentData(
          analytics,
          portfolioId: portfolioId,
        );

        return InvestmentHeatmapWidget(
          filterType: InvestmentFilterType.portfolio,
          inputData: inputData,
          isLoading: false,
          compact: compact,
          onTilePressed: onTilePressed,
          onFiltersChanged: onFiltersChanged != null
              ? ({filterType, timeFrame, metric, sector, marketCap}) {
                  onFiltersChanged?.call(
                    timeFrame: timeFrame,
                    metric: metric,
                    sector: sector,
                    marketCap: marketCap,
                  );
                }
              : null,
        );
      },
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) {
        AppLogger.error(
          'Failed to load portfolio analytics: $portfolioId',
          tag: 'EnhancedPortfolioHeatmapCard',
          error: error,
          stackTrace: stackTrace,
        );
        return _buildErrorState(context, error.toString());
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: const [],
      isLoading: true,
      compact: compact,
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: const [],
      error: error,
      compact: compact,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return InvestmentHeatmapWidget(
      filterType: InvestmentFilterType.portfolio,
      inputData: const [],
      compact: compact,
    );
  }
}

/// Factory methods for different portfolio heatmap use cases
extension PortfolioHeatmapFactory on EnhancedPortfolioHeatmapCard {
  /// Create a mobile-optimized portfolio heatmap
  static EnhancedPortfolioHeatmapCard mobile({
    Key? key,
    required String portfolioId,
    String? title,
    Function(InvestmentInputData)? onTilePressed,
  }) {
    return EnhancedPortfolioHeatmapCard(
      key: key,
      portfolioId: portfolioId,
      title: title,
      compact: true,
      onTilePressed: onTilePressed,
    );
  }

  /// Create a web-optimized portfolio heatmap
  static EnhancedPortfolioHeatmapCard web({
    Key? key,
    required String portfolioId,
    String? title,
    Function(InvestmentInputData)? onTilePressed,
    Function({
      TimeFrame? timeFrame,
      MetricType? metric,
      SectorType? sector,
      MarketCapType? marketCap,
    })?
    onFiltersChanged,
  }) {
    return EnhancedPortfolioHeatmapCard(
      key: key,
      portfolioId: portfolioId,
      title: title,
      compact: false,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
    );
  }

  /// Create a dashboard widget portfolio heatmap
  static EnhancedPortfolioHeatmapCard dashboard({
    Key? key,
    required String portfolioId,
    String? title,
  }) {
    return EnhancedPortfolioHeatmapCard(
      key: key,
      portfolioId: portfolioId,
      title: title,
      compact: true,
    );
  }
}
