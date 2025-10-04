import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import '../selectors/selectors.dart';import '../selectors/selectors.dart';

import 'heatmap_selector_card.dart';import 'heatmap_selector_card.dart';



/// Advanced, modern heatmap selector card with sophisticated UX/// Advanced, modern heatmap selector card with sophisticated UX

/// Optimized for single-row compact design/// Optimized for single-row compact design

class AdvancedHeatmapSelectorCard extends StatefulWidget {class AdvancedHeatmapSelectorCard extends StatefulWidget {

  /// Current configuration values  /// Current configuration values

  final HeatmapSelectorConfig config;  final HeatmapSelectorConfig config;



  /// Callbacks for selector changes  /// Callbacks for selector changes

  final HeatmapSelectorCallbacks callbacks;  final HeatmapSelectorCallbacks callbacks;



  /// Primary color theme  /// Primary color theme

  final Color? primaryColor;  final Color? primaryColor;



  /// Whether to use compact mode  /// Whether to use compact mode

  final bool compact;  final bool compact;



  /// Whether to show reset button  /// Whether to show reset button

  final bool showResetButton;  final bool showResetButton;



  /// Whether to show export button  /// Whether to show export button

  final bool showExportButton;  final bool showExportButton;



  /// Reset callback  /// Reset callback

  final VoidCallback? onReset;  final VoidCallback? onReset;



  /// Export callback  /// Export callback

  final VoidCallback? onExport;  final VoidCallback? onExport;



  /// Custom margin  /// Custom margin

  final EdgeInsets? margin;  final EdgeInsets? margin;



  const AdvancedHeatmapSelectorCard({  const AdvancedHeatmapSelectorCard({

    super.key,    super.key,

    required this.config,    required this.config,

    required this.callbacks,    required this.callbacks,

    this.primaryColor,    this.primaryColor,

    this.compact = false,    this.compact = false,

    this.showResetButton = false,    this.showResetButton = false,

    this.showExportButton = false,    this.showExportButton = false,

    this.onReset,    this.onReset,

    this.onExport,    this.onExport,

    this.margin,    this.margin,

  });  });



  @override  @override

  State<AdvancedHeatmapSelectorCard> createState() =>  State<AdvancedHeatmapSelectorCard> createState() =>

      _AdvancedHeatmapSelectorCardState();      _AdvancedHeatmapSelectorCardState();

}}



