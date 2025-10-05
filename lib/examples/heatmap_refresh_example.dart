// Example of how to use the HeatmapDisplayTemplate with refresh functionality

import 'package:flutter/material.dart';

import '../shared/widgets/heatmap/core/heatmap_display_core.dart';
import '../shared/widgets/heatmap/heatmap_display_template.dart';

/// Example showing how to implement data refresh in heatmap display
class HeatmapWithRefreshExample extends StatefulWidget {
  const HeatmapWithRefreshExample({super.key});

  @override
  State<HeatmapWithRefreshExample> createState() =>
      _HeatmapWithRefreshExampleState();
}

class _HeatmapWithRefreshExampleState extends State<HeatmapWithRefreshExample> {
  late HeatmapDisplayCore _displayCore;

  @override
  void initState() {
    super.initState();

    // Initialize core with refresh callback
    _displayCore = HeatmapDisplayCore(
      initialIsLoading: true,
      onRefreshRequested: _handleDataRefresh,
      onTilePressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tile pressed!')));
      },
    );

    // Load initial data
    _loadInitialData();
  }

  @override
  void dispose() {
    _displayCore.dispose();
    super.dispose();
  }

  /// Load initial data
  void _loadInitialData() {
    _handleDataRefresh();
  }

  /// Handle data refresh - this is where you would fetch new data from API
  Future<void> _handleDataRefresh() async {
    try {
      // Simulate network call
      await Future.delayed(const Duration(seconds: 1));

      // In real app, you would call your API here
      // final newData = await heatmapService.fetchHeatmapData();

      if (mounted) {
        // For demo purposes, create sample data
        final newData = _createSampleHeatmapData();
        _displayCore.updateData(newData);
        _displayCore.setLoading(false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data refreshed!')));
      }
    } catch (error) {
      if (mounted) {
        _displayCore.setError('Failed to refresh data: $error');
        _displayCore.setLoading(false);
      }
    }
  }

  /// Create sample heatmap data (replace with your actual data fetching)
  dynamic _createSampleHeatmapData() {
    // This would be replaced with your actual HeatmapData creation
    // For now, return null to demonstrate empty state handling
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Heatmap with Refresh'),
      actions: [
        IconButton(
          onPressed: () => _displayCore.refresh(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Data',
        ),
      ],
    ),
    body: Column(
      children: [
        // Instructions card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refresh Methods:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('• Pull down to refresh (mobile)'),
                const Text('• Click refresh button (web/mobile)'),
                const Text('• Tap refresh icon in app bar'),
              ],
            ),
          ),
        ),

        // Heatmap display
        Expanded(
          child: HeatmapDisplayTemplate(
            core: _displayCore,
            onLayoutChanged: (layout) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Layout changed to: $layout')),
              );
            },
          ),
        ),
      ],
    ),
  );
}

/// Alternative example using legacy interface
class LegacyHeatmapWithRefreshExample extends StatefulWidget {
  const LegacyHeatmapWithRefreshExample({super.key});

  @override
  State<LegacyHeatmapWithRefreshExample> createState() =>
      _LegacyHeatmapWithRefreshExampleState();
}

class _LegacyHeatmapWithRefreshExampleState
    extends State<LegacyHeatmapWithRefreshExample> {
  dynamic _heatmapData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In real app: final data = await api.fetchHeatmapData();

      setState(() {
        _heatmapData = null; // Replace with actual data
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load data: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Legacy Heatmap with Refresh')),
    body: HeatmapDisplayTemplate(
      // Legacy interface - still works!
      data: _heatmapData,
      isLoading: _isLoading,
      error: _error,
      onRefreshRequested: _loadData, // Handle refresh requests
      onTilePressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Legacy tile pressed!')));
      },
    ),
  );
}
