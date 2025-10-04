import 'package:flutter/material.dart';
import '../selectors/selectors.dart';
import 'heatmap_selector_card.dart';

/// Advanced, modern heatmap selector card with sophisticated UX
class AdvancedHeatmapSelectorCard extends StatefulWidget {
  /// Current configuration values
  final HeatmapSelectorConfig config;

  /// Callbacks for selector changes
  final HeatmapSelectorCallbacks callbacks;

  /// Primary color theme
  final Color? primaryColor;

  /// Whether to use compact mode
  final bool compact;

  /// Whether to show reset button
  final bool showResetButton;

  /// Whether to show export button
  final bool showExportButton;

  /// Reset callback
  final VoidCallback? onReset;

  /// Export callback
  final VoidCallback? onExport;

  /// Custom margin
  final EdgeInsets? margin;

  const AdvancedHeatmapSelectorCard({
    super.key,
    required this.config,
    required this.callbacks,
    this.primaryColor,
    this.compact = false,
    this.showResetButton = false,
    this.showExportButton = false,
    this.onReset,
    this.onExport,
    this.margin,
  });

  @override
  State<AdvancedHeatmapSelectorCard> createState() =>
      _AdvancedHeatmapSelectorCardState();
}

class _AdvancedHeatmapSelectorCardState
    extends State<AdvancedHeatmapSelectorCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Color get _primaryColor =>
      widget.primaryColor ?? Theme.of(context).primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
            border: Border.all(
              color: _primaryColor.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildHeader(context),
                _buildMainFilters(context),
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: child,
                    );
                  },
                  child: _buildAdvancedFilters(context),
                ),
                if (widget.showResetButton || widget.showExportButton)
                  _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.08),
            _primaryColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Customize your view',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _primaryColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildActiveFiltersCount(context),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersCount(BuildContext context) {
    int activeCount = 0;
    if (widget.config.selectedTimeFrame != TimeFrame.oneYear) activeCount++;
    if (widget.config.selectedMetric != MetricType.changePercent) activeCount++;
    if (widget.config.selectedSector != SectorType.all) activeCount++;
    if (widget.config.selectedMarketCap != MarketCapType.all) activeCount++;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: activeCount > 0
            ? _primaryColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: activeCount > 0 ? _primaryColor : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '$activeCount active',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: activeCount > 0 ? _primaryColor : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileMainFilters(context);
          } else {
            return _buildDesktopMainFilters(context);
          }
        },
      ),
    );
  }

  Widget _buildDesktopMainFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildModernTimeFrameSelector(context)),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildModernMetricSelector(context)),
        const SizedBox(width: 20),
        _buildAdvancedToggle(context),
      ],
    );
  }

  Widget _buildMobileMainFilters(BuildContext context) {
    return Column(
      children: [
        _buildModernTimeFrameSelector(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildModernMetricSelector(context)),
            const SizedBox(width: 16),
            _buildAdvancedToggle(context),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTimeFrameSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: _primaryColor),
              const SizedBox(width: 6),
              Text(
                'Time Period',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: TimeFrame.heatmapTimeFrames.map((timeFrame) {
                final isSelected = widget.config.selectedTimeFrame == timeFrame;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildTimeFrameChip(context, timeFrame, isSelected),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFrameChip(
    BuildContext context,
    TimeFrame timeFrame,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.callbacks.onTimeFrameChanged(timeFrame),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: Text(
              timeFrame.code,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernMetricSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.analytics_rounded, size: 16, color: _primaryColor),
              const SizedBox(width: 6),
              Text(
                'Metric',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MetricType>(
              value: widget.config.selectedMetric,
              onChanged: (metric) {
                if (metric != null) {
                  widget.callbacks.onMetricChanged(metric);
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _primaryColor,
              ),
              selectedItemBuilder: (context) {
                return MetricType.heatmapMetrics.map((metric) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          metric.icon,
                          size: 16,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        metric.shortName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: MetricType.heatmapMetrics.map((metric) {
                return DropdownMenuItem<MetricType>(
                  value: metric,
                  child: Row(
                    children: [
                      Icon(metric.icon, size: 18, color: _primaryColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            metric.shortName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            metric.displayName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedToggle(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28), // Align with other elements
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _expandController.forward();
                } else {
                  _expandController.reverse();
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? _primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isExpanded
                      ? _primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.tune_rounded,
                  color: _isExpanded ? _primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildMobileAdvancedFilters(context);
              } else {
                return _buildDesktopAdvancedFilters(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAdvancedFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildModernSectorSelector(context)),
        const SizedBox(width: 20),
        Expanded(child: _buildModernMarketCapSelector(context)),
      ],
    );
  }

  Widget _buildMobileAdvancedFilters(BuildContext context) {
    return Column(
      children: [
        _buildModernSectorSelector(context),
        const SizedBox(height: 16),
        _buildModernMarketCapSelector(context),
      ],
    );
  }

  Widget _buildModernSectorSelector(BuildContext context) {
    return _buildAdvancedDropdown(
      context,
      title: 'Sector',
      icon: Icons.business_rounded,
      value: widget.config.selectedSector,
      items: SectorType.portfolioSectors,
      onChanged: (SectorType? value) {
        if (value != null) {
          widget.callbacks.onSectorChanged(value);
        }
      },
      itemBuilder: (sector) => Row(
        children: [
          Icon(sector.icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Text(sector.displayName),
        ],
      ),
      selectedBuilder: (sector) => Row(
        children: [
          Icon(sector.icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Text(sector.shortName),
        ],
      ),
    );
  }

  Widget _buildModernMarketCapSelector(BuildContext context) {
    return _buildAdvancedDropdown(
      context,
      title: 'Market Cap',
      icon: Icons.account_balance_wallet_rounded,
      value: widget.config.selectedMarketCap,
      items: MarketCapType.portfolioMarketCaps,
      onChanged: (MarketCapType? value) {
        if (value != null) {
          widget.callbacks.onMarketCapChanged(value);
        }
      },
      itemBuilder: (marketCap) => Row(
        children: [
          Icon(marketCap.icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Text(marketCap.displayName),
        ],
      ),
      selectedBuilder: (marketCap) => Row(
        children: [
          Icon(marketCap.icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Text(marketCap.shortName),
        ],
      ),
    );
  }

  Widget _buildAdvancedDropdown<T>(
    BuildContext context, {
    required String title,
    required IconData icon,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
    required Widget Function(T) selectedBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 16, color: _primaryColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade600,
              ),
              selectedItemBuilder: (context) {
                return items.map((item) => selectedBuilder(item)).toList();
              },
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: itemBuilder(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: [
          if (widget.showResetButton)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (widget.showResetButton && widget.showExportButton)
            const SizedBox(width: 16),
          if (widget.showExportButton)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
