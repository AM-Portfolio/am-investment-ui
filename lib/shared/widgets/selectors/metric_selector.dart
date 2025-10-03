import 'package:flutter/material.dart';
import '../inputs/app_segmented_control.dart';

/// Enum for different metric types that can be displayed
enum MetricType {
  // Performance metrics
  returns('Returns', 'Total Returns', Icons.trending_up),
  dailyReturns('Daily', 'Daily Returns', Icons.today),
  weeklyReturns('Weekly', 'Weekly Returns', Icons.date_range),
  monthlyReturns('Monthly', 'Monthly Returns', Icons.calendar_month),

  // Value metrics
  marketValue('Value', 'Market Value', Icons.account_balance_wallet),
  investedValue('Invested', 'Invested Value', Icons.payment),
  profitLoss('P&L', 'Profit & Loss', Icons.account_balance),

  // Percentage metrics
  changePercent('Change %', 'Change Percentage', Icons.percent),
  allocationPercent('Allocation %', 'Portfolio Allocation', Icons.pie_chart),

  // Performance ratios
  sharpeRatio('Sharpe', 'Sharpe Ratio', Icons.analytics),
  beta('Beta', 'Portfolio Beta', Icons.show_chart),
  volatility('Volatility', 'Price Volatility', Icons.waves),

  // Risk metrics
  drawdown('Drawdown', 'Maximum Drawdown', Icons.trending_down),
  valueAtRisk('VaR', 'Value at Risk', Icons.warning),

  // Volume metrics
  volume('Volume', 'Trading Volume', Icons.bar_chart),
  averageVolume('Avg Volume', 'Average Volume', Icons.timeline);

  const MetricType(this.shortName, this.displayName, this.icon);

  /// Short name for compact display
  final String shortName;

  /// Full display name
  final String displayName;

  /// Representative icon
  final IconData icon;

  /// Get metric type from short name
  static MetricType? fromShortName(String shortName) {
    for (final metric in MetricType.values) {
      if (metric.shortName == shortName) {
        return metric;
      }
    }
    return null;
  }

  /// Common metrics for portfolio overview
  static List<MetricType> get portfolioMetrics => [
    MetricType.marketValue,
    MetricType.profitLoss,
    MetricType.changePercent,
    MetricType.returns,
    MetricType.allocationPercent,
  ];

  /// Common metrics for performance analysis
  static List<MetricType> get performanceMetrics => [
    MetricType.returns,
    MetricType.dailyReturns,
    MetricType.weeklyReturns,
    MetricType.monthlyReturns,
    MetricType.changePercent,
  ];

  /// Common metrics for risk analysis
  static List<MetricType> get riskMetrics => [
    MetricType.volatility,
    MetricType.beta,
    MetricType.sharpeRatio,
    MetricType.drawdown,
    MetricType.valueAtRisk,
  ];

  /// Common metrics for heatmap display
  static List<MetricType> get heatmapMetrics => [
    MetricType.changePercent,
    MetricType.marketValue,
    MetricType.allocationPercent,
    MetricType.profitLoss,
  ];

  /// Common metrics for trading analysis
  static List<MetricType> get tradingMetrics => [
    MetricType.changePercent,
    MetricType.volume,
    MetricType.averageVolume,
    MetricType.volatility,
  ];

  /// Mobile-optimized metrics (limited selection)
  static List<MetricType> get mobileMetrics => [
    MetricType.changePercent,
    MetricType.marketValue,
    MetricType.returns,
    MetricType.volume,
  ];

  /// Web-optimized metrics (full selection)
  static List<MetricType> get webMetrics => [
    MetricType.changePercent,
    MetricType.marketValue,
    MetricType.returns,
    MetricType.volume,
    MetricType.volatility,
    MetricType.sharpeRatio,
    MetricType.beta,
    MetricType.profitLoss,
    MetricType.allocationPercent,
    MetricType.averageVolume,
    MetricType.valueAtRisk,
    MetricType.drawdown,
  ];
}

/// Widget for selecting different metrics to display
class MetricSelector extends StatelessWidget {
  /// Currently selected metric
  final MetricType selectedMetric;

  /// Callback when metric changes
  final ValueChanged<MetricType> onMetricChanged;

  /// Available metric options (defaults to portfolio metrics)
  final List<MetricType>? availableMetrics;

  /// Whether to show as compact chips instead of segmented control
  final bool compact;

  /// Primary color for the selector
  final Color? primaryColor;

  /// Whether to show icons alongside text
  final bool showIcons;

  /// Whether to use full display names instead of short names
  final bool useDisplayNames;

  /// Optional title for the selector
  final String? title;

  /// Whether to show as dropdown instead of chips/segments
  final bool asDropdown;

