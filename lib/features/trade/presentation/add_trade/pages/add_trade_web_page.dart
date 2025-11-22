import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../shared/widgets/layouts/web_layout.dart';
import '../../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../../authentication/presentation/cubit/auth_state.dart';
import '../../../internal/domain/entities/trade_controller_entities.dart';
import '../../cubit/trade_controller_cubit.dart';
import '../../cubit/trade_controller_state.dart';
import '../../web/trade_web_screen.dart';
import '../../widgets/responsive_sidebar.dart';
import '../../widgets/trade_sidebar.dart';
import '../components/add_trade_form.dart';

/// Web page for adding new trades with responsive design
/// Streamlined 4-step process with click-and-select focus
class AddTradeWebPage extends StatefulWidget {
  const AddTradeWebPage({required this.portfolioId, super.key, this.portfolioName, this.onTradeAdded});

  final String portfolioId;
  final String? portfolioName;
  final VoidCallback? onTradeAdded;

  @override
  State<AddTradeWebPage> createState() => _AddTradeWebPageState();
}

class _AddTradeWebPageState extends State<AddTradeWebPage> {
  bool _isLoading = false;

  void _handleSave(TradeDetails tradeDetails) {
    AppLogger.methodEntry('_handleSave', tag: 'AddTradeWebPage');
    AppLogger.info(
      '💾 Starting trade save process - portfolioId: ${widget.portfolioId}, symbol: ${tradeDetails.instrumentInfo.symbol}',
      tag: 'AddTradeWebPage',
    );

    setState(() => _isLoading = true);

    // Get userId from AuthCubit
    final authState = context.read<AuthCubit>().state;
    final userId = authState is Authenticated ? authState.user.id : null;

    if (userId == null || userId.isEmpty) {
      AppLogger.error('🚨 CRITICAL: Cannot save trade - userId is null or empty!', tag: 'AddTradeWebPage');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please log in again.'), backgroundColor: Colors.red),
      );
      return;
    }

    // CRITICAL: Set portfolioId and userId from widget/auth since they're not included in the form
    final tradeToSave = tradeDetails.copyWith(portfolioId: widget.portfolioId, userId: userId);

    AppLogger.debug('📋 Trade Details (with portfolioId & userId): ${tradeToSave.toString()}', tag: 'AddTradeWebPage');
    AppLogger.info('🚀 Calling TradeControllerCubit.addNewTrade() with userId: $userId', tag: 'AddTradeWebPage');

    // Call the TradeControllerCubit to save the trade
    context.read<TradeControllerCubit>().addNewTrade(tradeToSave);

    AppLogger.methodExit('_handleSave', tag: 'AddTradeWebPage');
  }

  void _handleCancel() {
    AppLogger.info('❌ User initiated cancel', tag: 'AddTradeWebPage');

    // Show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Trade?'),
        content: const Text('Are you sure you want to discard this trade? All entered data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Continue Editing')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Discard')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        AppLogger.info('✅ User confirmed discard, navigating back', tag: 'AddTradeWebPage');
        _navigateBack();
      } else {
        AppLogger.info('↩️ User chose to continue editing', tag: 'AddTradeWebPage');
      }
    });
  }

  void _navigateBack() {
    AppLogger.methodEntry('_navigateBack', tag: 'AddTradeWebPage');
    AppLogger.info('🔙 Popping navigation stack to return to previous screen', tag: 'AddTradeWebPage');

    // Simply pop the current route to go back to the previous screen (which has WebLayout)
    Navigator.of(context).pop();

    AppLogger.methodExit('_navigateBack', tag: 'AddTradeWebPage');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get user info from auth state for WebLayout
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.displayName ?? authState.user.email : 'User';
    final userEmail = authState is Authenticated ? authState.user.email : '';

    return BlocListener<TradeControllerCubit, TradeControllerState>(
      listener: (context, state) {
        state.when(
          initial: () {
            AppLogger.debug('[TradeControllerCubit] State: Initial', tag: 'AddTradeWebPage');
          },
          loading: () {
            AppLogger.debug('[TradeControllerCubit] State: Loading trades', tag: 'AddTradeWebPage');
          },
          loaded: (trades, portfolioId) {
            AppLogger.info('[TradeControllerCubit] State: Loaded ${trades.length} trades', tag: 'AddTradeWebPage');
          },
          adding: () {
            AppLogger.info('[TradeControllerCubit] State: Adding trade...', tag: 'AddTradeWebPage');
            setState(() => _isLoading = true);
          },
          addSuccess: (trade) {
            AppLogger.info(
              '✅ [TradeControllerCubit] Trade added successfully - tradeId: ${trade.tradeId}',
              tag: 'AddTradeWebPage',
            );
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Trade added successfully!'), backgroundColor: Colors.green));

            widget.onTradeAdded?.call();
            _navigateBack();
          },
          updating: () {
            AppLogger.debug('[TradeControllerCubit] State: Updating trade', tag: 'AddTradeWebPage');
          },
          updateSuccess: (trade) {
            AppLogger.info('[TradeControllerCubit] State: Trade updated successfully', tag: 'AddTradeWebPage');
          },
          deleting: () {
            AppLogger.debug('[TradeControllerCubit] State: Deleting trade', tag: 'AddTradeWebPage');
          },
          deleteSuccess: (tradeId) {
            AppLogger.info('[TradeControllerCubit] State: Trade deleted successfully', tag: 'AddTradeWebPage');
          },
          error: (message, error) {
            AppLogger.error('❌ [TradeControllerCubit] Error: $message', tag: 'AddTradeWebPage', error: error);
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to save trade: $message'), backgroundColor: Colors.red));
          },
        );
      },
      child: WebLayout(
        title: 'Trade',
        activeNavItem: 'Trade',
        userName: userName,
        userEmail: userEmail,
        onLogout: () async {
          await context.read<AuthCubit>().logout();
        },
        onNavigate: (navItem) {
          // Navigate back to main screen
          _navigateBack();
        },
        child: Row(
          children: [
            // Sidebar
            ResponsiveSidebar(
              child: TradeSidebar(
                selectedView: TradeViewType.holdings,
                onViewChanged: (_) {},
                currentPortfolioId: widget.portfolioId,
                currentPortfolioName: widget.portfolioName,
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceContainerLowest,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _handleCancel,
                            tooltip: 'Back to Trades',
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Trade',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (widget.portfolioName != null)
                                Text(
                                  widget.portfolioName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Expanded(
                      child: AddTradeForm(onSave: _handleSave, onCancel: _handleCancel, isLoading: _isLoading),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ), // End of WebLayout child
      ), // End of BlocListener
    );
  }
}
