import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../providers/trade_internal_providers.dart';
import '../calendar/pages/trade_calendar_analytics_web_page.dart';
import '../components/templates/trade_portfolio_discovery_template.dart';
import '../holdings/pages/trade_holdings_dashboard_web_page.dart';
import '../journal/pages/journal_web_page.dart';
import '../models/trade_portfolio_view_model.dart';
import '../trades/pages/trade_list_web_page.dart';
import 'widgets/trade_sidebar.dart';

/// Trade view types for navigation
enum TradeViewType { portfolios, holdings, calendar, trades, journal }

/// Web-specific trade screen implementation with sidebar navigation
class TradeWebScreen extends ConsumerStatefulWidget {
  const TradeWebScreen({
    required this.userId,
    super.key,
    this.selectedPortfolioId,
    this.selectedPortfolioName,
    this.initialView = TradeViewType.portfolios,
    this.isSidebarVisible = true,
    this.onToggleSidebar,
  });

  final String userId;
  final String? selectedPortfolioId;
  final String? selectedPortfolioName;
  final TradeViewType initialView;
  final bool isSidebarVisible;
  final VoidCallback? onToggleSidebar;

  @override
  ConsumerState<TradeWebScreen> createState() => _TradeWebScreenState();
}

class _TradeWebScreenState extends ConsumerState<TradeWebScreen> {
  late TradeViewType _selectedView;
  String? _currentPortfolioId;
  String? _currentPortfolioName;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.initialView;
    _currentPortfolioId = widget.selectedPortfolioId;
    _currentPortfolioName = widget.selectedPortfolioName;

    // CRITICAL: Validate userId is not empty
    AppLogger.debug(
      '🔍 TradeWebScreen.initState() called with userId: "${widget.userId}" (length: ${widget.userId.length})',
      tag: 'TradeWebScreen',
    );

