import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';

/// Web-optimized heatmap layout with desktop-friendly design
/// Optimized for larger screens with horizontal layouts and dense information
class HeatmapLayoutWeb extends StatelessWidget {
  const HeatmapLayoutWeb({
    required this.data,
    required this.displayWidget,
    super.key,
    this.selectorWidget,
    this.title,
    this.subtitle,
    this.icon,
    this.showHeader = true,
    this.showLegend = true,
    this.showSelectors = true,
    this.headerActions,
    this.customHeader,
    this.padding,
    this.backgroundColor,
  });

  final HeatmapData data;
  final Widget displayWidget;
  final Widget? selectorWidget;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool showHeader;
  final bool showLegend;
  final bool showSelectors;
  final List<Widget>? headerActions;
  final Widget? customHeader;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      'HeatmapLayoutWeb: rendering web layout',
      tag: 'Heatmap.Layout.Web',
    );

    return Container(
      color: backgroundColor,
      padding: padding ?? const EdgeInsets.all(12),
      child: Column(
        children: [
          // Selectors section - compact horizontal layout for web
          if (showSelectors && selectorWidget != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: selectorWidget,
            ),
            const SizedBox(height: 16),
          ],

          // Main heatmap card with web-optimized styling
          Expanded(
            child: Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20), // More padding for web
                child: Column(
                  children: [
                    // Header section - web optimized
                    if (showHeader) ...[
                      customHeader ?? _buildWebHeader(context),
                      const SizedBox(height: 20),
                    ],

                    // Legend section - horizontal layout for web
                    if (showLegend && data.configuration.showPerformance) ...[
                      _buildWebColorLegend(context),
                      const SizedBox(height: 20),
                    ],

                    // Main display content
                    Expanded(child: displayWidget),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    final effectiveTitle = title ?? data.title;
    final effectiveSubtitle = subtitle ?? data.subtitle;

    return Row(
      children: [
        // Icon and title section
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (effectiveSubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        effectiveSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Header actions - horizontal layout for web
        if (headerActions != null && headerActions!.isNotEmpty) ...[
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: headerActions!
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: action,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildWebColorLegend(BuildContext context) {
    if (data.configuration.colorScheme != HeatmapColorSchemeType.performance) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.palette_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Performance Scale:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _buildWebLegendItem(context, 'Loss', Colors.red.shade400),
                const SizedBox(width: 24),
                _buildWebLegendItem(context, 'Neutral', Colors.grey.shade400),
                const SizedBox(width: 24),
                _buildWebLegendItem(context, 'Gain', Colors.green.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLegendItem(BuildContext context, String label, Color color) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      );
}
