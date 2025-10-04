import 'package:flutter_bloc/flutter_bloc.dart';

import 'portfolio_heatmap_state.dart';
import 'portfolio_analytics_cubit.dart';
import 'portfolio_analytics_state.dart';
import '../../../../shared/widgets/selectors/selectors.dart';
import '../../../../shared/models/heatmap/heatmap_ui_data.dart';
import '../../../../shared/models/heatmap/heatmap_tile_data.dart';
import '../../../../shared/utils/sector_heatmap_converter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/app_logic/domain/entities/heatmap/heatmap_data_entity.dart';

/// Portfolio Heatmap Cubit
class PortfolioHeatmapCubit extends Cubit<PortfolioHeatmapState> {
  final PortfolioAnalyticsCubit? _analyticsCubit;

  PortfolioHeatmapCubit([this._analyticsCubit]) : super(PortfolioHeatmapInitial()) {
    AppLogger.info(
      'PortfolioHeatmapCubit initialized',
      tag: 'PortfolioHeatmapCubit',
    );
    AppLogger.stateChange(
      'null',
      'PortfolioHeatmapInitial',
      tag: 'PortfolioHeatmapCubit',
    );
  }

  /// Load heatmap data for portfolio
  Future<void> loadHeatmapData({
    required String portfolioId,
    TimeFrame timeFrame = TimeFrame.oneDay,
    MetricType metric = MetricType.marketValue,
    SectorType sector = SectorType.all,
    MarketCapType marketCap = MarketCapType.all,
    PortfolioAnalyticsCubit? analyticsCubit,
  }) async {
    AppLogger.methodEntry(
      'loadHeatmapData',
      tag: 'PortfolioHeatmapCubit',
      params: {
        'portfolioId': portfolioId,
        'timeFrame': timeFrame.name,
        'metric': metric.name,
        'sector': sector.name,
        'marketCap': marketCap.name,
      },
    );

    try {
      AppLogger.stateChange(
        state.runtimeType.toString(),
        'PortfolioHeatmapLoading',
        tag: 'PortfolioHeatmapCubit',
      );

      emit(
        const PortfolioHeatmapLoading(message: 'Loading portfolio heatmap...'),
      );

      AppLogger.info(
        'Starting heatmap data fetch',
        tag: 'PortfolioHeatmapCubit',
      );

      // Get analytics data from the analytics cubit or passed parameter
      final usedAnalyticsCubit = analyticsCubit ?? _analyticsCubit;
      
      HeatmapData heatmapData;
      
      if (usedAnalyticsCubit != null) {
        final analyticsState = usedAnalyticsCubit.state;
        
        if (analyticsState is PortfolioAnalyticsLoaded && analyticsState.heatmap != null) {
          AppLogger.info(
            'Using real analytics data from cubit',
            tag: 'PortfolioHeatmapCubit',
          );
          
          // Convert real analytics data to heatmap data
          heatmapData = SectorHeatmapConverter.convertToHeatmapData(
            heatmap: analyticsState.heatmap,
            showSubCards: true,
            title: 'Portfolio Heatmap',
            subtitle: 'Sector Performance Analysis',
          );
          
          AppLogger.info(
            'Converted analytics data to heatmap: ${heatmapData.tiles.length} sectors found',
            tag: 'PortfolioHeatmapCubit',
          );
        } else {
          AppLogger.warning(
            'Analytics data not loaded or no heatmap data available, using fallback',
            tag: 'PortfolioHeatmapCubit',
          );
          heatmapData = _createFallbackHeatmapData(portfolioId);
        }
      } else {
        AppLogger.warning(
          'No analytics cubit available, using fallback data',
          tag: 'PortfolioHeatmapCubit',
        );
        heatmapData = _createFallbackHeatmapData(portfolioId);
      }

      AppLogger.info(
        'Heatmap data created successfully',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.debug('Heatmap data details: ${heatmapData.tiles.length} tiles', tag: 'PortfolioHeatmapCubit');

      AppLogger.stateChange(
        'PortfolioHeatmapLoading',
        'PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );

      emit(
        PortfolioHeatmapLoaded(
          heatmapData: heatmapData,
          portfolioId: portfolioId,
          timeFrame: timeFrame,
          metric: metric,
          sector: sector,
          marketCap: marketCap,
          lastUpdated: DateTime.now(),
        ),
      );

      AppLogger.methodExit(
        'loadHeatmapData',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load portfolio heatmap data',
        tag: 'PortfolioHeatmapCubit',
        error: e,
        stackTrace: stackTrace,
      );

      AppLogger.stateChange(
        state.runtimeType.toString(),
        'PortfolioHeatmapError',
        tag: 'PortfolioHeatmapCubit',
      );

      emit(PortfolioHeatmapError(message: 'Failed to load portfolio heatmap'));

      AppLogger.methodExit(
        'loadHeatmapData',
        tag: 'PortfolioHeatmapCubit',
        result: 'error',
      );
    }
  }

  Future<void> updateTimeFrame(TimeFrame timeFrame) async {
    AppLogger.methodEntry(
      'updateTimeFrame',
      tag: 'PortfolioHeatmapCubit',
      params: {
        'timeFrame': timeFrame.name,
        'currentState': state.runtimeType.toString(),
      },
    );

    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      AppLogger.info(
        'Updating timeframe from ${currentState.timeFrame.name} to ${timeFrame.name}',
        tag: 'PortfolioHeatmapCubit',
      );

      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: timeFrame,
        metric: currentState.metric,
        sector: currentState.sector ?? SectorType.all,
        marketCap: currentState.marketCap ?? MarketCapType.all,
        analyticsCubit: _analyticsCubit,
      );

      AppLogger.methodExit(
        'updateTimeFrame',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } else {
      AppLogger.warning(
        'Cannot update timeframe - current state is not PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.methodExit(
        'updateTimeFrame',
        tag: 'PortfolioHeatmapCubit',
        result: 'invalid_state',
      );
    }
  }

  Future<void> updateMetric(MetricType metric) async {
    AppLogger.methodEntry(
      'updateMetric',
      tag: 'PortfolioHeatmapCubit',
      params: {
        'metric': metric.name,
        'currentState': state.runtimeType.toString(),
      },
    );

    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      AppLogger.info(
        'Updating metric from ${currentState.metric.name} to ${metric.name}',
        tag: 'PortfolioHeatmapCubit',
      );

      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: metric,
        sector: currentState.sector ?? SectorType.all,
        marketCap: currentState.marketCap ?? MarketCapType.all,
        analyticsCubit: _analyticsCubit,
      );

      AppLogger.methodExit(
        'updateMetric',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } else {
      AppLogger.warning(
        'Cannot update metric - current state is not PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.methodExit(
        'updateMetric',
        tag: 'PortfolioHeatmapCubit',
        result: 'invalid_state',
      );
    }
  }

