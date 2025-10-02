import 'package:flutter/material.dart';

/// A reusable user dropdown menu widget with better UI/UX
/// Shows user information and available actions in a dropdown below the trigger
class UserDropdownMenu extends StatefulWidget {
  /// The user's full name
  final String userName;
  
  /// The user's email (optional)
  final String? userEmail;
  
  /// The user's avatar URL (optional)
  final String? avatarUrl;
  
  /// Callback when logout is requested
  final VoidCallback? onLogout;
  
  /// Callback when profile is requested
  final VoidCallback? onProfile;
  
  /// Callback when settings is requested
  final VoidCallback? onSettings;
  
  /// Custom menu items (optional)
  final List<UserDropdownItem>? customItems;
  
  /// Background color for the dropdown
  final Color? backgroundColor;
  
  /// Border color for the dropdown
  final Color? borderColor;
  
  /// Width of the dropdown menu (if null, uses responsive width)
  final double? dropdownWidth;
  
  /// Maximum height of the dropdown menu
  final double? maxHeight;
  
  /// Minimum width of the dropdown menu
  final double? minWidth;
  
  /// Spacing between trigger and dropdown
  final double spacing;
  
  /// Padding from screen edges
  final double screenPadding;
  
  /// Child widget that triggers the dropdown (usually a user avatar/icon)
  final Widget child;
  
  const UserDropdownMenu({
    super.key,
    required this.userName,
    required this.child,
    this.userEmail,
    this.avatarUrl,
    this.onLogout,
    this.onProfile,
    this.onSettings,
    this.customItems,
    this.backgroundColor,
    this.borderColor,
    this.dropdownWidth,
    this.maxHeight,
    this.minWidth,
    this.spacing = 8.0,
    this.screenPadding = 16.0,
  });

  @override
  State<UserDropdownMenu> createState() => _UserDropdownMenuState();
}

class _UserDropdownMenuState extends State<UserDropdownMenu>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    // Force close menu immediately without animation
    if (_isMenuOpen) {
      _removeOverlay();
      _isMenuOpen = false;
    }
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (!mounted) return;
    
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (_isMenuOpen || !mounted) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    
    // Only animate if controller is not disposed
    if (mounted && !_animationController.isAnimating) {
      _animationController.forward();
    }
    
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    if (!_isMenuOpen || !mounted) return;
    
    // Immediately mark as closed to prevent multiple calls
    setState(() {
      _isMenuOpen = false;
    });
    
    // Only animate if controller is still active
    if (_animationController.isAnimating || _animationController.isCompleted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          _removeOverlay();
        }
      });
    } else {
      _removeOverlay();
    }
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  /// Handle menu item tap with immediate cleanup
  void _handleMenuItemTap(VoidCallback callback) {
    if (!mounted) return;
    
    // Immediately close menu without animation
    _closeMenuImmediately();
    
    // Execute callback immediately
    try {
      callback();
    } catch (e) {
      debugPrint('Error executing menu item callback: $e');
    }
  }
  
  /// Immediately close menu without animation
  void _closeMenuImmediately() {
    if (!_isMenuOpen) return;
    
    // Stop any ongoing animation
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    
    // Reset animation controller
    _animationController.reset();
    
    // Remove overlay immediately
    _removeOverlay();
    
    // Update state
    if (mounted) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    if (!mounted) {
      throw StateError('Cannot create overlay entry when widget is not mounted');
    }
    
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      throw StateError('Cannot find render object for dropdown positioning');
    }
    
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    
    // Get screen dimensions
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    
    // Calculate responsive dropdown dimensions
    double calculatedWidth = widget.dropdownWidth ?? 
        (screenWidth < 600 ? screenWidth * 0.8 : 280.0).clamp(200.0, 400.0);
    double calculatedMaxHeight = widget.maxHeight ?? 
        (screenHeight * 0.6).clamp(200.0, 500.0);
    
    // Calculate optimal position
    double leftPosition = offset.dx + size.width - calculatedWidth;
    double topPosition = offset.dy + size.height + widget.spacing;
    
    // Ensure dropdown stays within screen bounds horizontally
    if (leftPosition < widget.screenPadding) {
      leftPosition = widget.screenPadding;
    } else if (leftPosition + calculatedWidth > screenWidth - widget.screenPadding) {
      leftPosition = screenWidth - calculatedWidth - widget.screenPadding;
    }
    
    // Ensure dropdown stays within screen bounds vertically
    if (topPosition + calculatedMaxHeight > screenHeight - widget.screenPadding) {
      // Position above the trigger if there's not enough space below
      topPosition = offset.dy - calculatedMaxHeight - widget.spacing;
      if (topPosition < widget.screenPadding) {
        // If still not enough space, position with maximum available height
        topPosition = widget.screenPadding;
      }
    }

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _closeMenuImmediately(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Invisible overlay to detect outside clicks
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Dropdown menu
            Positioned(
              left: leftPosition,
              top: topPosition,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: Alignment.topRight,
                    child: _buildDropdownContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    // Calculate responsive dimensions
    double calculatedWidth = widget.dropdownWidth ?? 
        (mediaQuery.size.width < 600 ? mediaQuery.size.width * 0.8 : 280.0).clamp(200.0, 400.0);
    double calculatedMaxHeight = widget.maxHeight ?? 
        (mediaQuery.size.height * 0.6).clamp(200.0, 500.0);
    double calculatedMinWidth = widget.minWidth ?? 200.0;
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: widget.backgroundColor ?? theme.colorScheme.surface,
      child: Container(
        width: calculatedWidth,
        constraints: BoxConstraints(
          maxHeight: calculatedMaxHeight,
          minWidth: calculatedMinWidth,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.borderColor ?? theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: widget.avatarUrl != null 
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                    child: widget.avatarUrl == null
                        ? Text(
                            _getInitials(widget.userName),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // User details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.userEmail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.userEmail!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items - scrollable container
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile option
                    if (widget.onProfile != null)
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => _handleMenuItemTap(widget.onProfile!),
                      ),
                    
                    // Settings option
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'Available soon',
                      onTap: () => _handleMenuItemTap(() {
                        if (widget.onSettings != null) {
                          widget.onSettings!();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings will be available soon'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }),
                    ),
                    
                    // Custom items
                    if (widget.customItems != null)
                      ...widget.customItems!.map((item) => _buildMenuItem(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        onTap: () => _handleMenuItemTap(item.onTap),
                        isDestructive: item.isDestructive,
                      )),
                    
                    // Divider before logout
                    if (widget.onLogout != null) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () => _handleMenuItemTap(widget.onLogout!),
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final textColor = isDestructive 
        ? theme.colorScheme.error 
        : theme.colorScheme.onSurface;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor.withOpacity(0.8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (subtitle != null && subtitle.contains('soon'))
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }



  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: widget.child,
      ),
    );
  }
}

/// Custom menu item for the user dropdown
class UserDropdownItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const UserDropdownItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });
}