import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Right-side floating quick actions with flying animations
class RightFloatingQuickActions extends ConsumerStatefulWidget {
  final String userId;
  final String? portfolioId;
  final Function(String)? onPortfolioCreated;
  final Function(String)? onTradeDetailsAdded;
  final Function(String)? onError;

  const RightFloatingQuickActions({
    super.key,
    required this.userId,
    this.portfolioId,
    this.onPortfolioCreated,
    this.onTradeDetailsAdded,
    this.onError,
  });

  @override
  ConsumerState<RightFloatingQuickActions> createState() => _RightFloatingQuickActionsState();
}

class _RightFloatingQuickActionsState extends ConsumerState<RightFloatingQuickActions>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isProcessing = false;
  late AnimationController _flyController;
  late AnimationController _iconController;
  late AnimationController _staggerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotation;

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
    
    // Main flying animation controller
    _flyController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Icon rotation controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Stagger animation controller for individual actions
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Slide animation from right to left
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0), // Start from right side
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOutBack,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animation for entrance effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOutBack,
    ));

    // Icon rotation
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flyController.dispose();
    _iconController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _iconController.forward();
      _flyController.forward();
      _staggerController.forward();
    } else {
      _iconController.reverse();
      _flyController.reverse();
      _staggerController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay to close actions when tapping outside
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleActions,
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
        
        // Flying actions panel
        if (_isExpanded)
          Positioned(
            right: 80,
            top: 20,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildActionsPanel(),
                ),
              ),
            ),
          ),
        
        // Floating action button (trigger)
        Positioned(
          right: 16,
          top: 16,
          child: _buildFloatingTrigger(),
        ),
      ],
    );
  }

  Widget _buildFloatingTrigger() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing ? null : _toggleActions,
          borderRadius: BorderRadius.circular(28),
          child: AnimatedBuilder(
            animation: _iconRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _iconRotation.value * 2 * 3.14159,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.flash_on,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionsPanel() {
    if (_isProcessing) {
      return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Actions list with staggered animation
            ..._quickActions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              
              return AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animationValue = ((_staggerController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                  
                  return Transform.translate(
                    offset: Offset((1 - animationValue) * 50, 0),
                    child: Opacity(
                      opacity: animationValue,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildActionItem(action),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(QuickActionItem action) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: action.color.withOpacity(0.08),
        border: Border.all(
          color: action.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleQuickAction(action.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: action.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuickAction(String actionId) async {
    // Close the actions panel first
    _toggleActions();
    
    // Add a small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));
    
    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF2196F3),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text('Add Stock'),
          ],
        ),
        content: const Text(
          'Quick stock addition feature is coming soon! You\'ll be able to add stocks directly from this quick action.',
          style: TextStyle(fontSize: 16),
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_file,
                color: Color(0xFFFF9800),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text('Import Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your import method:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> _performRefresh() async {
    await Future.delayed(const Duration(milliseconds: 2000)); // Simulate refresh
    _showSnackBar('Portfolio refreshed successfully!', const Color(0xFF4CAF50));
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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