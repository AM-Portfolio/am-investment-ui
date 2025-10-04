import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'portfolio_heatmap_state.dart';
import '../../../../shared/widgets/selectors/selectors.dart';
import '../../../../shared/models/heatmap/heatmap_ui_data.dart';
import '../../../../shared/models/heatmap/heatmap_tile_data.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/app_logic/domain/entities/heatmap/heatmap_data_entity.dart';

/// Portfolio Heatmap Cubit
class PortfolioHeatmapCubit extends Cubit<PortfolioHeatmapState> {
  PortfolioHeatmapCubit() : super(PortfolioHeatmapInitial()) {
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
      // Simulating API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.debug(
        'Heatmap data fetch delay completed',
        tag: 'PortfolioHeatmapCubit',
      );

      AppLogger.debug(
        'Creating sample heatmap data',
        tag: 'PortfolioHeatmapCubit',
      );
      final sampleData = HeatmapData(
        id: 'portfolio-heatmap',
        title: 'Portfolio Heatmap',
        subtitle: 'Sector Performance Analysis',
        tiles: [
          HeatmapTileData(
            id: 'technology',
            name: 'technology',
            displayName: 'Technology',
            weightage: 36.0,
            performance: 3.45,
            value: 45000.0,
            icon: Icons.computer,
            metadata: {'allocation': 36.0},
          ),
        ],
        metadata: HeatmapMetadata(
          lastUpdated: DateTime.now(),
          dataSource: 'portfolio_api',
          additionalInfo: {'portfolioId': portfolioId},
        ),
        configuration: const HeatmapConfiguration(),
      );

      AppLogger.info(
        'Heatmap data created successfully',
        tag: 'PortfolioHeatmapCubit',
      );
      AppLogger.debug('Heatmap data details', tag: 'PortfolioHeatmapCubit');

      AppLogger.stateChange(
        'PortfolioHeatmapLoading',
        'PortfolioHeatmapLoaded',
        tag: 'PortfolioHeatmapCubit',
      );

      emit(
        PortfolioHeatmapLoaded(
          heatmapData: sampleData,
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
}
