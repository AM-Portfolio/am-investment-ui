import 'package:flutter/material.dart';
import '../backgrounds/interactive_background.dart';

class ThemeSelector extends StatelessWidget {
  final BackgroundTheme currentTheme;
  final Function(BackgroundTheme) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, BackgroundTheme.nebula, Icons.bubble_chart, 'Nebula'),
          Container(width: 1, height: 20, color: Colors.white24),
          _buildOption(context, BackgroundTheme.market, Icons.candlestick_chart, 'Market'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, BackgroundTheme theme, IconData icon, String label) {
    final isSelected = currentTheme == theme;
    return InkWell(
      onTap: () => onThemeChanged(theme),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
