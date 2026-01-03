import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:am_common_ui/am_common_ui.dart';

import '../../../../core/utils/logger.dart';
import '../../internal/domain/entities/portfolio_list.dart';
import '../../providers/portfolio_providers.dart';
import '../cubit/portfolio_analytics_cubit.dart';
import '../cubit/portfolio_heatmap_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../widgets/portfolio_sidebar.dart';
import 'pages/portfolio_overview_web_page.dart';
import 'pages/portfolio_holdings_web_page.dart';
import 'pages/portfolio_analysis_web_page.dart';
import 'pages/portfolio_heatmap_web_page.dart';

/// Web-specific portfolio screen implementation
class PortfolioWebScreen extends ConsumerStatefulWidget {
  const PortfolioWebScreen({
    required this.userId,
    super.key,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.portfolios,
    this.onPortfolioChanged,
    this.isSidebarVisible = true,
    this.onToggleSidebar,
  });
  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;
  final bool isSidebarVisible;
  final VoidCallback? onToggleSidebar;

  @override
  ConsumerState<PortfolioWebScreen> createState() => _PortfolioWebScreenState();
}

class _PortfolioWebScreenState extends ConsumerState<PortfolioWebScreen> {
  PortfolioViewType _selectedView = PortfolioViewType.overview;
  String? _currentPortfolioId;

  @override
  void initState() {
    super.initState();
    _currentPortfolioId = widget.selectedPortfolioId ?? widget.userId;
  }

  void _onPortfolioChanged(String portfolioId, String portfolioName) {
    setState(() {
      _currentPortfolioId = portfolioId;
    });

    // Invalidate providers to refresh data - use userId for API calls
    ref.invalidate(portfolioSummaryProvider(widget.userId));
    ref.invalidate(portfolioHoldingsProvider(widget.userId));

    // Notify parent if callback is provided
    widget.onPortfolioChanged?.call(portfolioId, portfolioName);
  }

  bool _useNewSidebar = false;

