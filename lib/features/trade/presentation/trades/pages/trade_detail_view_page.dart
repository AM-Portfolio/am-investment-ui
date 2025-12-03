import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../features/attachment/presentation/models/pending_attachment.dart';
import '../../../../../features/attachment/presentation/widgets/shared/attachment_preview_grid.dart';
import '../../models/trade_holding_view_model.dart';
import '../widgets/trade_detail_widgets/similar_trades_section.dart';
import '../widgets/trade_detail_widgets/trade_detail_header.dart';
import '../widgets/trade_detail_widgets/trade_detail_summary.dart';

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
  Widget build(BuildContext context) {
    AppLogger.debug('🔍 Building TradeDetailViewPage', tag: 'TradeDetail');
    AppLogger.debug('📊 Trade Symbol: ${widget.trade.symbol}', tag: 'TradeDetail');
    AppLogger.debug('📎 Has Attachments: ${widget.trade.hasAttachments}', tag: 'TradeDetail');
    AppLogger.debug('📸 Attachment Count: ${widget.trade.attachmentCount}', tag: 'TradeDetail');

    return Container(
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

                  // Attachments Section (if any)
                  if (widget.trade.hasAttachments) ...[
                    _buildAttachmentsSection(context, widget.trade),
                    const SizedBox(height: 20),
                  ],

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

  Widget _buildAttachmentsSection(BuildContext context, TradeHoldingViewModel trade) {
    final theme = Theme.of(context);

    AppLogger.debug('🔨 Building Attachments Section', tag: 'TradeDetail');
    AppLogger.debug('📦 Raw Attachments: ${trade.attachments?.length ?? 0} items', tag: 'TradeDetail');

    final filteredAttachments = (trade.attachments ?? [])
        .where((attachment) => attachment.fileUrl != null && attachment.fileUrl!.isNotEmpty)
        .toList();

    AppLogger.debug('✅ Filtered Attachments: ${filteredAttachments.length} items', tag: 'TradeDetail');

    for (var i = 0; i < filteredAttachments.length; i++) {
      final att = filteredAttachments[i];
      AppLogger.debug('  [$i] URL: ${att.fileUrl}, Name: ${att.fileName ?? "N/A"}', tag: 'TradeDetail');
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Attachments (${trade.attachmentCount})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Attachments Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final attachmentItems = filteredAttachments
                    .map((attachment) => AttachmentItem.uploaded(attachment.fileUrl))
                    .toList();

                AppLogger.debug('🎨 Creating AttachmentItems: ${attachmentItems.length}', tag: 'TradeDetail');

                return AttachmentPreviewGrid(attachments: attachmentItems, readOnly: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