  /// Constructor
  const MetricSelector({
    super.key,
    required this.selectedMetric,
    required this.onMetricChanged,
    this.availableMetrics,
    this.compact = false,
    this.primaryColor,
    this.showIcons = false,
    this.useDisplayNames = false,
    this.title,
    this.asDropdown = false,
  });

  /// Factory constructor for portfolio context
  factory MetricSelector.portfolio({
    Key? key,
    required MetricType selectedMetric,
    required ValueChanged<MetricType> onMetricChanged,
    bool compact = false,
    Color? primaryColor,
    bool showIcons = true,
    String? title,
  }) {
    return MetricSelector(
      key: key,
      selectedMetric: selectedMetric,
      onMetricChanged: onMetricChanged,
      availableMetrics: MetricType.portfolioMetrics,
      compact: compact,
      primaryColor: primaryColor,
      showIcons: showIcons,
      title: title,
    );
  }

  /// Factory constructor for performance analysis context
  factory MetricSelector.performance({
    Key? key,
    required MetricType selectedMetric,
    required ValueChanged<MetricType> onMetricChanged,
    bool compact = true,
    Color? primaryColor,
    String? title,
  }) {
    return MetricSelector(
      key: key,
      selectedMetric: selectedMetric,
      onMetricChanged: onMetricChanged,
      availableMetrics: MetricType.performanceMetrics,
      compact: compact,
      primaryColor: primaryColor,
      title: title,
    );
  }

  /// Factory constructor for risk analysis context
  factory MetricSelector.risk({
    Key? key,
    required MetricType selectedMetric,
    required ValueChanged<MetricType> onMetricChanged,
    bool asDropdown = true,
    Color? primaryColor,
    String? title,
  }) {
    return MetricSelector(
      key: key,
      selectedMetric: selectedMetric,
      onMetricChanged: onMetricChanged,
      availableMetrics: MetricType.riskMetrics,
      asDropdown: asDropdown,
      primaryColor: primaryColor,
      useDisplayNames: true,
      title: title,
    );
  }

  /// Factory constructor for heatmap context
  factory MetricSelector.heatmap({
    Key? key,
    required MetricType selectedMetric,
    required ValueChanged<MetricType> onMetricChanged,
    bool compact = true,
    Color? primaryColor,
    String? title,
  }) {
    return MetricSelector(
      key: key,
      selectedMetric: selectedMetric,
      onMetricChanged: onMetricChanged,
      availableMetrics: MetricType.heatmapMetrics,
      compact: compact,
      primaryColor: primaryColor,
      title: title,
    );
  }

  /// Factory constructor for trading context
  factory MetricSelector.trading({
    Key? key,
    required MetricType selectedMetric,
    required ValueChanged<MetricType> onMetricChanged,
    bool compact = true,
    Color? primaryColor,
    String? title,
  }) {
    return MetricSelector(
      key: key,
      selectedMetric: selectedMetric,
      onMetricChanged: onMetricChanged,
      availableMetrics: MetricType.tradingMetrics,
      compact: compact,
      primaryColor: primaryColor,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = availableMetrics ?? MetricType.portfolioMetrics;

    Widget selector;

    if (asDropdown) {
      selector = _buildDropdownSelector(context, metrics);
    } else if (compact) {
      selector = _buildCompactSelector(context, metrics);
    } else {
      selector = _buildSegmentedSelector(context, metrics);
    }

    if (title != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          selector,
        ],
      );
    }

    return selector;
  }

  Widget _buildSegmentedSelector(
    BuildContext context,
    List<MetricType> metrics,
  ) {
    final children = Map<MetricType, String>.fromEntries(
      metrics.map(
        (metric) => MapEntry(
          metric,
          useDisplayNames ? metric.displayName : metric.shortName,
        ),
      ),
    );

    return AppSegmentedControl<MetricType>(
      selectedValue: selectedMetric,
      children: children,
      onValueChanged: onMetricChanged,
      primaryColor: primaryColor,
    );
  }

  Widget _buildCompactSelector(BuildContext context, List<MetricType> metrics) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: metrics.map((metric) {
        final isSelected = metric == selectedMetric;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onMetricChanged(metric),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (primaryColor ?? Theme.of(context).primaryColor)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? (primaryColor ?? Theme.of(context).primaryColor)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showIcons) ...[
                    Icon(
                      metric.icon,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    useDisplayNames ? metric.displayName : metric.shortName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownSelector(
    BuildContext context,
    List<MetricType> metrics,
  ) {
    return DropdownButtonFormField<MetricType>(
      value: selectedMetric,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      items: metrics.map((metric) {
        return DropdownMenuItem<MetricType>(
          value: metric,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcons) ...[
                Icon(metric.icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                useDisplayNames ? metric.displayName : metric.shortName,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (metric) {
        if (metric != null) {
          onMetricChanged(metric);
        }
      },
    );
  }
}
