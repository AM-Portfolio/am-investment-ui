import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_widget.dart';

/// Button types for different visual styles
enum AppButtonType {
  primary,
  secondary,
  text,
}

/// A cross-platform button component that adapts to the current platform.
///
/// This widget provides a consistent API while rendering the appropriate
/// native-looking button based on the platform.
class AppButton extends PlatformWidget<Widget, Widget> {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? height;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.padding,
    this.minWidth,
    this.height,
  }) : super(key: key);

  @override
  Widget buildIosWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button color based on type
    Color? buttonColor;
    switch (type) {
      case AppButtonType.primary:
        buttonColor = theme.primaryColor;
        break;
      case AppButtonType.secondary:
        buttonColor = Colors.transparent;
        break;
      case AppButtonType.text:
        buttonColor = Colors.transparent;
        break;
    }

    // For text buttons on iOS, use a simple CupertinoButton with no background
    if (type == AppButtonType.text) {
      return CupertinoButton(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context, CupertinoColors.activeBlue),
      );
    }

    return SizedBox(
      height: height ?? 48,
      width: minWidth,
      child: CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        color: buttonColor,
        disabledColor: CupertinoColors.inactiveGray,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(
          context, 
          type == AppButtonType.primary ? CupertinoColors.white : theme.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    // Build the appropriate button based on type
    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          height: height ?? 48,
          width: minWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(context, Colors.white),
          ),
        );
      
      case AppButtonType.secondary:
        return SizedBox(
          height: height ?? 48,
          width: minWidth,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(context, theme.primaryColor),
          ),
        );
      
      case AppButtonType.text:
        return TextButton(
          style: TextButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(context, theme.primaryColor),
        );
    }
  }

  @override
  Widget buildWebWidget(BuildContext context) {
    // For web, we use Material buttons with some adjustments for better web UX
    final theme = Theme.of(context);
    
    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          height: height ?? 48,
          width: minWidth,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(context, Colors.white),
          ),
        );
      
      case AppButtonType.secondary:
        return SizedBox(
          height: height ?? 48,
          width: minWidth,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(context, theme.primaryColor),
          ),
        );
      
      case AppButtonType.text:
        return TextButton(
          style: TextButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(context, theme.primaryColor),
        );
    }
  }

  Widget _buildChild(BuildContext context, Color textColor) {
    if (isLoading) {
      return _buildLoadingIndicator(context);
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: textColor)),
        ],
      );
    }

    return Text(text, style: TextStyle(color: textColor));
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    // Use platform-specific loading indicators
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const CupertinoActivityIndicator();
    }
    
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == AppButtonType.primary ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
