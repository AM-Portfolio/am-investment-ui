import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/document_upload_service.dart';
import '../../../core/domain/entities/document/document_upload.dart';

/// Types of portfolio actions available
enum PortfolioActionType {
  createFromHoldings,
  createFromTradeHistory,
  addTradeDetails,
}

/// Configuration for portfolio action
class PortfolioActionConfig {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DocumentCategory documentCategory;
  final List<String> allowedExtensions;

  const PortfolioActionConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.documentCategory,
    required this.allowedExtensions,
  });
}

/// Quick action widget for portfolio operations
class PortfolioQuickActions extends ConsumerStatefulWidget {
  /// Called when an action is completed successfully
  final Function(PortfolioActionType type, DocumentUpload result)? onActionCompleted;
  
  /// Called when an action fails
  final Function(PortfolioActionType type, String error)? onActionFailed;
  
  /// Current portfolio ID (for adding trade details)
  final String? portfolioId;
  
  /// Current user ID
  final String userId;

  const PortfolioQuickActions({
    super.key,
    this.onActionCompleted,
    this.onActionFailed,
    this.portfolioId,
    required this.userId,
  });

  @override
  ConsumerState<PortfolioQuickActions> createState() => _PortfolioQuickActionsState();
}

class _PortfolioQuickActionsState extends ConsumerState<PortfolioQuickActions> {
  bool _isUploading = false;
  PortfolioActionType? _currentAction;

  /// Configuration for each action type
  static const Map<PortfolioActionType, PortfolioActionConfig> _actionConfigs = {
    PortfolioActionType.createFromHoldings: PortfolioActionConfig(
      title: 'Create Portfolio from Holdings',
      description: 'Upload your current holdings document to create a new portfolio',
      icon: Icons.folder_open,
      color: Colors.blue,
      documentCategory: DocumentCategory.stockPortfolio,
      allowedExtensions: ['xls', 'xlsx'],
    ),
    PortfolioActionType.createFromTradeHistory: PortfolioActionConfig(
      title: 'Create Portfolio from Trade History',
      description: 'Upload your trade history to analyze and create portfolio',
      icon: Icons.history,
      color: Colors.green,
      documentCategory: DocumentCategory.tradeEq,
      allowedExtensions: ['xls', 'xlsx'],
    ),
    PortfolioActionType.addTradeDetails: PortfolioActionConfig(
      title: 'Add Trade Details',
      description: 'Upload trade details to update your portfolio',
      icon: Icons.add_chart,
      color: Colors.orange,
      documentCategory: DocumentCategory.tradeEq,
      allowedExtensions: ['xls', 'xlsx'],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isUploading) ...[
              _buildUploadingState(),
            ] else ...[
              _buildActionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsList() {
    return Column(
      children: _actionConfigs.entries.map((entry) {
        final actionType = entry.key;
        final config = entry.value;
        
        // Hide "Add Trade Details" if no portfolio is selected
        if (actionType == PortfolioActionType.addTradeDetails && widget.portfolioId == null) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildActionTile(actionType, config),
        );
      }).toList(),
    );
  }

  Widget _buildActionTile(PortfolioActionType actionType, PortfolioActionConfig config) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: config.color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: config.color.withOpacity(0.1),
          child: Icon(
            config.icon,
            color: config.color,
          ),
        ),
        title: Text(
          config.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          config.description,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Icon(
          Icons.upload_file,
          color: config.color,
        ),
        onTap: () => _handleActionTap(actionType, config),
      ),
    );
  }

  Widget _buildUploadingState() {
    final config = _actionConfigs[_currentAction];
    return Column(
      children: [
        LinearProgressIndicator(
          color: config?.color ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              config?.icon ?? Icons.upload,
              color: config?.color ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Uploading ${config?.title.toLowerCase() ?? 'document'}...',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleActionTap(PortfolioActionType actionType, PortfolioActionConfig config) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: config.allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = result.files.first;
      
      // Validate file extension
      if (!_isValidFileExtension(file.extension, config.allowedExtensions)) {
        _showError('Please select a valid file format (${config.allowedExtensions.join(', ')})');
        return;
      }

      setState(() {
        _isUploading = true;
        _currentAction = actionType;
      });

      // Upload document
      final documentService = ref.read(documentUploadServiceProvider);
      final portfolioId = _getPortfolioId(actionType);
      
      DocumentUpload uploadResult;
      
      if (kIsWeb) {
        // Web platform - use bytes
        if (file.bytes == null) {
          throw Exception('Failed to read file bytes');
        }
        uploadResult = await documentService.uploadDocument(
          file: file.bytes!,
          fileName: file.name,
          category: config.documentCategory,
          portfolioId: portfolioId,
          userId: widget.userId,
          description: _getUploadDescription(actionType),
        );
      } else {
        // Mobile/Desktop platform - use File
        final filePath = file.path;
        if (filePath == null) {
          throw Exception('Failed to get file path');
        }
        uploadResult = await documentService.uploadDocument(
          file: File(filePath),
          fileName: file.name,
          category: config.documentCategory,
          portfolioId: portfolioId,
          userId: widget.userId,
          description: _getUploadDescription(actionType),
        );
      }

      // Success callback
      widget.onActionCompleted?.call(actionType, uploadResult);
      
      if (mounted) {
        _showSuccess('Document uploaded successfully!');
      }

    } catch (e) {
      debugPrint('Upload error: $e');
      final errorMessage = e.toString();
      widget.onActionFailed?.call(actionType, errorMessage);
      _showError('Upload failed: $errorMessage');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _currentAction = null;
        });
      }
    }
  }

  bool _isValidFileExtension(String? extension, List<String> allowedExtensions) {
    if (extension == null) return false;
    return allowedExtensions.contains(extension.toLowerCase());
  }

  String _getPortfolioId(PortfolioActionType actionType) {
    switch (actionType) {
      case PortfolioActionType.createFromHoldings:
      case PortfolioActionType.createFromTradeHistory:
        // For creation, generate a temporary ID or let the service handle it
        return 'temp-${DateTime.now().millisecondsSinceEpoch}';
      case PortfolioActionType.addTradeDetails:
        return widget.portfolioId ?? 'default';
    }
  }

  String _getUploadDescription(PortfolioActionType actionType) {
    switch (actionType) {
      case PortfolioActionType.createFromHoldings:
        return 'Portfolio creation from current holdings document';
      case PortfolioActionType.createFromTradeHistory:
        return 'Portfolio creation from trade history document';
      case PortfolioActionType.addTradeDetails:
        return 'Adding trade details to existing portfolio';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}