  @override
  Widget build(BuildContext context) { 
    if (_useNewSidebar) {
      return UnifiedSidebarScaffold(
        title: 'Portfolio',
        subtitle: widget.selectedPortfolioName ?? 'My Portfolio',
        icon: Icons.pie_chart_rounded,
        accentColor: ModuleColors.portfolio,
        body: _buildMainContent(context),
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              _useNewSidebar = false;
            });
          },
          backgroundColor: Theme.of(context).cardColor,
          child: const Icon(Icons.undo_rounded),
        ),
        items: [
           SecondarySidebarItem(
            title: 'Overview',
            icon: Icons.dashboard_outlined,
            isSelected: _selectedView == PortfolioViewType.overview,
            onTap: () => setState(() => _selectedView = PortfolioViewType.overview),
          ),
          SecondarySidebarItem(
            title: 'Holdings',
            icon: Icons.list_alt_rounded,
            isSelected: _selectedView == PortfolioViewType.holdings,
            onTap: () => setState(() => _selectedView = PortfolioViewType.holdings),
          ),
          SecondarySidebarItem(
            title: 'Analysis',
            icon: Icons.donut_large_outlined,
            isSelected: _selectedView == PortfolioViewType.analysis,
            onTap: () => setState(() => _selectedView = PortfolioViewType.analysis),
          ),
          SecondarySidebarItem(
            title: 'Heatmap',
            icon: Icons.grid_view_rounded,
            isSelected: _selectedView == PortfolioViewType.heatmap,
            onTap: () => setState(() => _selectedView = PortfolioViewType.heatmap),
          ),
        ],
      );
    }

    return Scaffold(
    appBar: null, // Hidden as per user request for cleaner UI
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _useNewSidebar = true;
          });
        },
        tooltip: 'Switch to New Sidebar',
        child: const Icon(Icons.auto_awesome),
      ),
    /* AppBar(
      title: Text(widget.selectedPortfolioName ?? 'Portfolio'),
      actions: [
        // Portfolio selector dropdown
        if (widget.portfolios != null && widget.portfolios!.length > 1)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _currentPortfolioId,
              icon: const Icon(Icons.arrow_drop_down),
              underline: Container(),
              items: widget.portfolios!
                  .map<DropdownMenuItem<String>>(
                    (portfolio) => DropdownMenuItem<String>(
                      value: portfolio.portfolioId,
                      child: Text(
                        portfolio.portfolioName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  final selectedPortfolio = widget.portfolios!.firstWhere(
                    (p) => p.portfolioId == newValue,
                  );
                  _onPortfolioChanged(
                    newValue,
                    selectedPortfolio.portfolioName,
                  );
                }
              },
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(portfolioSummaryProvider(widget.userId));
            ref.invalidate(portfolioHoldingsProvider(widget.userId));
          },
        ),
      ],
    ), */
    body: Row(
      children: [
        // Left sidebar for navigation
        LayoutBuilder(
          builder: (context, constraints) {
            // Determine if sidebar should be compact based on screen width
            // Using 1200 as breakpoint for "minimized" view preference
            final screenWidth = MediaQuery.of(context).size.width;
            final isCompact = screenWidth < 1200;
            final sidebarWidth = widget.isSidebarVisible 
                ? (isCompact ? 72.0 : 250.0) 
                : 0.0;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: sidebarWidth,
              curve: Curves.easeInOut,
              child: OverflowBox(
                minWidth: isCompact ? 72 : 250,
                maxWidth: isCompact ? 72 : 250,
                alignment: Alignment.centerLeft,
                child: Container(
                  width: isCompact ? 72 : 250,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: PortfolioSidebar(
                    selectedView: _selectedView,
                    onViewChanged: (viewType) {
                      setState(() {
                        _selectedView = viewType;
                      });
                    },
                    currentPortfolioId: _currentPortfolioId,
                    currentPortfolioName: widget.selectedPortfolioName,
                    portfolios: widget.portfolios ?? [],
                    onPortfolioSelected: widget.onPortfolioChanged,
                    isCompact: isCompact,
                  ),
                ),
              ),
            );
          },
        ),
        // Main content area
        Expanded(child: _buildMainContent(context)),
      ],
    ),
  );
  }

  /// Build main content based on selected view
  Widget _buildMainContent(BuildContext context) {
    switch (_selectedView) {
      case PortfolioViewType.overview:
        return _buildOverviewContent(context);
      case PortfolioViewType.holdings:
        return _buildHoldingsContent(context);
      case PortfolioViewType.analysis:
        return _buildAnalysisContent(context);
      case PortfolioViewType.heatmap:
        return _buildHeatmapContent(context);
      default:
        // Fallback to overview if any other view is selected
        return _buildOverviewContent(context);
    }
  }

  /// Build overview content using dedicated overview page
  Widget _buildOverviewContent(BuildContext context) {
    return PortfolioOverviewWebPage(
      userId: widget.userId,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build holdings content using dedicated holdings page
  Widget _buildHoldingsContent(BuildContext context) {
    return PortfolioHoldingsWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build analysis content using dedicated analysis page
  Widget _buildAnalysisContent(BuildContext context) {
    return PortfolioAnalysisWebPage(
      userId: widget.userId,
      portfolioId: _currentPortfolioId!,
      portfolioName: widget.selectedPortfolioName,
    );
  }

  /// Build heatmap content using dedicated heatmap page
  Widget _buildHeatmapContent(BuildContext context) {
    AppLogger.debug(
      'Building heatmap content with analytics and heatmap cubits',
      tag: 'PortfolioWebScreen',
    );

    final analyticsServiceAsync = ref.watch(portfolioAnalyticsServiceProvider);

    return analyticsServiceAsync.when(
      data: (analyticsService) {
        AppLogger.info(
          'Analytics service loaded, creating cubits',
          tag: 'PortfolioWebScreen',
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                AppLogger.info(
                  'Creating PortfolioAnalyticsCubit',
                  tag: 'PortfolioWebScreen',
                );
                return PortfolioAnalyticsCubit(analyticsService);
              },
            ),
            BlocProvider(
              create: (context) {
                AppLogger.info(
                  'Creating PortfolioHeatmapCubit',
                  tag: 'PortfolioWebScreen',
                );
                return PortfolioHeatmapCubit();
              },
            ),
          ],
          child: PortfolioHeatmapWebPage(
            userId: widget.userId,
            portfolioId: _currentPortfolioId!,
            portfolioName: widget.selectedPortfolioName,
          ),
        );
      },
      loading: () {
        AppLogger.debug(
          'Analytics service loading...',
          tag: 'PortfolioWebScreen',
        );
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        AppLogger.error(
          'Failed to load analytics service',
          tag: 'PortfolioWebScreen',
          error: error,
          stackTrace: stack,
        );
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load analytics service: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(portfolioAnalyticsServiceProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
