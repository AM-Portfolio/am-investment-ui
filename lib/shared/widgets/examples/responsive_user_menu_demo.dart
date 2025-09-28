import 'package:flutter/material.dart';
import '../common/user_dropdown_menu.dart';

/// Examples showing different configurations of UserDropdownMenu
/// Demonstrates the flexibility and responsive design
class ResponsiveUserMenuDemo extends StatelessWidget {
  const ResponsiveUserMenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive UserDropdownMenu Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Default Responsive Design
            _buildSection(
              context,
              'Default Responsive Design',
              'Adapts width based on screen size (80% on mobile, 280px on desktop)',
              UserDropdownMenu(
                userName: 'John Doe',
                userEmail: 'john.doe@example.com',
                onLogout: () => _showSnackBar(context, 'Logout clicked'),
                onProfile: () => _showSnackBar(context, 'Profile clicked'),
                child: _buildTrigger(context, 'Default', Icons.person),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 2: Compact Mobile Design
            _buildSection(
              context,
              'Compact Mobile Design',
              'Fixed narrow width for mobile interfaces',
              UserDropdownMenu(
                userName: 'Jane Smith',
                userEmail: 'jane.smith@company.com',
                dropdownWidth: 200,
                maxHeight: 300,
                spacing: 4,
                screenPadding: 8,
                onLogout: () => _showSnackBar(context, 'Logout clicked'),
                child: _buildTrigger(context, 'Compact', Icons.phone_android),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 3: Desktop Wide Design
            _buildSection(
              context,
              'Desktop Wide Design',
              'Wider dropdown for desktop applications with more content',
              UserDropdownMenu(
                userName: 'Michael Johnson',
                userEmail: 'michael.johnson@enterprise.com',
                dropdownWidth: 320,
                maxHeight: 450,
                spacing: 12,
                screenPadding: 24,
                onLogout: () => _showSnackBar(context, 'Logout clicked'),
                onProfile: () => _showSnackBar(context, 'Profile clicked'),
                customItems: [
                  UserDropdownItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    subtitle: 'View your dashboard',
                    onTap: () => _showSnackBar(context, 'Dashboard clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View detailed analytics',
                    onTap: () => _showSnackBar(context, 'Analytics clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _showSnackBar(context, 'Help clicked'),
                  ),
                ],
                child: _buildTrigger(context, 'Desktop', Icons.desktop_windows),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 4: Minimal Design
            _buildSection(
              context,
              'Minimal Design',
              'Clean, minimal dropdown with custom colors',
              UserDropdownMenu(
                userName: 'Sarah Wilson',
                dropdownWidth: 180,
                maxHeight: 250,
                minWidth: 150,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderColor: Theme.of(context).colorScheme.primary,
                onLogout: () => _showSnackBar(context, 'Logout clicked'),
                child: _buildTrigger(context, 'Minimal', Icons.minimize),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 5: Full-featured Design
            _buildSection(
              context,
              'Full-featured Design',
              'Maximum features with custom styling and many menu items',
              UserDropdownMenu(
                userName: 'David Brown',
                userEmail: 'david.brown@fullfeature.com',
                dropdownWidth: 280,
                maxHeight: 400,
                spacing: 8,
                backgroundColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.tertiary,
                onLogout: () => _showSnackBar(context, 'Logout clicked'),
                onProfile: () => _showSnackBar(context, 'Profile clicked'),
                onSettings: () => _showSnackBar(context, 'Settings clicked'),
                customItems: [
                  UserDropdownItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: '3 unread',
                    onTap: () => _showSnackBar(context, 'Notifications clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.bookmark,
                    title: 'Bookmarks',
                    onTap: () => _showSnackBar(context, 'Bookmarks clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.history,
                    title: 'Recent Activity',
                    onTap: () => _showSnackBar(context, 'Activity clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.feedback,
                    title: 'Feedback',
                    subtitle: 'Help us improve',
                    onTap: () => _showSnackBar(context, 'Feedback clicked'),
                  ),
                  UserDropdownItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => _showSnackBar(context, 'About clicked'),
                  ),
                ],
                child: _buildTrigger(context, 'Full', Icons.star),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Configuration Guide
            _buildConfigurationGuide(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String description, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            dropdown,
            const SizedBox(width: 16),
            Text(
              '← Click to test',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrigger(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }
  
  Widget _buildConfigurationGuide(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildConfigItem('dropdownWidth', 'Fixed width (null = responsive)'),
          _buildConfigItem('maxHeight', 'Maximum height (null = 60% of screen)'),
          _buildConfigItem('minWidth', 'Minimum width (default: 200)'),
          _buildConfigItem('spacing', 'Distance from trigger (default: 8)'),
          _buildConfigItem('screenPadding', 'Padding from edges (default: 16)'),
          _buildConfigItem('backgroundColor', 'Custom background color'),
          _buildConfigItem('borderColor', 'Custom border color'),
          const SizedBox(height: 16),
          Text(
            'Responsive Behavior:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('• Mobile (<600px): 80% of screen width'),
          Text('• Desktop (≥600px): 280px fixed width'),
          Text('• Height: 60% of screen height (clamped 200-500px)'),
          Text('• Auto-positions to stay within viewport'),
          Text('• Scrollable content when needed'),
        ],
      ),
    );
  }
  
  Widget _buildConfigItem(String property, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$property: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
  
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}