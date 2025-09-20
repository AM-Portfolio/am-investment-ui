import 'package:flutter/material.dart';

/// A widget that provides quick actions for portfolio management
class PortfolioQuickActions extends StatelessWidget {
  /// Callback when file is uploaded
  final Function() onFileUploaded;
  
  /// Callback when stock entry is requested
  final VoidCallback onAddStockEntry;
  
  /// Constructor
  const PortfolioQuickActions({
    super.key,
    required this.onFileUploaded,
    required this.onAddStockEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick action buttons
          Row(
            children: [
              // File upload button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.cloud_upload_outlined,
                  label: 'Import Portfolio',
                  color: theme.colorScheme.primary,
                  onPressed: () => _handleFileUpload(context),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Add stock entry button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.add_circle_outline,
                  label: 'Add Stock',
                  color: theme.colorScheme.secondary,
                  onPressed: onAddStockEntry,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description text
          Text(
            'Quickly import your portfolio data or add individual stock transactions.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build an action button
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handle file upload
  Future<void> _handleFileUpload(BuildContext context) async {
    try {
      // For now, just trigger the callback without actual file picking
      // This can be enhanced later with proper file picker implementation
      onFileUploaded();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File uploaded'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
