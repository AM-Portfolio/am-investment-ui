import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

import '../../../internal/domain/entities/journal_entry.dart';
import '../../../internal/presentation/cubits/journal/journal_cubit.dart';
import 'utils/journal_helpers.dart';
import 'widgets/mood_selector.dart';
import 'widgets/rich_text_editor.dart';
import 'widgets/sentiment_selector.dart';
import 'widgets/tags_selector.dart';
import 'widgets/url_preview_widget.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({required this.userId, required this.cubit, super.key, this.entry});

  final String userId;
  final JournalCubit cubit;
  final JournalEntry? entry;

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  late TextEditingController _tradeIdController;
  late TextEditingController _urlController;
  late DateTime _entryDate;
  String? _selectedMood;
  String? _marketSentiment;
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  String? _urlPreview;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');

    // Initialize Quill controller with existing content or empty
    final doc = widget.entry?.content != null && widget.entry!.content.isNotEmpty
        ? quill.Document.fromJson(jsonDecode(widget.entry!.content))
        : quill.Document();
    _quillController = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));

    _tradeIdController = TextEditingController(text: widget.entry?.tradeId ?? '');
    _urlController = TextEditingController();
    _entryDate = widget.entry?.entryDate ?? DateTime.now();

    // Map mood using helper
    _selectedMood = JournalHelpers.mapMoodFromEntry(widget.entry?.mood);

    // Map sentiment using helper
    _marketSentiment = JournalHelpers.mapSentimentFromValue(widget.entry?.marketSentiment);

    if (widget.entry?.tags != null) {
      _selectedTags.addAll(widget.entry!.tags);
    }

    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _tradeIdController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty && (text.startsWith('http://') || text.startsWith('https://'))) {
      setState(() => _urlPreview = text);
    } else {
      setState(() => _urlPreview = null);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _entryDate = picked);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  String _getQuillContent() {
    final delta = _quillController.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final content = _getQuillContent();
        if (widget.entry == null) {
          await widget.cubit.addJournalEntry(
            userId: widget.userId,
            title: _titleController.text,
            content: content,
            entryDate: _entryDate,
            tradeId: _tradeIdController.text.isEmpty ? null : _tradeIdController.text,
            mood: JournalHelpers.getMoodString(_selectedMood),
            marketSentiment: JournalHelpers.getSentimentValue(_marketSentiment),
            tags: _selectedTags.isEmpty ? null : _selectedTags.toList(),
          );
        } else {
          await widget.cubit.editJournalEntry(
            entryId: widget.entry!.id,
            userId: widget.userId,
            title: _titleController.text,
            content: content,
            entryDate: _entryDate,
            tradeId: _tradeIdController.text.isEmpty ? null : _tradeIdController.text,
            mood: JournalHelpers.getMoodString(_selectedMood),
            marketSentiment: JournalHelpers.getSentimentValue(_marketSentiment),
            tags: _selectedTags.isEmpty ? null : _selectedTags.toList(),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildMainContent(),
            const SizedBox(height: 24),
            TagsSelector(selectedTags: _selectedTags, onTagToggled: _toggleTag),
            const SizedBox(height: 24),
            _buildOptionalFields(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        widget.entry == null ? 'New Journal Entry' : 'Edit Journal Entry',
        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      FilledButton.icon(
        onPressed: _isSubmitting ? null : _submit,
        icon: _isSubmitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.check, size: 20),
        label: Text(widget.entry == null ? 'Create' : 'Update'),
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
      ),
    ],
  );

  Widget _buildMainContent() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 2, child: _buildLeftColumn()),
      const SizedBox(width: 24),
      Expanded(child: _buildRightColumn()),
    ],
  );

  Widget _buildLeftColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildTitleField(),
      const SizedBox(height: 16),
      RichTextEditor(controller: _quillController),
      const SizedBox(height: 16),
      _buildUrlField(),
      if (_urlPreview != null) ...[
        const SizedBox(height: 12),
        UrlPreviewWidget(
          url: _urlPreview!,
          onClose: () {
            _urlController.clear();
            setState(() => _urlPreview = null);
          },
        ),
      ],
    ],
  );

  Widget _buildTitleField() => TextFormField(
    controller: _titleController,
    decoration: InputDecoration(
      labelText: 'Title',
      hintText: 'e.g., "AAPL Breakout" or "Lesson: Don\'t Chase"',
      prefixIcon: const Icon(Icons.title, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  );

  Widget _buildUrlField() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _urlController,
        decoration: const InputDecoration(
          labelText: 'Add URL (optional)',
          hintText: 'https://tradingview.com/chart/...',
          prefixIcon: Icon(Icons.link, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRightColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MoodSelector(selectedMood: _selectedMood, onMoodSelected: (mood) => setState(() => _selectedMood = mood)),
      const SizedBox(height: 20),
      SentimentSelector(
        selectedSentiment: _marketSentiment,
        onSentimentSelected: (sentiment) => setState(() => _marketSentiment = sentiment),
      ),
    ],
  );

  Widget _buildOptionalFields(ThemeData theme) => Row(
    children: [
      Expanded(child: _buildDateField(theme)),
      const SizedBox(width: 12),
      Expanded(child: _buildTradeIdField(theme)),
    ],
  );

  Widget _buildDateField(ThemeData theme) => InkWell(
    onTap: _selectDate,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date (optional)',
          prefixIcon: Icon(Icons.calendar_today, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(DateFormat('MMM dd, yyyy').format(_entryDate), style: theme.textTheme.bodyMedium),
      ),
    ),
  );

  Widget _buildTradeIdField(ThemeData theme) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: _tradeIdController,
      decoration: const InputDecoration(
        labelText: 'Trade ID (optional)',
        hintText: 'Optional',
        prefixIcon: Icon(Icons.tag, size: 18),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );
}
