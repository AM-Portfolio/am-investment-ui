import 'package:flutter/material.dart';

import '../../../../core/utils/logger.dart';
import '../../../models/heatmap/heatmap_tile_data.dart';
import '../../../models/heatmap/heatmap_ui_data.dart';

/// Mobile-optimized heatmap layout with touch-friendly design
/// Optimized for mobile screens with vertical stacking and larger touch targets
class HeatmapLayoutMobile extends StatelessWidget {
  const HeatmapLayoutMobile({
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
      'HeatmapLayoutMobile: rendering mobile layout',
      tag: 'Heatmap.Layout.Mobile',
    );

    return Container(
      color: backgroundColor,
      padding: padding ?? const EdgeInsets.all(8),
      child: Column(
        children: [
          // Selectors section - full width on mobile
          if (showSelectors && selectorWidget != null) ...[
            selectorWidget!,
            const SizedBox(height: 12),
          ],

          // Main heatmap card with mobile-optimized padding
          Expanded(
            child: Card(
              elevation: 2, // Slightly less elevation for mobile
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12), // Reduced padding for mobile
                child: Column(
                  children: [
                    // Header section - mobile optimized
                    if (showHeader) ...[
                      customHeader ?? _buildMobileHeader(context),
                      const SizedBox(height: 12),
                    ],

                    // Legend section - compact for mobile
                    if (showLegend && data.configuration.showPerformance) ...[
                      _buildMobileColorLegend(context),
                      const SizedBox(height: 12),
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

  Widget _buildMobileHeader(BuildContext context) {
    final effectiveTitle = title ?? data.title;
    final effectiveSubtitle = subtitle ?? data.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with icon
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                effectiveTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Subtitle (if exists)
        if (effectiveSubtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            effectiveSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Header actions (if exists) - stacked vertically on small screens
        if (headerActions != null && headerActions!.isNotEmpty) ...[
          const SizedBox(height: 8),
          if (MediaQuery.of(context).size.width < 400)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: headerActions!
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: action,
                    ),
                  )
                  .toList(),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: headerActions!,
            ),
        ],
      ],
    );
  }

  Widget _buildMobileColorLegend(BuildContext context) {
    if (data.configuration.colorScheme != HeatmapColorSchemeType.performance) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMobileLegendItem(context, 'Loss', Colors.red.shade300),
          _buildMobileLegendItem(context, 'Neutral', Colors.grey.shade300),
          _buildMobileLegendItem(context, 'Gain', Colors.green.shade300),
        ],
      ),
    );
  }

  Widget _buildMobileLegendItem(
    BuildContext context,
    String label,
    Color color,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14, // Slightly larger for mobile
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    ],
  );
}