    if (widget.userId.isEmpty) {
      AppLogger.error(
        '🚨 CRITICAL: TradeWebScreen initialized with EMPTY userId! This should NOT happen!',
        tag: 'TradeWebScreen',
      );
      AppLogger.error(
        '🔎 Debug info - view: $_selectedView, portfolioId: $_currentPortfolioId, portfolioName: $_currentPortfolioName',
        tag: 'TradeWebScreen',
      );
    } else {
      AppLogger.info(
        '✅ TradeWebScreen initialized successfully - userId: "${widget.userId}", view: $_selectedView',
        tag: 'TradeWebScreen',
      );
    }
  }

  void _onViewChanged(TradeViewType viewType) {
    setState(() {
      _selectedView = viewType;
    });

    AppLogger.info('Trade view changed to: $viewType', tag: 'TradeWebScreen');
  }

  void _onPortfolioSelected(String portfolioId, String portfolioName) {
    final previousPortfolioId = _currentPortfolioId;
    final wasOnHoldingsOrCalendar = _selectedView == TradeViewType.holdings || _selectedView == TradeViewType.calendar;

    setState(() {
      _currentPortfolioId = portfolioId;
      _currentPortfolioName = portfolioName;

      // If we're on holdings or calendar and changing to a different portfolio,
      // stay on current view to show the new portfolio's data
      // Otherwise, go to portfolios view
      if (wasOnHoldingsOrCalendar && previousPortfolioId != null && previousPortfolioId != portfolioId) {
        // Stay on current view, data will refresh automatically with new portfolio
      } else if (!wasOnHoldingsOrCalendar) {
        // Not on holdings/calendar, go to portfolios view
        _selectedView = TradeViewType.portfolios;
      }
    });

    AppLogger.info('Portfolio selected: $portfolioName ($portfolioId)', tag: 'TradeWebScreen');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    // Watch portfolios stream
    final portfoliosAsyncValue = ref.watch(tradePortfoliosStreamProvider(widget.userId));

    return Scaffold(
      appBar: _buildAppBar(context),
      // Drawer for mobile
      drawer: isMobile
          ? Drawer(
              child: portfoliosAsyncValue.when(
                data: (portfolios) => TradeSidebar(
                  selectedView: _selectedView,
                  onViewChanged: (viewType) {
                    _onViewChanged(viewType);
                    Navigator.pop(context); // Close drawer after selection
                  },
                  currentPortfolioId: _currentPortfolioId,
                  currentPortfolioName: _currentPortfolioName,
                  portfolios: portfolios,
                  onPortfolioSelected: _onPortfolioSelected,
                ),
                loading: () => TradeSidebar(
                  selectedView: _selectedView,
                  onViewChanged: (viewType) {
                    _onViewChanged(viewType);
                    Navigator.pop(context); // Close drawer after selection
                  },
                  currentPortfolioId: _currentPortfolioId,
                  currentPortfolioName: _currentPortfolioName,
                ),
                error: (_, __) => TradeSidebar(
                  selectedView: _selectedView,
                  onViewChanged: (viewType) {
                    _onViewChanged(viewType);
                    Navigator.pop(context); // Close drawer after selection
                  },
                  currentPortfolioId: _currentPortfolioId,
                  currentPortfolioName: _currentPortfolioName,
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          // Left sidebar for desktop only with responsive width
          if (!isMobile)
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive sidebar width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                double sidebarWidth;

                if (screenWidth < 1000) {
                  sidebarWidth = 60; // Icon-only mode
                } else if (screenWidth < 1400) {
                  sidebarWidth = 150; // Condensed mode
                } else {
                  sidebarWidth = 280; // Full mode
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.isSidebarVisible ? sidebarWidth : 0,
                  curve: Curves.easeInOut,
                  child: OverflowBox(
                    minWidth: sidebarWidth,
                    maxWidth: sidebarWidth,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: sidebarWidth,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                        color: Theme.of(context).cardColor,
                      ),
                      child: portfoliosAsyncValue.when(
                        data: (portfolios) => TradeSidebar(
                          selectedView: _selectedView,
                          onViewChanged: _onViewChanged,
                          currentPortfolioId: _currentPortfolioId,
                          currentPortfolioName: _currentPortfolioName,
                          portfolios: portfolios,
                          onPortfolioSelected: _onPortfolioSelected,
                        ),
                        loading: () => TradeSidebar(
                          selectedView: _selectedView,
                          onViewChanged: _onViewChanged,
                          currentPortfolioId: _currentPortfolioId,
                          currentPortfolioName: _currentPortfolioName,
                        ),
                        error: (_, __) => TradeSidebar(
                          selectedView: _selectedView,
                          onViewChanged: _onViewChanged,
                          currentPortfolioId: _currentPortfolioId,
                          currentPortfolioName: _currentPortfolioName,
                        ),
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

  /// Build app bar with context-aware title and actions
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    var title = 'Trade Analysis';
    var showTitle = true;

    switch (_selectedView) {
      case TradeViewType.portfolios:
        title = 'Portfolio Discovery';
        showTitle = false; // Hide title for portfolios view - title is in the content
        break;
      case TradeViewType.holdings:
        title = 'Holdings';
        showTitle = false; // Hide title - portfolio info is in sidebar
        break;
      case TradeViewType.calendar:
        title = _currentPortfolioName != null
            ? 'Calendar Analytics - $_currentPortfolioName'
            : 'Trade Calendar Analytics';
        break;
      case TradeViewType.trades:
        title = 'All Trades';
        showTitle = false; // Hide title - will be in content
        break;
      case TradeViewType.journal:
        title = 'Trade Journal';
        showTitle = false; // Custom header in page
        break;
    }

    return AppBar(
      // Automatically shows menu button on mobile when drawer is present
      toolbarHeight: showTitle && _selectedView != TradeViewType.calendar
          ? kToolbarHeight
          : 0, // Hide app bar completely when no title or in calendar view
      title: showTitle && _selectedView != TradeViewType.calendar
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: isMobile ? const TextStyle(fontSize: 16) : null,
                  ),
                ),
              ],
            )
          : null,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      actions: showTitle && _selectedView != TradeViewType.calendar
          ? [
              // Back to portfolios button (when portfolio is selected)
              if (_currentPortfolioId != null && _selectedView != TradeViewType.portfolios)
                isMobile
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back to Portfolios',
                        onPressed: () {
                          setState(() {
                            _selectedView = TradeViewType.portfolios;
                            _currentPortfolioId = null;
                            _currentPortfolioName = null;
                          });
                        },
                      )
                    : TextButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Portfolios'),
                        onPressed: () {
                          setState(() {
                            _selectedView = TradeViewType.portfolios;
                            _currentPortfolioId = null;
                            _currentPortfolioName = null;
                          });
                        },
                      ),

              // Refresh button - hidden for portfolios view (refresh is in the content header)
              if (_selectedView != TradeViewType.portfolios)
                Consumer(
                  builder: (context, ref, child) => IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Data',
                    onPressed: () {
                      AppLogger.info('Refreshing trade data for view: $_selectedView', tag: 'TradeWebScreen');

                      // Invalidate relevant providers based on current view
                      switch (_selectedView) {
                        case TradeViewType.portfolios:
                          ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
                          break;
                        case TradeViewType.holdings:
                          if (_currentPortfolioId != null) {
                            final params = (userId: widget.userId, portfolioId: _currentPortfolioId!);
                            ref.invalidate(tradeHoldingsStreamProvider(params));
                            ref.invalidate(tradeSummaryStreamProvider(params));
                          }
                          break;
                        case TradeViewType.calendar:
                          if (_currentPortfolioId != null) {
                            final params = (userId: widget.userId, portfolioId: _currentPortfolioId!);
                            ref.invalidate(tradeCalendarStreamProvider(params));
                          }
                          break;
                        case TradeViewType.trades:
                          if (_currentPortfolioId != null) {
                            final params = (userId: widget.userId, portfolioId: _currentPortfolioId!);
                            ref.invalidate(tradeHoldingsStreamProvider(params));
                          }
                          break;
                        case TradeViewType.journal:
                          // Journal doesn't use providers, no refresh needed
                          break;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Refreshing ${_selectedView.name} data...'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  /// Build main content based on selected view
  Widget _buildMainContent(BuildContext context) {
    switch (_selectedView) {
      case TradeViewType.portfolios:
        return _buildPortfoliosView();

      case TradeViewType.holdings:
        if (_currentPortfolioId == null) {
          return _buildSelectPortfolioPrompt();
        }
        return TradeHoldingsDashboardWebPage(
          key: ValueKey('holdings_$_currentPortfolioId'),
          userId: widget.userId,
          portfolioId: _currentPortfolioId!,
        );

      case TradeViewType.calendar:
        if (_currentPortfolioId == null) {
          return _buildSelectPortfolioPrompt();
        }
        return TradeCalendarAnalyticsWebPage(
          key: ValueKey('calendar_$_currentPortfolioId'),
          userId: widget.userId,
          portfolioId: _currentPortfolioId!,
        );

      case TradeViewType.trades:
        if (_currentPortfolioId == null) {
          return _buildSelectPortfolioPrompt();
        }
        return TradeListWebPage(
          key: ValueKey('trades_$_currentPortfolioId'),
          userId: widget.userId,
          portfolioId: _currentPortfolioId!,
        );

      case TradeViewType.journal:
        return JournalWebPage(userId: widget.userId, portfolioId: _currentPortfolioId);
    }
  }

  /// Build portfolios view with integrated navigation
  Widget _buildPortfoliosView() {
    // Show error if userId is empty
    if (widget.userId.isEmpty) {
      return Consumer(
        builder: (context, ref, child) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Authentication Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('User ID is missing. Please log in again.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Force logout and navigate to login
                  context.read<AuthCubit>().logout();
                },
                child: const Text('Log In Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final portfoliosAsync = ref.watch(tradePortfoliosStreamProvider(widget.userId));

        return portfoliosAsync.when(
          data: (portfolios) {
            // Auto-select first portfolio if none selected and portfolios exist
            // But only if we are in the portfolios view (initial load)
            if (_currentPortfolioId == null && portfolios.isNotEmpty && _selectedView == TradeViewType.portfolios) {
              // Schedule the state update to avoid build-phase errors
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _onPortfolioSelected(portfolios.first.id, portfolios.first.name);
                }
              });
            }

            return TradePortfolioDiscoveryTemplate(
              portfolios: portfolios,
              isLoading: false,
              onPortfolioSelected: (portfolio) {
                // When clicking a portfolio card, select it and go to holdings
                setState(() {
                  _currentPortfolioId = portfolio.id;
                  _currentPortfolioName = portfolio.name;
                  _selectedView = TradeViewType.holdings;
                });
              },
              onRefresh: () {
                ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => TradePortfolioDiscoveryTemplate(
            portfolios: const <TradePortfolioViewModel>[],
            isLoading: false,
            errorMessage: error.toString(),
            onPortfolioSelected: (_) {},
            onRefresh: () {
              ref.invalidate(tradePortfoliosStreamProvider(widget.userId));
            },
          ),
        );
      },
    );
  }

  /// Build prompt to select a portfolio
  Widget _buildSelectPortfolioPrompt() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _selectedView == TradeViewType.holdings ? Icons.dashboard_outlined : Icons.calendar_today_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Select a Portfolio',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedView == TradeViewType.holdings
              ? 'Choose a portfolio to access the comprehensive holdings dashboard with detailed analytics and summary views'
              : 'Choose a portfolio to explore the interactive calendar analytics with trade event insights',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _selectedView = TradeViewType.portfolios;
            });
          },
          icon: const Icon(Icons.list),
          label: const Text('View Portfolio List'),
        ),
      ],
    ),
  );
}
