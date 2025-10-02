import 'package:flutter/material.dart';
import '../../../shared/widgets/cards/heatmap_card.dart';
import '../../../shared/models/heatmap.dart';

/// Example widget demonstrating how to use the shared HeatmapCard
/// for different types of data (e.g., geographic allocation, asset allocation, etc.)
class AssetAllocationHeatmapExample extends StatelessWidget {
  const AssetAllocationHeatmapExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data for asset allocation
    final heatmapData = HeatmapData(
      title: 'Asset Allocation',
      subtitle: 'Portfolio distribution by asset type',
      tiles: [
        HeatmapTileData(
          id: 'equity',
          name: 'Equity',
          displayName: 'Equity',
          weightage: 65.0,
          performance: 12.5,
          value: 650000,
        ),
        HeatmapTileData(
          id: 'debt',
          name: 'Debt',
          displayName: 'Debt',
          weightage: 25.0,
          performance: 6.8,
          value: 250000,
        ),
        HeatmapTileData(
          id: 'gold',
          name: 'Gold',
          displayName: 'Gold',
          weightage: 8.0,
          performance: -2.3,
          value: 80000,
        ),
        HeatmapTileData(
          id: 'cash',
          name: 'Cash',
          displayName: 'Cash',
          weightage: 2.0,
          performance: 4.0,
          value: 20000,
        ),
      ],
      configuration: HeatmapConfiguration.web(),
    );

    return HeatmapCard(
      data: heatmapData,
      icon: Icons.account_balance_wallet,
      onTilePressed: () {
        // Handle tile press - navigate to asset details
        debugPrint('Asset tile pressed');
      },
    );
  }
}

/// Example widget for geographic allocation using mobile configuration
class GeographicAllocationHeatmapExample extends StatelessWidget {
  const GeographicAllocationHeatmapExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data for geographic allocation
    final heatmapData = HeatmapData(
      title: 'Geographic Allocation',
      tiles: [
        HeatmapTileData(
          id: 'india',
          name: 'India',
          displayName: 'India',
          weightage: 70.0,
          performance: 15.2,
        ),
        HeatmapTileData(
          id: 'usa',
          name: 'United States',
          displayName: 'USA',
          weightage: 20.0,
          performance: 8.5,
        ),
        HeatmapTileData(
          id: 'europe',
          name: 'Europe',
          displayName: 'Europe',
          weightage: 7.0,
          performance: 5.1,
        ),
        HeatmapTileData(
          id: 'asia_ex_india',
          name: 'Asia ex-India',
          displayName: 'Asia ex-India',
          weightage: 3.0,
          performance: -1.2,
        ),
      ],
      configuration: HeatmapConfiguration.mobile(), // Use mobile config
    );

    return HeatmapCard(data: heatmapData, icon: Icons.public);
  }
}

/// Example showing custom colors and weightage-based color scheme
class CustomColorHeatmapExample extends StatelessWidget {
  const CustomColorHeatmapExample({super.key});

  @override
  Widget build(BuildContext context) {
    final heatmapData = HeatmapData(
      title: 'Market Cap Allocation',
      tiles: [
        HeatmapTileData(
          id: 'large_cap',
          name: 'Large Cap',
          displayName: 'Large Cap',
          weightage: 50.0,
          performance: 10.5,
          customColor: Colors.blue.shade400,
        ),
        HeatmapTileData(
          id: 'mid_cap',
          name: 'Mid Cap',
          displayName: 'Mid Cap',
          weightage: 30.0,
          performance: 18.2,
          customColor: Colors.purple.shade400,
        ),
        HeatmapTileData(
          id: 'small_cap',
          name: 'Small Cap',
          displayName: 'Small Cap',
          weightage: 20.0,
          performance: 25.7,
          customColor: Colors.orange.shade400,
        ),
      ],
      configuration: const HeatmapConfiguration(
        showSubCards: true,
        colorScheme: HeatmapColorScheme.custom,
        layout: HeatmapLayout.treemap,
      ),
    );

    return HeatmapCard(data: heatmapData, icon: Icons.trending_up);
  }
}
