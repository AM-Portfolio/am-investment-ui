import 'package:flutter/material.dart';
import '../../../core/app_logic/services/auth_service.dart';

/// A layout component specifically designed for web interfaces
/// Includes header navigation and footer
class WebLayout extends StatelessWidget {
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

  /// Constructor
  const WebLayout({
    super.key,
    required this.child,
    this.title = 'AM Investment', // Title parameter kept for compatibility
    this.activeNavItem = 'Dashboard',
    this.onLogout,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  }

  /// Build the header with navigation
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().currentState.user;

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
                        const SnackBar(
                          content: Text('Search coming soon'),
                        ),
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

                  // User profile
                  InkWell(
                    onTap: () {
                      _showUserMenu(context);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.onPrimary,
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user?.name ?? 'User',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.onPrimary,
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

  /// Show company information dialog
  void _showCompanyInfo(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'About AM Investment',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'A leading investment platform for modern investors',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Legal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('License: SEBI Registration No. INZ000031633'),
              const SizedBox(height: 4),
              Text('CIN: U67190MH2018PTC307971'),
              const SizedBox(height: 4),
              Text('GSTIN: 27AAHCA1996R1ZP'),
              const SizedBox(height: 24),
              Text(
                'Quick Links',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoLink(context, 'About Us'),
                  _buildInfoLink(context, 'Contact'),
                  _buildInfoLink(context, 'Help Center'),
                  _buildInfoLink(context, 'Privacy Policy'),
                  _buildInfoLink(context, 'Terms of Service'),
                  _buildInfoLink(context, 'Careers'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info link for company info dialog
  Widget _buildInfoLink(BuildContext context, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label coming soon')));
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  /// Show user menu
  void _showUserMenu(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('User Menu', style: theme.textTheme.titleMedium),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon')),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 12),
                Text('Profile'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              if (onLogout != null) {
                onLogout!();
              }
            },
            child: Row(
              children: [
                Icon(Icons.logout, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
