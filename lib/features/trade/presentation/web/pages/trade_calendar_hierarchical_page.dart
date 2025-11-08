import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/trade_calendar_cubit.dart';
import '../../cubit/trade_calendar_state.dart';
import '../../models/calendar_view_models.dart' as view_models;
import '../../widgets/calendar_views.dart';

/// Enhanced Trade Calendar Page with Hierarchical Drill-Down Views
///
/// Features:
/// - Yearly view (default) - Grid of 12 months
/// - Monthly view - Calendar grid of days
/// - Daily view - List of trades
/// - Breadcrumb navigation
/// - Back button support
class TradeCalendarHierarchicalPage extends StatelessWidget {
  const TradeCalendarHierarchicalPage({required this.userId, required this.portfolioId, super.key});

  final String userId;
  final String portfolioId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Trade Calendar'),
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final cubit = context.read<TradeCalendarCubit>();
            cubit.refresh(userId: userId, portfolioId: portfolioId, forceReload: true);
          },
          tooltip: 'Refresh',
        ),
      ],
    ),
    body: BlocBuilder<TradeCalendarCubit, TradeCalendarState>(
      builder: (context, state) {
        if (state is TradeCalendarLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TradeCalendarError) {
          return _buildErrorView(context, state.message);
        }

        if (state is TradeCalendarLoaded) {
          return _buildCalendarView(context, state);
        }

        return const Center(child: Text('No data available'));
      },
    ),
  );

  Widget _buildErrorView(BuildContext context, String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text('Error loading calendar', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            final cubit = context.read<TradeCalendarCubit>();
            cubit.retryLoad(userId: userId, portfolioId: portfolioId);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _buildCalendarView(BuildContext context, TradeCalendarLoaded state) {
    final cubit = context.read<TradeCalendarCubit>();
    final navigationState = cubit.navigationState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb navigation
        _buildBreadcrumbs(context, navigationState, cubit),

        // Divider
        const Divider(height: 1),

        // Calendar view based on current navigation state
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildHierarchicalView(context, navigationState, cubit),
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs(
    BuildContext context,
    view_models.CalendarNavigationState navigationState,
    TradeCalendarCubit cubit,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Row(
        children: [
          // Home icon for yearly view
          InkWell(
            onTap: () {
              cubit.navigateToYearly(userId: userId, portfolioId: portfolioId);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.home,
                size: 20,
                color: navigationState.viewType == view_models.CalendarViewType.yearly
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Breadcrumb trail
          ...navigationState.breadcrumbs.map((breadcrumb) {
            final isLast = breadcrumb == navigationState.breadcrumbs.last;
            return Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16),
                const SizedBox(width: 8),
                InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          cubit.navigateToBreadcrumb(userId: userId, portfolioId: portfolioId, breadcrumb: breadcrumb);
                        },
                  child: Text(
                    breadcrumb.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isLast ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHierarchicalView(
    BuildContext context,
    view_models.CalendarNavigationState navigationState,
    TradeCalendarCubit cubit,
  ) {
    switch (navigationState.viewType) {
      case view_models.CalendarViewType.yearly:
        return _buildYearlyView(context, cubit);

      case view_models.CalendarViewType.monthly:
        return _buildMonthlyView(context, cubit);

      case view_models.CalendarViewType.daily:
        return _buildDailyView(context, cubit);
    }
  }

  Widget _buildYearlyView(BuildContext context, TradeCalendarCubit cubit) {
    final yearlyData = cubit.getYearlyCalendarData();

    if (yearlyData == null) {
      return const Center(child: Text('No yearly data available'));
    }

    return YearlyCalendarView(
      yearData: yearlyData,
      onMonthTap: (month) {
        cubit.navigateToMonthly(userId: userId, portfolioId: portfolioId, month: month);
      },
      onPreviousYear: () {
        cubit.navigateToPreviousYear(userId: userId, portfolioId: portfolioId);
      },
      onNextYear: () {
        cubit.navigateToNextYear(userId: userId, portfolioId: portfolioId);
      },
    );
  }

  Widget _buildMonthlyView(BuildContext context, TradeCalendarCubit cubit) {
    final monthlyData = cubit.getMonthlyCalendarData();

    if (monthlyData == null) {
      return const Center(child: Text('No monthly data available'));
    }

    return MonthlyCalendarView(
      monthData: monthlyData,
      onDayTap: (day) {
        cubit.navigateToDaily(userId: userId, portfolioId: portfolioId, day: day);
      },
      onBack: () {
        cubit.navigateBack(userId: userId, portfolioId: portfolioId);
      },
    );
  }

  Widget _buildDailyView(BuildContext context, TradeCalendarCubit cubit) {
    final dailyData = cubit.getDailyCalendarData();

    if (dailyData == null) {
      return const Center(child: Text('No daily data available'));
    }

    return DailyCalendarView(
      dayData: dailyData,
      onBack: () {
        cubit.navigateBack(userId: userId, portfolioId: portfolioId);
      },
    );
  }
}
