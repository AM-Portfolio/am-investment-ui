import 'dart:ui';
import 'package:flutter/material.dart';

/// Enhanced template with rich pre-filled content
class EnhancedTemplateDialog extends StatefulWidget {
  const EnhancedTemplateDialog({
    required this.onTemplateSelected,
    super.key,
  });

  final Function(String templateName, String richContent) onTemplateSelected;

  @override
  State<EnhancedTemplateDialog> createState() => _EnhancedTemplateDialogState();
}

class _EnhancedTemplateDialogState extends State<EnhancedTemplateDialog> {
  String? _selectedTemplate;
  String? _previewContent;

  // Rich template definitions with pre-filled content
  final Map<String, Map<String, dynamic>> _templates = {
    'Daily Game Plan': {
      'description': 'Complete daily trading preparation checklist',
      'icon': Icons.calendar_today,
      'color': Color(0xFF6C5DD3),
