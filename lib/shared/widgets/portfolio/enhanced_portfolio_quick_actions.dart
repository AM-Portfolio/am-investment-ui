import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/document/document_upload.dart';
import '../ui/portfolio_quick_actions.dart';

/// Service to handle portfolio creation from uploaded documents
class PortfolioCreationService {
  /// Create portfolio from uploaded document
  static Future<PortfolioCreationResult> createPortfolioFromDocument({
    required DocumentUpload uploadResult,
    required PortfolioActionType actionType,
    required String userId,
    String? portfolioName,
  }) async {
    try {
      // Simulate processing based on action type
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      final portfolioId = 'portfolio_${DateTime.now().millisecondsSinceEpoch}';
      final defaultName = _getDefaultPortfolioName(actionType);
      
      return PortfolioCreationResult.success(
        portfolioId: portfolioId,
        portfolioName: portfolioName ?? defaultName,
        documentsProcessed: [uploadResult],
        summary: _generatePortfolioSummary(actionType, uploadResult),
      );
    } catch (e) {
      return PortfolioCreationResult.error(
        message: 'Failed to create portfolio: ${e.toString()}',
      );
    }
  }

  /// Add trade details to existing portfolio
  static Future<TradeDetailsResult> addTradeDetailsToPortfolio({
    required DocumentUpload uploadResult,
    required String portfolioId,
    required String userId,
  }) async {
    try {
      // Simulate processing
      await Future.delayed(const Duration(seconds: 1));
      
      return TradeDetailsResult.success(
        portfolioId: portfolioId,
        tradesAdded: _simulateTradeCount(),
        documentProcessed: uploadResult,
        summary: 'Successfully added ${_simulateTradeCount()} trades to portfolio',
      );
    } catch (e) {
      return TradeDetailsResult.error(
        message: 'Failed to add trade details: ${e.toString()}',
      );
    }
  }

  static String _getDefaultPortfolioName(PortfolioActionType actionType) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 10);
    switch (actionType) {
      case PortfolioActionType.createFromHoldings:
        return 'Holdings Portfolio - $timestamp';
      case PortfolioActionType.createFromTradeHistory:
        return 'Trade History Portfolio - $timestamp';
      case PortfolioActionType.addTradeDetails:
        return 'Updated Portfolio - $timestamp';
    }
  }

  static String _generatePortfolioSummary(PortfolioActionType actionType, DocumentUpload uploadResult) {
    switch (actionType) {
      case PortfolioActionType.createFromHoldings:
        return 'Portfolio created from current holdings document. '
               'Document: ${uploadResult.identity.fileName} '
               'Status: ${uploadResult.status.current.name}';
      case PortfolioActionType.createFromTradeHistory:
        return 'Portfolio created from trade history analysis. '
               'Document: ${uploadResult.identity.fileName} '
               'Status: ${uploadResult.status.current.name}';
      case PortfolioActionType.addTradeDetails:
        return 'Trade details added to portfolio. '
               'Document: ${uploadResult.identity.fileName}';
    }
  }

  static int _simulateTradeCount() {
    // Simulate random number of trades between 5-50
    return 5 + (DateTime.now().millisecondsSinceEpoch % 45);
  }
}

/// Result of portfolio creation operation
class PortfolioCreationResult {
  final bool isSuccess;
  final String? portfolioId;
  final String? portfolioName;
  final List<DocumentUpload>? documentsProcessed;
  final String? summary;
  final String? errorMessage;

  const PortfolioCreationResult._({
    required this.isSuccess,
    this.portfolioId,
    this.portfolioName,
    this.documentsProcessed,
    this.summary,
    this.errorMessage,
  });

  factory PortfolioCreationResult.success({
    required String portfolioId,
    required String portfolioName,
    required List<DocumentUpload> documentsProcessed,
    required String summary,
  }) {
    return PortfolioCreationResult._(
      isSuccess: true,
      portfolioId: portfolioId,
      portfolioName: portfolioName,
      documentsProcessed: documentsProcessed,
      summary: summary,
    );
  }

  factory PortfolioCreationResult.error({
    required String message,
  }) {
    return PortfolioCreationResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Result of trade details addition operation
class TradeDetailsResult {
  final bool isSuccess;
  final String? portfolioId;
  final int? tradesAdded;
  final DocumentUpload? documentProcessed;
  final String? summary;
  final String? errorMessage;

  const TradeDetailsResult._({
    required this.isSuccess,
    this.portfolioId,
    this.tradesAdded,
    this.documentProcessed,
    this.summary,
    this.errorMessage,
  });

  factory TradeDetailsResult.success({
    required String portfolioId,
    required int tradesAdded,
    required DocumentUpload documentProcessed,
    required String summary,
  }) {
    return TradeDetailsResult._(
      isSuccess: true,
      portfolioId: portfolioId,
      tradesAdded: tradesAdded,
      documentProcessed: documentProcessed,
      summary: summary,
    );
  }

  factory TradeDetailsResult.error({
    required String message,
  }) {
    return TradeDetailsResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Enhanced portfolio quick actions widget with creation service integration
class EnhancedPortfolioQuickActions extends ConsumerStatefulWidget {
  /// Called when portfolio is created successfully
  final Function(PortfolioCreationResult result)? onPortfolioCreated;
  
  /// Called when trade details are added successfully
  final Function(TradeDetailsResult result)? onTradeDetailsAdded;
  
  /// Called when any operation fails
  final Function(String error)? onError;
  
  /// Current portfolio ID (for adding trade details)
  final String? portfolioId;
  
  /// Current user ID
  final String userId;

  const EnhancedPortfolioQuickActions({
    super.key,
    this.onPortfolioCreated,
    this.onTradeDetailsAdded,
    this.onError,
    this.portfolioId,
    required this.userId,
  });

  @override
  ConsumerState<EnhancedPortfolioQuickActions> createState() => _EnhancedPortfolioQuickActionsState();
}

class _EnhancedPortfolioQuickActionsState extends ConsumerState<EnhancedPortfolioQuickActions> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Container(
        constraints: const BoxConstraints(
          minHeight: 40,
          maxHeight: 60,
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;
        return Container(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4 : 8,
            vertical: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                icon: Icons.add_circle_outline,
                label: 'Add Stock',
                color: Colors.blue,
                onTap: () => _handleQuickAction('add_stock'),
              ),
              _buildQuickAction(
                icon: Icons.upload_file,
                label: 'Import',
                color: Colors.orange,
                onTap: () => _handleQuickAction('import_data'),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 80;
          final iconSize = isCompact ? 16.0 : 18.0;
          final fontSize = isCompact ? 10.0 : 11.0;
          
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: isCompact ? 60 : 70,
                  maxWidth: isCompact ? 80 : 90,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 8,
                  vertical: isCompact ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                    SizedBox(height: isCompact ? 2 : 3),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleQuickAction(String action) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      switch (action) {
        case 'add_stock':
          await _showAddStockDialog();
          break;
        case 'view_analysis':
          _showSnackBar('Analysis feature coming soon!', Colors.blue);
          break;
        case 'import_data':
          await _showImportDialog();
          break;
        case 'refresh':
          _showSnackBar('Portfolio refreshed!', Colors.green);
          break;
      }
    } catch (e) {
      widget.onError?.call('Action failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showAddStockDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock'),
        content: const Text('Quick stock addition feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Choose import type:\n• Upload Excel file\n• Connect broker account\n• Manual entry'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Import feature coming soon!', Colors.orange);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}