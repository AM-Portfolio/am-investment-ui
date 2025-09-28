import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expandable left-side quick actions widget with smooth animations
class ExpandableLeftQuickActions extends ConsumerStatefulWidget {
  final String userId;
  final String? portfolioId;
  final Function(String)? onPortfolioCreated;
  final Function(String)? onTradeDetailsAdded;
  final Function(String)? onError;

  const ExpandableLeftQuickActions({
    super.key,
    required this.userId,
    this.portfolioId,
    this.onPortfolioCreated,
    this.onTradeDetailsAdded,
    this.onError,
  });

  @override
  ConsumerState<ExpandableLeftQuickActions> createState() => _ExpandableLeftQuickActionsState();
}

class _ExpandableLeftQuickActionsState extends ConsumerState<ExpandableLeftQuickActions>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isProcessing = false;
  late AnimationController _expandController;
  late AnimationController _iconController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _fadeAnimation;

  final List<QuickActionItem> _quickActions = [
    QuickActionItem(
      id: 'add_stock',
      icon: Icons.add_circle_outline,
      label: 'Add Stock',
      color: const Color(0xFF2196F3),
      description: 'Add new stock to portfolio',
    ),
    QuickActionItem(
      id: 'view_analysis',
      icon: Icons.trending_up,
      label: 'Analysis',
      color: const Color(0xFF4CAF50),
      description: 'View portfolio analytics',
    ),
    QuickActionItem(
      id: 'import_data',
      icon: Icons.upload_file,
      label: 'Import',
      color: const Color(0xFFFF9800),
      description: 'Import data from file',
    ),
    QuickActionItem(
      id: 'refresh',
      icon: Icons.refresh,
      label: 'Refresh',
      color: const Color(0xFF9C27B0),
      description: 'Refresh portfolio data',
    ),
    QuickActionItem(
      id: 'settings',
      icon: Icons.settings,
      label: 'Settings',
      color: const Color(0xFF607D8B),
      description: 'Portfolio settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutQuart,
    );

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
      _iconController.forward();
    } else {
      _expandController.reverse();
      _iconController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleButton(),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: _expandAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildActionsList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing ? null : _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _iconRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _iconRotation.value * 3.14159,
                      child: Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _iconRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _iconRotation.value * 3.14159,
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsList() {
    if (_isProcessing) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Portfolio Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._quickActions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final delay = index * 0.1;
                final animationValue = (_expandAnimation.value - delay).clamp(0.0, 1.0);
                
                return Transform.translate(
                  offset: Offset(0, (1 - animationValue) * 20),
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildActionItem(action),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionItem(QuickActionItem action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: action.color.withOpacity(0.05),
        border: Border.all(
          color: action.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleQuickAction(action.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: action.color.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuickAction(String actionId) async {
    setState(() {
      _isProcessing = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      switch (actionId) {
        case 'add_stock':
          await _showAddStockDialog();
          break;
        case 'view_analysis':
          _showSnackBar('Analysis feature coming soon!', const Color(0xFF4CAF50));
          break;
        case 'import_data':
          await _showImportDialog();
          break;
        case 'refresh':
          await _performRefresh();
          break;
        case 'settings':
          _showSnackBar('Settings feature coming soon!', const Color(0xFF607D8B));
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Stock'),
          ],
        ),
        content: const Text(
          'Quick stock addition feature is coming soon! You\'ll be able to add stocks directly from this quick action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.upload_file,
                color: Color(0xFFFF9800),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Import Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your import method:'),
            const SizedBox(height: 16),
            _buildImportOption(Icons.file_upload, 'Upload Excel/CSV file'),
            _buildImportOption(Icons.link, 'Connect broker account'),
            _buildImportOption(Icons.edit, 'Manual entry'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Import feature coming soon!', const Color(0xFFFF9800));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _performRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate refresh
    _showSnackBar('Portfolio refreshed successfully!', const Color(0xFF4CAF50));
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Data class for quick action items
class QuickActionItem {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  const QuickActionItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
}