import 'package:flutter/material.dart';

import '../../../internal/domain/entities/trade_controller_entities.dart';
import '../../components/templates/add_trade_template.dart';
import '../../widgets/responsive_sidebar.dart';
import '../../widgets/trade_sidebar.dart';
import '../trade_web_screen.dart';

/// Web page for adding new trades with responsive design
/// Features:
/// - Sidebar navigation
/// - Multi-step form with validation
/// - Auto-save drafts
/// - Success/error handling
/// - Responsive layout
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

  @override
  void initState() {
    super.initState();
  }

  void _handleSave(TradeDetails tradeDetails) {
    setState(() {
      _isLoading = true;
    });

    // TODO: Integrate with TradeControllerCubit when available
    // context.read<TradeControllerCubit>().addTrade(tradeDetails);

    // For now, simulate success
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _handleSuccess();
      }
    });
  }

  void _handleCancel() {
    // Show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trade Entry'),
        content: const Text('Are you sure you want to cancel? All entered data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continue Editing')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Discard'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        Navigator.pop(context);
      }
    });
  }

  void _handleSuccess() {
    setState(() => _isLoading = false);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Trade added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Call callback if provided
      widget.onTradeAdded?.call();

      // Navigate back after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _handleError(String error) {
    setState(() {
      _isLoading = false;
    });

    // Show error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    // TODO: Add BlocListener when TradeControllerCubit is integrated
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: isSmallScreen
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add New Trade'),
                  if (widget.portfolioName != null)
                    Text(
                      widget.portfolioName!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                    ),
                ],
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
      drawer: isSmallScreen
          ? Drawer(
              child: TradeSidebar(
                selectedView: TradeViewType.holdings,
                onViewChanged: (view) {
                  Navigator.pop(context); // Close drawer
                  // Handle view change if needed
                },
                currentPortfolioId: widget.portfolioId,
                currentPortfolioName: widget.portfolioName,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for desktop
          if (!isSmallScreen)
            ResponsiveSidebar(
              child: TradeSidebar(
                selectedView: TradeViewType.holdings,
                onViewChanged: (view) {
                  // Handle view change if needed
                },
                currentPortfolioId: widget.portfolioId,
                currentPortfolioName: widget.portfolioName,
              ),
            ),

          // Main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.colorScheme.surface, theme.colorScheme.surface],
                ),
              ),
              child: AddTradeTemplate(
                portfolioId: widget.portfolioId,
                onSave: _handleSave,
                onCancel: _handleCancel,
                isLoading: _isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
