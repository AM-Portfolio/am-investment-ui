import 'package:flutter/material.dart';

import '../../internal/domain/entities/favorite_filter.dart';
import '../../internal/domain/entities/metrics_filter_config.dart';

/// Template widget for creating or editing a favorite filter
class FavoriteFilterTemplate extends StatefulWidget {
  const FavoriteFilterTemplate({required this.onSave, super.key, this.filter, this.onCancel});

  final FavoriteFilter? filter;
  final void Function(String name, MetricsFilterConfig filterConfig, String? description, bool isDefault) onSave;
  final VoidCallback? onCancel;

  @override
  State<FavoriteFilterTemplate> createState() => _FavoriteFilterTemplateState();
}

class _FavoriteFilterTemplateState extends State<FavoriteFilterTemplate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isDefault;
  late MetricsFilterConfig _filterConfig;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.filter?.name ?? '');
    _descriptionController = TextEditingController(text: widget.filter?.description ?? '');
    _isDefault = widget.filter?.isDefault ?? false;
    _filterConfig = widget.filter?.filterConfig ?? const MetricsFilterConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Filter Name',
              hintText: 'e.g., Winning Trades, High R:R',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a filter name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Brief description of this filter',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Set as Default
          CheckboxListTile(
            value: _isDefault,
            onChanged: (value) {
              setState(() {
                _isDefault = value ?? false;
              });
            },
            title: const Text('Set as default filter'),
            subtitle: const Text('This filter will be applied automatically'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Filter Configuration Section
          Text(
            'Filter Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // TODO: Add filter configuration UI
          // For now, showing placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Criteria', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure date ranges, trade status, brokers, and other filters here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  // This section will be expanded based on MetricsFilterConfig
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onCancel != null) TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _handleSave, child: Text(widget.filter == null ? 'Create' : 'Save')),
            ],
          ),
        ],
      ),
    ),
  );

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _nameController.text.trim(),
        _filterConfig,
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        _isDefault,
      );
    }
  }
}
