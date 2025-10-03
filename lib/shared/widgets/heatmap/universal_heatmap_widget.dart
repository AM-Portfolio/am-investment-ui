import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/cubits/heatmap/heatmap_display_cubit.dart';
import '../../widgets/heatmap/heatmap_template_card.dart';
import '../../widgets/heatmap/configurable_heatmap_widget.dart';
import '../../widgets/selectors/selectors.dart';

/// Universal heatmap widget that integrates with any investment type using cubit state management
/// This is the main widget that should be used for displaying heatmaps across the app
class UniversalHeatmapWidget extends StatelessWidget {
  /// Investment type (portfolio, index, mutual funds, ETF)
  final InvestmentType investmentType;

  /// Raw data to be converted to heatmap format
  final Map<String, dynamic> rawData;

  /// Optional configuration overrides
  final HeatmapDisplayConfig? config;

  /// Optional initial filters
  final HeatmapFilters? initialFilters;

  /// Callback when a tile is pressed
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;

  /// Callback when filters change
  final Function(HeatmapFilters filters)? onFiltersChanged;

  /// Whether to show selectors (can override config)
  final bool? showSelectors;

  /// Custom title (can override config)
  final String? title;

  /// Whether to use compact mode (can override config)
  final bool? compactMode;

  const UniversalHeatmapWidget({
    super.key,
    required this.investmentType,
    required this.rawData,
    this.config,
    this.initialFilters,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HeatmapDisplayCubit(),
      child: _UniversalHeatmapContent(
        investmentType: investmentType,
        rawData: rawData,
        config: config,
        initialFilters: initialFilters,
        onTilePressed: onTilePressed,
        onFiltersChanged: onFiltersChanged,
        showSelectors: showSelectors,
        title: title,
        compactMode: compactMode,
      ),
    );
  }
}

class _UniversalHeatmapContent extends StatefulWidget {
  final InvestmentType investmentType;
  final Map<String, dynamic> rawData;
  final HeatmapDisplayConfig? config;
  final HeatmapFilters? initialFilters;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;
  final bool? showSelectors;
  final String? title;
  final bool? compactMode;

  const _UniversalHeatmapContent({
    required this.investmentType,
    required this.rawData,
    this.config,
    this.initialFilters,
    this.onTilePressed,
    this.onFiltersChanged,
    this.showSelectors,
    this.title,
    this.compactMode,
  });

  @override
  State<_UniversalHeatmapContent> createState() =>
      _UniversalHeatmapContentState();
}

class _UniversalHeatmapContentState extends State<_UniversalHeatmapContent> {
  @override
  void initState() {
    super.initState();
    _initializeHeatmap();
  }

  void _initializeHeatmap() {
    final cubit = context.read<HeatmapDisplayCubit>();
    final effectiveConfig = _getEffectiveConfig();

    cubit.initialize(
      config: effectiveConfig,
      rawData: widget.rawData,
      initialFilters: widget.initialFilters,
    );
  }

