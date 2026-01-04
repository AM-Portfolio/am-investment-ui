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
import '../../../../shared/widgets/selectors/shared_portfolio_selector.dart';
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
    this.onBack,
  });
  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final List<PortfolioItem>? portfolios;
  final Function(String portfolioId, String portfolioName)? onPortfolioChanged;
  final bool isSidebarVisible;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onBack;

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


  @override
  Widget build(BuildContext context) { 
      return UnifiedSidebarScaffold(
        module: ModuleType.portfolio,
        subtitle: widget.selectedPortfolioName ?? 'My Portfolio',
        onBackToGlobal: widget.onBack,
        body: _buildMainContent(context),
        sections: [
          // Portfolio Selector Section
          if (widget.portfolios != null && widget.portfolios!.isNotEmpty)
            SecondarySidebarSection(
              title: 'Portfolio',
              customWidget: SharedPortfolioSelector<PortfolioItem>(
                currentPortfolioId: _currentPortfolioId,
                currentPortfolioName: widget.selectedPortfolioName,
                portfolios: widget.portfolios!,
                onPortfolioSelected: _onPortfolioChanged,
                idExtractor: (p) => p.portfolioId,
                nameExtractor: (p) => p.portfolioName,
                // Accent color will be handled by module theme
              ),
            ),
          
          // Navigation Section
          SecondarySidebarSection(
            title: 'Navigation',
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
          ),
        ],
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
