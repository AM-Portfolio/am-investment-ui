import 'package:flutter/material.dart';

import '../../../core/app_logic/services/auth_service.dart';
import '../components.dart';

/// A layout component specifically designed for web interfaces
/// Includes header navigation and footer
class WebLayout extends StatelessWidget {
  /// Constructor
  const WebLayout({
    required this.child,
    super.key,
    this.title = 'AM Investment', // Title parameter kept for compatibility
    this.activeNavItem = 'Dashboard',
    this.onLogout,
    this.onNavigate,
  });

  /// The main content of the page
  final Widget child;

  /// The title to display in the header (only used for page title, not displayed)
  final String title;

  /// The currently active navigation item
  final String activeNavItem;

  /// Callback when logout is requested
  final VoidCallback? onLogout;

  /// Callback when navigation is requested
  final void Function(String navItem)? onNavigate;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        // Header with navigation
        _buildHeader(context),

        // Main content area
        Expanded(child: child),

        // Footer
        _buildFooter(context),
      ],
    ),
  );

  /// Build the header with navigation
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().currentState.currentUser;

    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // Top header with logo, navigation, and user profile
          Row(
            children: [
              // Logo and title
              Row(
                children: [
                  // App logo - improved design
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Main icon
                        Icon(
                          Icons.show_chart,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        // Accent element
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.onPrimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // App title - always 'AM Investment'
                  Text(
                    'AM Investment',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 40),

              // Navigation bar - moved to the middle
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNavItem(context, 'Dashboard', Icons.dashboard),
                      _buildNavItem(context, 'Portfolio', Icons.bar_chart),
                      _buildNavItem(context, 'Trade', Icons.swap_horiz),
                      _buildNavItem(context, 'Market', Icons.trending_up),
                      _buildNavItem(context, 'News', Icons.newspaper),
                      _buildNavItem(context, 'Reports', Icons.analytics),
                    ],
                  ),
                ),
              ),

              // User actions
              Row(
                children: [
                  // Search
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    color: theme.colorScheme.onPrimary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon')),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Notifications
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications',
                    color: theme.colorScheme.onPrimary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications coming soon'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // User profile with dropdown
                  UserDropdownMenu(
                    userName: user?.fullName ?? 'User',
                    userEmail: user?.email,
                    onLogout: onLogout,
                    onProfile: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile page coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.onPrimary,
                            child: Text(
                              user?.fullName.isNotEmpty == true
                                  ? _getInitials(user!.fullName)
                                  : 'U',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getFirstName(user?.fullName ?? 'User'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a navigation item
  Widget _buildNavItem(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final isActive = activeNavItem == label;

    return InkWell(
      onTap: () {
        // Use onNavigate callback if provided, otherwise use traditional navigation
        if (onNavigate != null) {
          onNavigate!(label);
        } else {
          Navigator.of(context).pushNamed('/${label.toLowerCase()}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimary.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onPrimary.withOpacity(0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the footer
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Copyright
          Text(
            '© 2025 AM Investment. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          // Quick links
          Row(
            children: [
              _buildFooterLink(context, 'Privacy'),
              const SizedBox(width: 16),
              _buildFooterLink(context, 'Terms'),
              const SizedBox(width: 16),
              _buildFooterLink(context, 'Help'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a footer link
  Widget _buildFooterLink(BuildContext context, String label) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          // Handle link tap
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label coming soon')));
        },
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Get user initials for avatar
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final names = name.trim().split(' ').where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return 'U';

    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  /// Get first name from full name
  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final names = fullName
        .trim()
        .split(' ')
        .where((n) => n.isNotEmpty)
        .toList();
    return names.isNotEmpty ? names[0] : 'User';
  }
}
