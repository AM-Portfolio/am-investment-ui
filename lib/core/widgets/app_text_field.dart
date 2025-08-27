import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_widget.dart';

/// A cross-platform text input component that adapts to the current platform.
///
/// This widget provides a consistent API while rendering the appropriate
/// native-looking text field based on the platform.
class AppTextField extends PlatformWidget<CupertinoTextField, TextField> {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final Widget? suffix;

  const AppTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  CupertinoTextField buildIosWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return CupertinoTextField(
      controller: controller,
      placeholder: hintText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      autofocus: autofocus,
      focusNode: focusNode,
      padding: contentPadding ?? const EdgeInsets.all(12),
      prefix: prefix != null 
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: prefix,
            ) 
          : null,
      suffix: suffix != null 
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: suffix,
            ) 
          : null,
      decoration: BoxDecoration(
        border: Border.all(
          color: errorText != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  TextField buildMaterialWidget(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }

  @override
  Widget buildWebWidget(BuildContext context) {
    // For web, we use the Material design with some adjustments
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}