  Future<void> updateSector(SectorType sector) async {
    AppLogger.methodEntry(
      'updateSector',
      tag: 'PortfolioHeatmapCubit',
      params: {
        'sector': sector.name,
        'currentState': state.runtimeType.toString(),
      },
    );

    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      final currentSector = currentState.sector?.name ?? 'null';
      AppLogger.info(
        'Updating sector from $currentSector to ${sector.name}',
        tag: 'PortfolioHeatmapCubit',
      );

      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: sector,
        marketCap: currentState.marketCap ?? MarketCapType.all,
        analyticsCubit: _analyticsCubit,
      );

      AppLogger.methodExit(
        'updateSector',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } else {
      AppLogger.warning(
        'Cannot update sector - current state is not PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.methodExit(
        'updateSector',
        tag: 'PortfolioHeatmapCubit',
        result: 'invalid_state',
      );
    }
  }

  Future<void> updateMarketCap(MarketCapType marketCap) async {
    AppLogger.methodEntry(
      'updateMarketCap',
      tag: 'PortfolioHeatmapCubit',
      params: {
        'marketCap': marketCap.name,
        'currentState': state.runtimeType.toString(),
      },
    );

    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      final currentMarketCap = currentState.marketCap?.name ?? 'null';
      AppLogger.info(
        'Updating market cap from $currentMarketCap to ${marketCap.name}',
        tag: 'PortfolioHeatmapCubit',
      );

      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: currentState.sector ?? SectorType.all,
        marketCap: marketCap,
        analyticsCubit: _analyticsCubit,
      );

      AppLogger.methodExit(
        'updateMarketCap',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } else {
      AppLogger.warning(
        'Cannot update market cap - current state is not PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.methodExit(
        'updateMarketCap',
        tag: 'PortfolioHeatmapCubit',
        result: 'invalid_state',
      );
    }
  }

  Future<void> refresh() async {
    AppLogger.methodEntry(
      'refresh',
      tag: 'PortfolioHeatmapCubit',
      params: {'currentState': state.runtimeType.toString()},
    );

    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      AppLogger.info('Refreshing heatmap data', tag: 'PortfolioHeatmapCubit');

      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: currentState.sector ?? SectorType.all,
        marketCap: currentState.marketCap ?? MarketCapType.all,
        analyticsCubit: _analyticsCubit,
      );

      AppLogger.methodExit(
        'refresh',
        tag: 'PortfolioHeatmapCubit',
        result: 'success',
      );
    } else {
      AppLogger.warning(
        'Cannot refresh - current state is not PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.methodExit(
        'refresh',
        tag: 'PortfolioHeatmapCubit',
        result: 'invalid_state',
      );
    }
  }

  /// Create fallback heatmap data when real data is not available
  HeatmapData _createFallbackHeatmapData(String portfolioId) {
    AppLogger.info(
      'Creating fallback heatmap data',
      tag: 'PortfolioHeatmapCubit',
    );
    
    return HeatmapData(
      id: 'portfolio-heatmap-fallback',
      title: 'Portfolio Heatmap',
      subtitle: 'Loading real data...',
      tiles: [
        HeatmapTileData(
          id: 'loading',
          name: 'loading',
          displayName: 'Loading...',
          weightage: 100.0,
          performance: 0.0,
          value: 0.0,
          metadata: {'status': 'loading'},
        ),
      ],
      metadata: HeatmapMetadata(
        lastUpdated: DateTime.now(),
        dataSource: 'fallback',
        additionalInfo: {'portfolioId': portfolioId},
      ),
      configuration: const HeatmapConfiguration(),
    );
  }
}
