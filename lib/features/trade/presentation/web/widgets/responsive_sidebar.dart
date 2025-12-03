import 'package:flutter/material.dart';

/// A responsive sidebar wrapper that automatically collapses on small screens
/// and provides smooth expand/collapse animations.
///
/// Features:
/// - Auto-collapses below 800px width
/// - Smooth slide animation
/// - Overlay mode on mobile
/// - Persistent mode on desktop
/// - Reusable for any sidebar content
class ResponsiveSidebar extends StatefulWidget {
  const ResponsiveSidebar({
    required this.child,
    this.width = 280,
    this.collapsedWidth = 60,
    this.breakpoint = 800,
    this.backgroundColor,
    this.elevation = 2,
    super.key,
  });

  final Widget child;
  final double width;
  final double collapsedWidth;
  final double breakpoint;
  final Color? backgroundColor;
  final double elevation;

  @override
  State<ResponsiveSidebar> createState() => ResponsiveSidebarState();
}

class ResponsiveSidebarState extends State<ResponsiveSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isExpanded = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.width,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < widget.breakpoint;

    // On small screens, show as overlay drawer
    if (isSmallScreen) {
      return const SizedBox.shrink(); // Use Drawer widget from Scaffold instead
    }

    // On larger screens, show as animated sidebar
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) => Material(
          elevation: widget.elevation,
          color: widget.backgroundColor ?? Theme.of(context).cardColor,
          child: Stack(
            children: [
              SizedBox(
                width: _widthAnimation.value,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: widget.width,
                    minWidth: widget.collapsedWidth,
                    child: SizedBox(
                      width: widget.width,
                      child: Opacity(opacity: _isExpanded ? 1.0 : 0.0, child: widget.child),
                    ),
                  ),
                ),
              ),
              // Toggle button
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedOpacity(
                  opacity: _isHovering || !_isExpanded ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: toggleSidebar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Collapsed icon menu
              if (!_isExpanded) Positioned.fill(child: _buildCollapsedMenu(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedMenu(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 60),
    child: Column(
      children: [
        _buildCollapsedIcon(context, Icons.list_alt, 'Portfolio List'),
        const SizedBox(height: 12),
        _buildCollapsedIcon(context, Icons.account_balance_wallet, 'Holdings'),
        const SizedBox(height: 12),
        _buildCollapsedIcon(context, Icons.calendar_today, 'Calendar'),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        _buildCollapsedIcon(context, Icons.analytics, 'Analytics'),
        const SizedBox(height: 12),
        _buildCollapsedIcon(context, Icons.download, 'Export'),
      ],
    ),
  );

  Widget _buildCollapsedIcon(BuildContext context, IconData icon, String tooltip) => Tooltip(
    message: tooltip,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
    ),
  );
}

/// A wrapper widget that provides sidebar with responsive behavior
/// including drawer for mobile screens.
class ResponsiveSidebarLayout extends StatelessWidget {
  const ResponsiveSidebarLayout({required this.sidebar, required this.body, this.breakpoint = 800, super.key});

  final Widget sidebar;
  final Widget body;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < breakpoint;

    if (isSmallScreen) {
      // Mobile: Use drawer
      return Scaffold(
        drawer: Drawer(child: sidebar),
        body: body,
      );
    } else {
      // Desktop: Use persistent sidebar
      return Row(
        children: [
          ResponsiveSidebar(breakpoint: breakpoint, child: sidebar),
          Expanded(child: body),
        ],
      );
    }
  }
}
