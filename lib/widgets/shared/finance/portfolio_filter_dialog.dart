import 'package:flutter/material.dart';
import '../../../core/models/portfolio/portfolio_holdings.dart';
import 'portfolio_filter_widget.dart';

/// A dialog widget that displays advanced filtering options for portfolio holdings
class PortfolioFilterDialog extends StatelessWidget {
  /// The list of holdings to filter
  final List<EquityHolding> holdings;

  /// Constructor
  const PortfolioFilterDialog({
    super.key,
    required this.holdings,
  });

  /// Show the filter dialog and return the filtered holdings
  static Future<List<EquityHolding>?> show(
    BuildContext context,
    List<EquityHolding> holdings,
  ) async {
    List<EquityHolding>? result;
    
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Holdings'),
          content: SizedBox(
            width: 600,
            child: PortfolioFilterWidget(
              holdings: holdings,
              initiallyExpanded: true,
              onFiltersApplied: (filtered) {
                result = filtered;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Holdings'),
      content: SizedBox(
        width: 600,
        child: PortfolioFilterWidget(
          holdings: holdings,
          initiallyExpanded: true,
          onFiltersApplied: (filtered) {
            Navigator.of(context).pop(filtered);
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