class _AdvancedHeatmapSelectorCardStateclass _AdvancedHeatmapSelectorCardState

    extends State<AdvancedHeatmapSelectorCard> {    extends State<AdvancedHeatmapSelectorCard> {



  Color get _primaryColor =>  Color get _primaryColor =>

      widget.primaryColor ?? Theme.of(context).primaryColor;      widget.primaryColor ?? Theme.of(context).primaryColor;



  @override  @override

  Widget build(BuildContext context) {  Widget build(BuildContext context) {

    return Container(    return Container(

      margin: widget.margin ?? const EdgeInsets.only(bottom: 12),      margin: widget.margin ?? const EdgeInsets.only(bottom: 12),

      height: 64, // Fixed compact height      height: 64, // Fixed compact height

      child: Material(      child: Material(

        elevation: 1,        elevation: 1,

        borderRadius: BorderRadius.circular(16),        borderRadius: BorderRadius.circular(16),

        color: Colors.transparent,        color: Colors.transparent,

        child: Container(        child: Container(

          decoration: BoxDecoration(          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(16),            borderRadius: BorderRadius.circular(16),

            color: Theme.of(context).colorScheme.surface,            color: Theme.of(context).colorScheme.surface,

            border: Border.all(            border: Border.all(

              color: _primaryColor.withOpacity(0.1),              color: _primaryColor.withOpacity(0.1),

              width: 1,              width: 1,

            ),            ),

            boxShadow: [            boxShadow: [

              BoxShadow(              BoxShadow(

                color: Colors.black.withOpacity(0.03),                color: Colors.black.withOpacity(0.03),

                blurRadius: 8,                blurRadius: 8,

                offset: const Offset(0, 2),                offset: const Offset(0, 2),

              ),              ),

            ],            ],

          ),          ),

          child: _buildCompactSingleRow(context),          child: _buildCompactSingleRow(context),

        ),        ),

      ),      ),

    );    );

  }  }



  /// Build a compact single-row filter layout  /// Build a compact single-row filter layout

  Widget _buildCompactSingleRow(BuildContext context) {  Widget _buildCompactSingleRow(BuildContext context) {

    return Padding(    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Row(      child: Row(

        children: [        children: [

          // Time Frame Selector - Pills style          // Time Frame Selector - Pills style

          Expanded(          Expanded(

            flex: 3,            flex: 3,

            child: _buildCompactTimeFrameSelector(context),            child: _buildCompactTimeFrameSelector(context),

          ),          ),

          const SizedBox(width: 12),          const SizedBox(width: 12),

                    

          // Metric Selector - Dropdown style          // Metric Selector - Dropdown style

          Expanded(          Expanded(

            flex: 2,            flex: 2,

            child: _buildCompactMetricSelector(context),            child: _buildCompactMetricSelector(context),

          ),          ),

          const SizedBox(width: 12),          const SizedBox(width: 12),

                    

          // Advanced filters button (Sector/Market Cap)          // Advanced filters button (Sector/Market Cap)

          _buildAdvancedButton(context),          _buildAdvancedButton(context),

                    

          // Reset button          // Reset button

          if (widget.showResetButton) ...[          if (widget.showResetButton) ...[

            const SizedBox(width: 8),            const SizedBox(width: 8),

            _buildCompactResetButton(context),            _buildCompactResetButton(context),

          ],          ],

        ],        ],

      ),      ),

    );    );

  }  }



  /// Build compact time frame selector with pills  /// Build compact time frame selector with pills

  Widget _buildCompactTimeFrameSelector(BuildContext context) {  Widget _buildCompactTimeFrameSelector(BuildContext context) {

    final timeFrames = [TimeFrame.oneDay, TimeFrame.oneWeek, TimeFrame.oneMonth, TimeFrame.threeMonths, TimeFrame.oneYear];    final timeFrames = [TimeFrame.oneDay, TimeFrame.oneWeek, TimeFrame.oneMonth, TimeFrame.threeMonths, TimeFrame.oneYear];

        

    return SingleChildScrollView(    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,      scrollDirection: Axis.horizontal,

      child: Row(      child: Row(

        children: timeFrames.map<Widget>((timeFrame) {        children: timeFrames.map((timeFrame) {

          final isSelected = widget.config.selectedTimeFrame == timeFrame;          final isSelected = widget.config.selectedTimeFrame == timeFrame;

          return Padding(          return Padding(

            padding: const EdgeInsets.only(right: 8),            padding: const EdgeInsets.only(right: 8),

            child: InkWell(            child: InkWell(

              onTap: () => widget.callbacks.onTimeFrameChanged(timeFrame),              onTap: () => widget.callbacks.onTimeFrameChanged(timeFrame),

              borderRadius: BorderRadius.circular(20),              borderRadius: BorderRadius.circular(20),

              child: Container(              child: Container(

                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                decoration: BoxDecoration(                decoration: BoxDecoration(

                  color: isSelected ? _primaryColor : Colors.transparent,                  color: isSelected ? _primaryColor : Colors.transparent,

                  borderRadius: BorderRadius.circular(20),                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(                  border: Border.all(

                    color: isSelected ? _primaryColor : _primaryColor.withOpacity(0.3),                    color: isSelected ? _primaryColor : _primaryColor.withOpacity(0.3),

                    width: 1,                    width: 1,

                  ),                  ),

                ),                ),

                child: Text(                child: Text(

                  timeFrame.displayName,                  timeFrame.displayName,

                  style: TextStyle(                  style: TextStyle(

                    color: isSelected ? Colors.white : _primaryColor,                    color: isSelected ? Colors.white : _primaryColor,

                    fontSize: 12,                    fontSize: 12,

                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,

                  ),                  ),

                ),                ),

              ),              ),

            ),            ),

          );          );

        }).toList(),        }).toList(),

      ),      ),

    );    );

  }  }



  /// Build compact metric selector dropdown  /// Build compact metric selector dropdown

  Widget _buildCompactMetricSelector(BuildContext context) {  Widget _buildCompactMetricSelector(BuildContext context) {

    return Container(    return Container(

      height: 40,      height: 40,

      padding: const EdgeInsets.symmetric(horizontal: 12),      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(      decoration: BoxDecoration(

        color: _primaryColor.withOpacity(0.05),        color: _primaryColor.withOpacity(0.05),

        borderRadius: BorderRadius.circular(12),        borderRadius: BorderRadius.circular(12),

        border: Border.all(        border: Border.all(

          color: _primaryColor.withOpacity(0.2),          color: _primaryColor.withOpacity(0.2),

          width: 1,          width: 1,

        ),        ),

      ),      ),

      child: DropdownButtonHideUnderline(      child: DropdownButtonHideUnderline(

        child: DropdownButton<MetricType>(        child: DropdownButton<MetricType>(

          value: widget.config.selectedMetric,          value: widget.config.selectedMetric,

          isExpanded: true,          isExpanded: true,

          icon: Icon(Icons.expand_more, color: _primaryColor, size: 18),          icon: Icon(Icons.expand_more, color: _primaryColor, size: 18),

          style: TextStyle(          style: TextStyle(

            color: _primaryColor,            color: _primaryColor,

            fontSize: 13,            fontSize: 13,

            fontWeight: FontWeight.w500,            fontWeight: FontWeight.w500,

          ),          ),

          items: MetricType.heatmapMetrics.map((metric) {          items: MetricType.heatmapMetrics.map((metric) {

            return DropdownMenuItem<MetricType>(            return DropdownMenuItem<MetricType>(

              value: metric,              value: metric,

              child: Row(              child: Row(

                children: [                children: [

                  Icon(metric.icon, size: 14, color: _primaryColor.withOpacity(0.7)),                  Icon(metric.icon, size: 14, color: _primaryColor.withOpacity(0.7)),

                  const SizedBox(width: 6),                  const SizedBox(width: 6),

                  Text(metric.shortName),                  Text(metric.shortName),

                ],                ],

              ),              ),

            );            );

          }).toList(),          }).toList(),

          onChanged: (value) {          onChanged: (value) {

            if (value != null) {            if (value != null) {

              widget.callbacks.onMetricChanged(value);              widget.callbacks.onMetricChanged(value);

            }            }

          },          },

        ),        ),

      ),      ),

    );    );

  }  }



  /// Build advanced filters button  /// Build advanced filters button

  Widget _buildAdvancedButton(BuildContext context) {  Widget _buildAdvancedButton(BuildContext context) {

    final hasAdvancedFilters = widget.config.selectedSector != SectorType.all ||     final hasAdvancedFilters = widget.config.selectedSector != SectorType.all || 

                             widget.config.selectedMarketCap != MarketCapType.all;                             widget.config.selectedMarketCap != MarketCapType.all;

        

    return InkWell(    return InkWell(

      onTap: () => _showAdvancedFiltersDialog(context),      onTap: () => _showAdvancedFiltersDialog(context),

      borderRadius: BorderRadius.circular(12),      borderRadius: BorderRadius.circular(12),

      child: Container(      child: Container(

        width: 40,        width: 40,

        height: 40,        height: 40,

        decoration: BoxDecoration(        decoration: BoxDecoration(

          color: hasAdvancedFilters ? _primaryColor.withOpacity(0.1) : Colors.transparent,          color: hasAdvancedFilters ? _primaryColor.withOpacity(0.1) : Colors.transparent,

          borderRadius: BorderRadius.circular(12),          borderRadius: BorderRadius.circular(12),

          border: Border.all(          border: Border.all(

            color: hasAdvancedFilters ? _primaryColor : _primaryColor.withOpacity(0.3),            color: hasAdvancedFilters ? _primaryColor : _primaryColor.withOpacity(0.3),

            width: 1,            width: 1,

          ),          ),

        ),        ),

        child: Stack(        child: Stack(

          children: [          children: [

            Center(            Center(

              child: Icon(              child: Icon(

                Icons.tune,                Icons.tune,

                color: hasAdvancedFilters ? _primaryColor : _primaryColor.withOpacity(0.7),                color: hasAdvancedFilters ? _primaryColor : _primaryColor.withOpacity(0.7),

                size: 18,                size: 18,

              ),              ),

            ),            ),

            if (hasAdvancedFilters)            if (hasAdvancedFilters)

              Positioned(              Positioned(

                top: 6,                top: 6,

                right: 6,                right: 6,

                child: Container(                child: Container(

                  width: 8,                  width: 8,

                  height: 8,                  height: 8,

                  decoration: BoxDecoration(                  decoration: BoxDecoration(

                    color: _primaryColor,                    color: _primaryColor,

                    shape: BoxShape.circle,                    shape: BoxShape.circle,

                  ),                  ),

                ),                ),

              ),              ),

          ],          ],

        ),        ),

      ),      ),

    );    );

  }  }



  /// Build compact reset button  /// Show advanced filters in a dialog

  Widget _buildCompactResetButton(BuildContext context) {  void _showAdvancedFiltersDialog(BuildContext context) {

    return InkWell(    showDialog(

      onTap: widget.onReset,      context: context,

      borderRadius: BorderRadius.circular(12),      builder: (context) => AlertDialog(

      child: Container(        title: Text('Advanced Filters'),

        width: 40,        content: Column(

        height: 40,          mainAxisSize: MainAxisSize.min,

        decoration: BoxDecoration(          children: [

          color: Colors.transparent,            // Sector selector

          borderRadius: BorderRadius.circular(12),            SectorSelector(

          border: Border.all(              selectedSector: widget.config.selectedSector,

            color: _primaryColor.withOpacity(0.3),              onSectorChanged: (value) => widget.callbacks.onSectorChanged(value),

            width: 1,              compact: true,

          ),            ),

        ),            const SizedBox(height: 16),

        child: Icon(            // Market Cap selector

          Icons.refresh,            MarketCapSelector(

          color: _primaryColor.withOpacity(0.7),              selectedMarketCap: widget.config.selectedMarketCap,

          size: 18,              onMarketCapChanged: (value) => widget.callbacks.onMarketCapChanged(value),

        ),              compact: true,

      ),            ),

    );          ],

  }        ),

        actions: [

  /// Show advanced filters in a dialog          TextButton(

  void _showAdvancedFiltersDialog(BuildContext context) {            onPressed: () {

    showDialog(              widget.callbacks.onSectorChanged(SectorType.all);

      context: context,              widget.callbacks.onMarketCapChanged(MarketCapType.all);

      builder: (context) => AlertDialog(              Navigator.of(context).pop();

        title: Text('Advanced Filters'),            },

        content: Column(            child: Text('Reset'),

          mainAxisSize: MainAxisSize.min,          ),

          children: [          TextButton(

            // Sector selector            onPressed: () => Navigator.of(context).pop(),

            SectorSelector(            child: Text('Done'),

              selectedSector: widget.config.selectedSector,          ),

              onSectorChanged: (value) => widget.callbacks.onSectorChanged(value),        ],

              compact: true,      ),

            ),    );

            const SizedBox(height: 16),  }

            // Market Cap selector

            MarketCapSelector(  /// Build compact reset button

              selectedMarketCap: widget.config.selectedMarketCap,  Widget _buildCompactResetButton(BuildContext context) {

              onMarketCapChanged: (value) => widget.callbacks.onMarketCapChanged(value),    return InkWell(

              compact: true,      onTap: widget.onReset,

            ),      borderRadius: BorderRadius.circular(12),

          ],      child: Container(

        ),        width: 40,

        actions: [        height: 40,

          TextButton(        decoration: BoxDecoration(

            onPressed: () {          color: Colors.transparent,

              widget.callbacks.onSectorChanged(SectorType.all);          borderRadius: BorderRadius.circular(12),

              widget.callbacks.onMarketCapChanged(MarketCapType.all);          border: Border.all(

              Navigator.of(context).pop();            color: _primaryColor.withOpacity(0.3),

            },            width: 1,

            child: Text('Reset'),          ),

          ),        ),

          TextButton(        child: Icon(

            onPressed: () => Navigator.of(context).pop(),          Icons.refresh,

            child: Text('Done'),          color: _primaryColor.withOpacity(0.7),

          ),          size: 18,

        ],        ),

      ),      ),

    );    );

  }  }

}}
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
