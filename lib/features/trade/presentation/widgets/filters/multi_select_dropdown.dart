import 'package:flutter/material.dart';

/// Reusable multi-select dropdown widget
class MultiSelectDropdown<T> extends StatefulWidget {
  const MultiSelectDropdown({
    required this.label,
    required this.selectedValues,
    required this.allValues,
    required this.formatter,
    required this.onChanged,
    super.key,
  });
  final String label;
  final List<T> selectedValues;
  final List<T> allValues;
  final String Function(T) formatter;
  final Function(List<T>) onChanged;

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late List<T> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<T>.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen) {
      _tempSelected = List<T>.from(widget.selectedValues);
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _tempSelected = List<T>.from(widget.selectedValues);
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(children: [_buildBackgroundDismiss(), _buildDropdownContent(size)]),
    );
  }

  Widget _buildBackgroundDismiss() => Positioned.fill(
    child: GestureDetector(onTap: _closeDropdown, behavior: HitTestBehavior.translucent),
  );

  Widget _buildDropdownContent(Size size) => Positioned(
    width: size.width,
    child: CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: Offset(0, size.height + 4),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [_buildDropdownHeader(), _buildOptionsList()]),
        ),
      ),
    ),
  );

  Widget _buildDropdownHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        _buildHeaderActions(),
      ],
    ),
  );

  Widget _buildHeaderActions() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_tempSelected.isNotEmpty)
        TextButton(
          onPressed: () => setState(() => _tempSelected.clear()),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: const Size(0, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Clear', style: TextStyle(fontSize: 11)),
        ),
      const SizedBox(width: 4),
      FilledButton(
        onPressed: () {
          widget.onChanged(_tempSelected);
          _closeDropdown();
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: const Size(0, 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Done', style: TextStyle(fontSize: 11)),
      ),
    ],
  );

  Widget _buildOptionsList() => Flexible(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: widget.allValues.map(_buildOptionItem).toList(),
    ),
  );

  Widget _buildOptionItem(T value) {
    final isSelected = _tempSelected.contains(value);
    return CheckboxListTile(
      title: Text(widget.formatter(value), style: const TextStyle(fontSize: 12)),
      value: isSelected,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _tempSelected.add(value);
          } else {
            _tempSelected.remove(value);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _layerLink,
    child: InkWell(
      onTap: _toggleDropdown,
      child: InputDecorator(decoration: _buildInputDecoration(), child: _buildDisplayText()),
    ),
  );

  InputDecoration _buildInputDecoration() => InputDecoration(
    labelText: widget.label,
    labelStyle: const TextStyle(fontSize: 12),
    border: const OutlineInputBorder(),
    suffixIcon: _buildSuffixIcon(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    isDense: true,
  );

  Widget _buildSuffixIcon() {
    if (widget.selectedValues.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 16),
        onPressed: () {
          widget.onChanged([]);
          _closeDropdown();
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }
    return Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 16);
  }

  Widget _buildDisplayText() {
    final String displayText;
    final Color? textColor;

    if (widget.selectedValues.isEmpty) {
      displayText = 'Select options';
      textColor = Colors.grey;
    } else if (widget.selectedValues.length == 1) {
      displayText = widget.formatter(widget.selectedValues.first);
      textColor = null;
    } else {
      displayText = '${widget.selectedValues.length} selected';
      textColor = null;
    }

    return Text(
      displayText,
      style: TextStyle(color: textColor, fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }
}
