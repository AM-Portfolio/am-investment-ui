import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../features/portfolio/internal/domain/entities/portfolio_holding.dart';
import '../../../../features/portfolio/providers/portfolio_providers.dart';
import '../configs/holdings_display_config.dart';
import '../core/holdings_selector_core.dart';
import 'holdings_template_factory.dart';

/// Universal holdings widget with template-based architecture
/// Follows the pattern from UniversalHeatmapWidget
class UniversalHoldingsWidget extends ConsumerStatefulWidget {
  const UniversalHoldingsWidget({
    required this.userId,
    super.key,
    this.portfolioId,
    this.config,
    this.templateType = HoldingsTemplateType.adaptive,
    this.title,
    this.onHoldingTap,
  });

  final String userId;
  final String? portfolioId;
  final HoldingsDisplayConfig? config;
  final HoldingsTemplateType templateType;
  final String? title;
  final ValueChanged<PortfolioHolding>? onHoldingTap;

  @override
  ConsumerState<UniversalHoldingsWidget> createState() =>
      _UniversalHoldingsWidgetState();
}

class _UniversalHoldingsWidgetState
    extends ConsumerState<UniversalHoldingsWidget> {
  late HoldingsSelectorCore _core;
  late HoldingsDisplayConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? HoldingsDisplayConfig.web();
    _core = HoldingsSelectorCore(
      initialSortBy: _config.defaultSortBy,
      initialDisplayFormat: _config.defaultDisplayFormat,
      initialChangeType: _config.defaultChangeType,
      initialViewMode: _config.defaultViewMode,
      initialSortAscending: _config.defaultSortAscending,
      onFiltersChanged: _onFiltersChanged,
    );

    AppLogger.debug(
      'UniversalHoldingsWidget: initialized for userId=${widget.userId}, portfolioId=${widget.portfolioId}',
      tag: 'UniversalHoldings',
    );
  }

  void _onFiltersChanged({
    HoldingsSortBy? sortBy,
    HoldingsDisplayFormat? displayFormat,
    HoldingsChangeType? changeType,
    HoldingsViewMode? viewMode,
    bool? sortAscending,
    String? sectorFilter,
  }) {
    AppLogger.debug(
      'Holdings filters changed',
      tag: 'UniversalHoldings',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _core.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the appropriate provider based on portfolioId
    final holdingsAsync = widget.portfolioId != null
        ? ref.watch(
            portfolioHoldingsByIdProvider(widget.userId, widget.portfolioId!),
          )
        : ref.watch(portfolioHoldingsProvider(widget.userId));

    return holdingsAsync.when(
      data: (portfolioHoldings) {
        AppLogger.debug(
          'Holdings data loaded: ${portfolioHoldings.holdings.length} holdings',
          tag: 'UniversalHoldings',
        );

        // Create display widget
        final displayWidget = HoldingsTemplateFactory.createDisplayTemplate(
          holdings: portfolioHoldings.holdings,
          core: _core,
          isLoading: false,
          onHoldingTap: widget.onHoldingTap,
        );

        // Create selector widget if enabled
        final selectorWidget = HoldingsTemplateFactory.createSelectorWidget(
          config: _config,
          core: _core,
        );

        // Create layout template
        return HoldingsTemplateFactory.createLayoutTemplate(
          context: context,
          templateType: widget.templateType,
          config: _config,
          holdings: portfolioHoldings.holdings,
          core: _core,
          displayWidget: displayWidget,
          selectorWidget: selectorWidget,
          title: widget.title,
        );
      },
      loading: () {
        AppLogger.debug(
          'Holdings loading',
          tag: 'UniversalHoldings',
        );

        return HoldingsTemplateFactory.createDisplayTemplate(
          holdings: const [],
          core: _core,
          isLoading: true,
        );
      },
      error: (error, stackTrace) {
        AppLogger.error(
          'Holdings error: $error',
          tag: 'UniversalHoldings',
          error: error,
          stackTrace: stackTrace,
        );

        return HoldingsTemplateFactory.createDisplayTemplate(
          holdings: const [],
          core: _core,
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }
}
