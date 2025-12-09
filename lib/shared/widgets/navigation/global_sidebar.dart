import 'package:flutter/material.dart';

class GlobalSidebar extends StatelessWidget {
  const GlobalSidebar({
    required this.activeNavItem,
    required this.onNavigate,
    super.key,
    this.onLogout,
    this.userName,
    this.userEmail,
    this.userAvatarUrl,
  });

  final String activeNavItem;
  final Function(String) onNavigate;
  final VoidCallback? onLogout;
  final String? userName;
  final String? userEmail;
  final String? userAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Darker background for global sidebar to distinguish from sub-sidebar
    final backgroundColor = isDark
        ? const Color(0xFF151520)
        : const Color(0xFF0F1015);
    const selectedColor = Color(0xFF6C5DD3);
    final unselectedColor = Colors.white.withValues(alpha: 0.5);

    return Container(
      width: 70, // Narrow width for icon-only sidebar
      color: backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // App Logo (Small)
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5DD3), Color(0xFF8B80F8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 24),
          ),

          const SizedBox(height: 40),

          // Main Navigation Items
          Expanded(
            child: Column(
              children: [
                _buildNavItem(
                  'Dashboard',
                  Icons.dashboard_rounded,
                  selectedColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  'Portfolio',
                  Icons.pie_chart_rounded,
                  selectedColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  'Trade',
                  Icons.swap_horiz_rounded,
                  selectedColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  'Market',
                  Icons.trending_up_rounded,
                  selectedColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  'News',
                  Icons.newspaper_rounded,
                  selectedColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  'Reports',
                  Icons.analytics_rounded,
                  selectedColor,
                  unselectedColor,
                ),
              ],
            ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // User Profile with Popup Menu
                if (userName != null || userEmail != null)
                  PopupMenuButton<String>(
                    offset: const Offset(70, 0),
                    tooltip: 'Profile Menu',
                    child: Column(
                      children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedColor,
                        ),
                        child: ClipOval(
                          child: userAvatarUrl != null
                              ? Image.network(
                                  userAvatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        (userName ?? userEmail ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    (userName ?? userEmail ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                        const SizedBox(height: 8),
                        if (userName != null)
                          Text(
                            userName!.split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (userName != null)
                              Text(
                                userName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            if (userEmail != null)
                              Text(
                                userEmail!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const Divider(),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 8),
                            const Text('Logout'),
                          ],
                        ),
                        onTap: onLogout,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String title,
    IconData icon,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = activeNavItem == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Tooltip(
        message: title,
        child: InkWell(
          onTap: () => onNavigate(title),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: selectedColor.withValues(alpha: 0.5))
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