  HeatmapDisplayConfig _getEffectiveConfig() {
    HeatmapDisplayConfig baseConfig;

    // Create base config based on investment type
    switch (widget.investmentType) {
      case InvestmentType.portfolio:
        baseConfig = HeatmapDisplayConfig.portfolio(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.indexFund:
        baseConfig = HeatmapDisplayConfig.index(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.mutualFunds:
        baseConfig = HeatmapDisplayConfig.mutualFunds(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
      case InvestmentType.etf:
        baseConfig = HeatmapDisplayConfig.etf(
          title: widget.title,
          compactMode: widget.compactMode ?? false,
        );
        break;
    }

    // Apply overrides from widget parameters
    if (widget.config != null) {
      baseConfig = baseConfig.copyWith(
        showSelectors: widget.showSelectors ?? widget.config!.showSelectors,
        title: widget.title ?? widget.config!.title,
        compactMode: widget.compactMode ?? widget.config!.compactMode,
      );
    } else if (widget.showSelectors != null) {
      baseConfig = baseConfig.copyWith(showSelectors: widget.showSelectors!);
    }

    return baseConfig;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HeatmapDisplayCubit, HeatmapDisplayState>(
      listener: (context, state) {
        if (state is HeatmapDisplayLoaded) {
          widget.onFiltersChanged?.call(state.filters);
        }
      },
      builder: (context, state) {
        if (state is HeatmapDisplayInitial) {
          return const Center(child: Text('Initializing heatmap...'));
        }

        if (state is HeatmapDisplayLoading) {
          return _buildLoadingState();
        }

        if (state is HeatmapDisplayError) {
          return _buildErrorState(state);
        }

        if (state is HeatmapDisplayLoaded) {
          return _buildLoadedState(state);
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildLoadingState() {
    final config = _getEffectiveConfig();

    if (config.compactMode) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading heatmap...'),
          ],
        ),
      );
    }

    return ConfigurableHeatmapWidget(
      isLoading: true,
      title: config.title,
      showSelectors: config.showSelectors,
      compact: config.compactMode,
    );
  }

  Widget _buildErrorState(HeatmapDisplayError state) {
    final config = _getEffectiveConfig();

    return ConfigurableHeatmapWidget(
      error: state.message,
      title: config.title,
      showSelectors: config.showSelectors,
      compact: config.compactMode,
    );
  }

  Widget _buildLoadedState(HeatmapDisplayLoaded state) {
    return ConfigurableHeatmapWidget(
      data: state.data,
      title: state.config.title,
      showSelectors: state.config.showSelectors,
      compact: state.config.compactMode,
      initialTimeFrame: state.filters.timeFrame,
      initialMetric: state.filters.metric,
      initialSector: state.filters.sector,
      initialMarketCap: state.filters.marketCap,
      onTilePressed: () {
        // Handle tile press - you could pass tile-specific data here
        widget.onTilePressed?.call('tile-id', null);
      },
      onSelectorsChanged:
          ({
            TimeFrame? timeFrame,
            MetricType? metric,
            SectorType? sector,
            MarketCapType? marketCap,
          }) {
            final cubit = context.read<HeatmapDisplayCubit>();

            if (timeFrame != null && timeFrame != state.filters.timeFrame) {
              cubit.updateTimeFrame(timeFrame);
            }
            if (metric != null && metric != state.filters.metric) {
              cubit.updateMetric(metric);
            }
            if (sector != null && sector != state.filters.sector) {
              cubit.updateSector(sector);
            }
            if (marketCap != null && marketCap != state.filters.marketCap) {
              cubit.updateMarketCap(marketCap);
            }
          },
      customTileBuilder: _buildCustomTile,
    );
  }

  Widget? _buildCustomTile(dynamic tile) {
    // You can customize tile appearance based on investment type
    // Return null to use default tile builder
    return null;
  }
}

/// Convenience widgets for specific investment types

/// Portfolio-specific heatmap widget
class PortfolioHeatmapWidget extends StatelessWidget {
  final Map<String, dynamic> portfolioData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  const PortfolioHeatmapWidget({
    super.key,
    required this.portfolioData,
    this.title = 'Portfolio Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalHeatmapWidget(
      investmentType: InvestmentType.portfolio,
      rawData: portfolioData,
      title: title,
      compactMode: compactMode,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
    );
  }
}

/// Index-specific heatmap widget
class IndexHeatmapWidget extends StatelessWidget {
  final Map<String, dynamic> indexData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  const IndexHeatmapWidget({
    super.key,
    required this.indexData,
    this.title = 'Index Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalHeatmapWidget(
      investmentType: InvestmentType.index,
      rawData: indexData,
      title: title,
      compactMode: compactMode,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
    );
  }
}

/// Mutual funds-specific heatmap widget
class MutualFundsHeatmapWidget extends StatelessWidget {
  final Map<String, dynamic> fundsData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  const MutualFundsHeatmapWidget({
    super.key,
    required this.fundsData,
    this.title = 'Mutual Funds Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalHeatmapWidget(
      investmentType: InvestmentType.mutualFunds,
      rawData: fundsData,
      title: title,
      compactMode: compactMode,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
    );
  }
}

/// ETF-specific heatmap widget
class ETFHeatmapWidget extends StatelessWidget {
  final Map<String, dynamic> etfData;
  final String? title;
  final bool compactMode;
  final Function(String tileId, Map<String, dynamic>? metadata)? onTilePressed;
  final Function(HeatmapFilters filters)? onFiltersChanged;

  const ETFHeatmapWidget({
    super.key,
    required this.etfData,
    this.title = 'ETF Heatmap',
    this.compactMode = false,
    this.onTilePressed,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalHeatmapWidget(
      investmentType: InvestmentType.etf,
      rawData: etfData,
      title: title,
      compactMode: compactMode,
      onTilePressed: onTilePressed,
      onFiltersChanged: onFiltersChanged,
    );
  }
}
