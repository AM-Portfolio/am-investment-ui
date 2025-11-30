import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trade_holding_view_model.dart';
import 'trade_detail_widgets/similar_trades_section.dart';
import 'trade_detail_widgets/trade_detail_header.dart';
import 'trade_detail_widgets/trade_detail_summary.dart';

/// Dedicated page for displaying detailed trade information in a modular layout
class TradeDetailViewPage extends ConsumerStatefulWidget {
  const TradeDetailViewPage({
    required this.trade,
    required this.userId,
    required this.portfolioId,
    this.onClose,
    super.key,
  });

  final TradeHoldingViewModel trade;
  final String userId;
  final String portfolioId;
  final VoidCallback? onClose;

  @override
  ConsumerState<TradeDetailViewPage> createState() => _TradeDetailViewPageState();
}

class _TradeDetailViewPageState extends ConsumerState<TradeDetailViewPage> {
  String? _symbolFilter;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Column(
      children: [
        // Header with filter
        TradeDetailHeader(
          trade: widget.trade,
          onClose: widget.onClose,
          onFilterChanged: (value) {
            setState(() {
              _symbolFilter = value?.trim().isEmpty ?? true ? null : value;
            });
          },
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Summary Cards (Trade Details, Price, Fees, Performance)
                TradeDetailSummary(trade: widget.trade),
                const SizedBox(height: 20),

                // Similar Trades Section
                SimilarTradesSection(
                  trade: widget.trade,
                  userId: widget.userId,
                  portfolioId: widget.portfolioId,
                  symbolFilter: _symbolFilter,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
