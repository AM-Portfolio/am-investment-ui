import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// A platform-adaptive card widget with consistent styling
class AppCard extends StatelessWidget {
  /// Child widget to display inside the card
  final Widget child;
  
  /// Optional title for the card
  final String? title;
  
  /// Optional subtitle for the card
  final String? subtitle;
  
  /// Optional action widget to display in the header
  final Widget? action;
  
  /// Whether to add extra padding inside the card
  final bool padded;
  
  /// Whether the card should take full width
  final bool fullWidth;
  
  /// Custom border radius
  final BorderRadius? borderRadius;
  
  /// Custom elevation
  final double? elevation;
  
  /// Background color of the card
  final Color? backgroundColor;
  
  /// Constructor
  const AppCard({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padded = true,
    this.fullWidth = true,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Platform-specific styling
    final double defaultElevation = defaultTargetPlatform == TargetPlatform.iOS ? 0 : 1;
    final BorderRadius defaultBorderRadius = defaultTargetPlatform == TargetPlatform.iOS 
        ? BorderRadius.circular(12) 
        : BorderRadius.circular(8);
    
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || subtitle != null || action != null)
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: subtitle != null ? 8 : 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium,
                        ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
        if (padded && (title != null || subtitle != null))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: child,
          )
        else if (padded)
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          )
        else
          child,
      ],
    );
    
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      return Container(
        width: fullWidth ? double.infinity : null,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? CupertinoColors.systemBackground,
          borderRadius: borderRadius ?? defaultBorderRadius,
          border: Border.all(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
        child: cardContent,
      );
    } else {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: elevation ?? defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
        ),
        color: backgroundColor,
        child: SizedBox(
          width: fullWidth ? double.infinity : null,
          child: cardContent,
        ),
      );
    }
  }
}
