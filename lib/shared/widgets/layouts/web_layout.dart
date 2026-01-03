import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am_common_ui/shared/widgets/navigation/global_sidebar.dart';
import 'package:am_common_ui/core/theme/cubit/theme_cubit.dart';

/// A layout component specifically designed for web interfaces
/// Includes header navigation and footer
class WebLayout extends StatelessWidget {
  /// Constructor
  const WebLayout({
    required this.child,
    super.key,
    this.title = 'AM Investment',
    this.activeNavItem = 'Dashboard',
    this.userName = 'User',
    this.userEmail,
    this.userAvatarUrl,
    this.onLogout,
    this.onNavigate,
  });

  /// The main content of the page
  final Widget child;

  /// The title to display in the header (only used for page title, not displayed)
  final String title;

  /// The currently active navigation item
  final String activeNavItem;

  /// User display name
  final String userName;

  /// User email
  final String? userEmail;

  /// User avatar URL
  final String? userAvatarUrl;

  /// Callback when logout is requested
  final VoidCallback? onLogout;

  /// Callback when navigation is requested
  final void Function(String navItem)? onNavigate;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        // Global Sidebar (Far Left)
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return GlobalSidebar(
              activeNavItem: activeNavItem,
              navItems: const [
                 GlobalNavigationItem(title: 'Dashboard', icon: Icons.dashboard_rounded),
                 GlobalNavigationItem(title: 'Portfolio', icon: Icons.pie_chart_rounded),
                 GlobalNavigationItem(title: 'Trade', icon: Icons.swap_horiz_rounded),
                 GlobalNavigationItem(title: 'Market', icon: Icons.trending_up_rounded),
                 GlobalNavigationItem(title: 'News', icon: Icons.newspaper_rounded),
                 GlobalNavigationItem(title: 'Reports', icon: Icons.analytics_rounded),
              ],
              userName: userName,
              userEmail: userEmail,
              userAvatarUrl: userAvatarUrl,
              isDarkMode: themeState.themeMode == ThemeMode.dark ||
                  (themeState.themeMode == ThemeMode.system &&
                      MediaQuery.of(context).platformBrightness == Brightness.dark),
              onNavigate: (navItem) {
                if (onNavigate != null) {
                  onNavigate!(navItem);
                } else {
                  Navigator.of(context).pushNamed('/${navItem.toLowerCase()}');
                }
              },
              onThemeToggle: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              onLogout: onLogout,
            );
          },
        ),

        // Main Content Area (Includes Sub-sidebar if present in child)
        Expanded(child: child),
      ],
    ),
  );
}
