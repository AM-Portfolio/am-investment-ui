import 'package:flutter/material.dart';

import '../../../internal/domain/entities/trade_controller_entities.dart';
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
    setState(() => _isLoading = true);

    // TODO: Integrate with TradeControllerCubit
    // context.read<TradeControllerCubit>().addTrade(tradeDetails);

    // Simulate success for now
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _handleSuccess();
      }
    });
  }

  void _handleSuccess() {
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trade added successfully!'), backgroundColor: Colors.green));

    widget.onTradeAdded?.call();
    _navigateBack();
  }

  void _handleCancel() {
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
        _navigateBack();
      }
    });
  }

  void _navigateBack() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => TradeWebScreen(
          userId: '', // TODO: Get from authentication context
          selectedPortfolioId: widget.portfolioId,
          selectedPortfolioName: widget.portfolioName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
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
      ),
    );
  }
}
