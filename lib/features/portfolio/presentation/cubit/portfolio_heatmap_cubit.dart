import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../state/portfolio_heatmap_state.dart';
import '../../../../shared/widgets/selectors/selectors.dart';
import '../../../../shared/models/heatmap/heatmap_ui_data.dart';
import '../../../../shared/models/heatmap/heatmap_tile_data.dart';
import '../../../../shared/models/heatmap/heatmap_configuration.dart';

/// Portfolio Heatmap Cubit
class PortfolioHeatmapCubit extends Cubit<PortfolioHeatmapState> {
  final Ref _ref;

  PortfolioHeatmapCubit(this._ref) : super(const PortfolioHeatmapInitial());

  /// Load heatmap data for portfolio
  Future<void> loadHeatmapData({
    required String portfolioId,
    TimeFrame timeFrame = TimeFrame.oneDay,
    MetricType metric = MetricType.marketValue,
    SectorType sector = SectorType.all,
    MarketCapType marketCap = MarketCapType.all,  
  }) async {
    try {
      emit(const PortfolioHeatmapLoading(message: 'Loading portfolio heatmap...'));
      await Future.delayed(const Duration(milliseconds: 500));

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
        metadata: {'portfolioId': portfolioId},
        configuration: const HeatmapConfiguration(
          layout: HeatmapLayoutType.grid,
          colorScheme: HeatmapColorSchemeType.performance,
          defaultSorting: HeatmapSortingType.performance,
        ),
      );

      emit(PortfolioHeatmapLoaded(
        data: sampleData,
        portfolioId: portfolioId,
        timeFrame: timeFrame,
        metric: metric,
        sector: sector,
        marketCap: marketCap,
      ));
    } catch (e, stackTrace) {
      emit(PortfolioHeatmapError(
        message: 'Failed to load portfolio heatmap',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> updateTimeFrame(TimeFrame timeFrame) async {
    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: timeFrame,
        metric: currentState.metric,
        sector: currentState.sector,
        marketCap: currentState.marketCap,
      );
    }
  }

  Future<void> updateMetric(MetricType metric) async {
    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: metric,
        sector: currentState.sector,
        marketCap: currentState.marketCap,
      );
    }
  }

  Future<void> updateSector(SectorType sector) async {
    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: sector,
        marketCap: currentState.marketCap,
      );
    }
  }

  Future<void> updateMarketCap(MarketCapType marketCap) async {
    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: currentState.sector,
        marketCap: marketCap,
      );
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is PortfolioHeatmapLoaded) {
      await loadHeatmapData(
        portfolioId: currentState.portfolioId,
        timeFrame: currentState.timeFrame,
        metric: currentState.metric,
        sector: currentState.sector,
        marketCap: currentState.marketCap,
      );
    }
  }
}
