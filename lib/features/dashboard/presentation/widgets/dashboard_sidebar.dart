import 'package:flutter/material.dart';

import '../../../../shared/widgets/navigation/sidebar_nav_item.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  final String currentView;
  final ValueChanged<String> onViewChanged;

  @override
  Widget build(BuildContext context) {
    // Define dark theme for sidebar (same as TradeSidebarContainer)
    final darkTheme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      cardColor: const Color(0xFF1E1E2E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C5DD3),
        surface: Color(0xFF1E1E2E),
        onSurface: Colors.white,
        primaryContainer: Color(0xFF2C2C3E),
        onPrimaryContainer: Colors.white,
        outline: Colors.white24,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      dividerColor: Colors.white.withValues(alpha: 0.1),
    );

    return Theme(
      data: darkTheme,
      child: Container(
        width: 280,
        color: const Color(0xFF1E1E2E),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C5DD3), Color(0xFF8B80F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TRADEZELLA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Add Trade Button (Quick Action style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5DD3), Color(0xFF8B80F8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5DD3).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add Trade',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _buildNavItem('Dashboard', Icons.grid_view_rounded, 'Overview & Stats'),
                    _buildNavItem('Daily Journal', Icons.bar_chart_rounded, 'Performance tracking'),
                    _buildNavItem('Trade Log', Icons.list_alt_rounded, 'Detailed trade history'),
                    _buildNavItem('Reports', Icons.pie_chart_outline_rounded, 'Analytics & breakdown'),
                    
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
                    
                    _buildNavItem('Insights', Icons.lightbulb_outline_rounded, 'AI-powered analysis'),
                    _buildNavItem('University', Icons.school_outlined, 'Learning resources'),
                    _buildNavItem('Notebook', Icons.book_outlined, 'Personal notes'),
                    _buildNavItem('Playbook', Icons.menu_book_rounded, 'Strategy builder'),
                    _buildNavItem('Trade Replay', Icons.replay_rounded, 'Market simulation'),
                  ],
                ),
              ),
            ),
            
            // User Profile
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Name',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Pro Plan',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String subtitle) {
    return SidebarNavItem<String>(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: title,
      groupValue: currentView,
      onChanged: onViewChanged,
      isEnabled: true,
      isCompact: false,
      isCondensed: false,
    );
  }
}
