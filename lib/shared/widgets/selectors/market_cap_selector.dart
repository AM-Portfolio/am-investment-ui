import 'package:flutter/material.dart';
import '../inputs/app_segmented_control.dart';

/// Enum for different market cap categories
enum MarketCapType {
  all('All', 'All Cap', Icons.account_balance_wallet),
  largeCap('Large', 'Large Cap', Icons.trending_up),
  midCap('Mid', 'Mid Cap', Icons.show_chart),
  smallCap('Small', 'Small Cap', Icons.insights),
  megaCap('Mega', 'Mega Cap', Icons.currency_exchange),
  microCap('Micro', 'Micro Cap', Icons.grain);

  const MarketCapType(this.shortName, this.displayName, this.icon);

  /// Short name for compact display
  final String shortName;

  /// Full display name
  final String displayName;

  /// Representative icon
  final IconData icon;

  /// Get market cap type from short name
  static MarketCapType? fromShortName(String shortName) {
    for (final marketCap in MarketCapType.values) {
      if (marketCap.shortName == shortName) {
        return marketCap;
      }
    }
    return null;
  }

  /// Common market cap categories for portfolio analysis
  static List<MarketCapType> get portfolioMarketCaps => [
    MarketCapType.all,
    MarketCapType.largeCap,
    MarketCapType.midCap,
    MarketCapType.smallCap,
  ];

  /// All available market cap categories
  static List<MarketCapType> get allMarketCaps => MarketCapType.values;

  /// Standard market cap categories (excluding micro and mega)
  static List<MarketCapType> get standardMarketCaps => [
    MarketCapType.all,
    MarketCapType.largeCap,
    MarketCapType.midCap,
    MarketCapType.smallCap,
  ];
}

/// Widget for selecting different market cap categories
class MarketCapSelector extends StatelessWidget {
  /// Currently selected market cap
  final MarketCapType selectedMarketCap;

  /// Callback when market cap changes
  final ValueChanged<MarketCapType> onMarketCapChanged;

  /// Available market cap options (defaults to portfolio market caps)
  final List<MarketCapType>? availableMarketCaps;

  /// Whether to show as compact chips instead of dropdown
  final bool compact;

  /// Primary color for the selector
  final Color? primaryColor;

  /// Whether to show icons alongside text
  final bool showIcons;

  /// Whether to use full display names instead of short names
  final bool useDisplayNames;

  /// Optional title for the selector
  final String? title;

  /// Whether to show as dropdown instead of chips
  final bool asDropdown;

  /// Constructor
  const MarketCapSelector({
    super.key,
    required this.selectedMarketCap,
    required this.onMarketCapChanged,
    this.availableMarketCaps,
    this.compact = false,
    this.primaryColor,
    this.showIcons = false,
    this.useDisplayNames = false,
    this.title,
    this.asDropdown = true,
  });

  /// Factory constructor for portfolio context
  factory MarketCapSelector.portfolio({
    Key? key,
    required MarketCapType selectedMarketCap,
    required ValueChanged<MarketCapType> onMarketCapChanged,
    bool compact = true,
    Color? primaryColor,
    bool showIcons = false,
    String? title,
  }) {
    return MarketCapSelector(
      key: key,
      selectedMarketCap: selectedMarketCap,
      onMarketCapChanged: onMarketCapChanged,
      availableMarketCaps: MarketCapType.portfolioMarketCaps,
      compact: compact,
      primaryColor: primaryColor,
      showIcons: showIcons,
      title: title,
      asDropdown: false,
    );
  }

  /// Factory constructor for heatmap context
  factory MarketCapSelector.heatmap({
    Key? key,
    required MarketCapType selectedMarketCap,
    required ValueChanged<MarketCapType> onMarketCapChanged,
    bool asDropdown = true,
    Color? primaryColor,
    String? title,
  }) {
    return MarketCapSelector(
      key: key,
      selectedMarketCap: selectedMarketCap,
      onMarketCapChanged: onMarketCapChanged,
      availableMarketCaps: MarketCapType.standardMarketCaps,
      asDropdown: asDropdown,
      primaryColor: primaryColor,
      showIcons: false,
      useDisplayNames: false,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketCaps = availableMarketCaps ?? MarketCapType.portfolioMarketCaps;

    Widget selector;

    if (asDropdown) {
      selector = _buildDropdownSelector(context, marketCaps);
    } else if (compact) {
      selector = _buildCompactSelector(context, marketCaps);
    } else {
      selector = _buildSegmentedSelector(context, marketCaps);
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
    List<MarketCapType> marketCaps,
  ) {
    final children = Map<MarketCapType, String>.fromEntries(
      marketCaps.map(
        (marketCap) => MapEntry(
          marketCap,
          useDisplayNames ? marketCap.displayName : marketCap.shortName,
        ),
      ),
    );

    return AppSegmentedControl<MarketCapType>(
      selectedValue: selectedMarketCap,
      children: children,
      onValueChanged: onMarketCapChanged,
      primaryColor: primaryColor,
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    List<MarketCapType> marketCaps,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: marketCaps.map((marketCap) {
        final isSelected = marketCap == selectedMarketCap;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onMarketCapChanged(marketCap),
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
                      marketCap.icon,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    useDisplayNames
                        ? marketCap.displayName
                        : marketCap.shortName,
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
    List<MarketCapType> marketCaps,
  ) {
    return DropdownButtonFormField<MarketCapType>(
      value: selectedMarketCap,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      items: marketCaps.map((marketCap) {
        return DropdownMenuItem<MarketCapType>(
          value: marketCap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcons) ...[
                Icon(marketCap.icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                useDisplayNames ? marketCap.displayName : marketCap.shortName,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (marketCap) {
        if (marketCap != null) {
          onMarketCapChanged(marketCap);
        }
      },
    );
  }
}
