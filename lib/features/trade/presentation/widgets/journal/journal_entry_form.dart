import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../attachment/presentation/widgets/attachment_picker.dart';
import '../../../internal/domain/entities/journal_entry.dart';
import '../../../internal/presentation/cubits/journal/journal_cubit.dart';
import '../../../providers/trade_internal_providers.dart';
import '../../models/trade_holding_view_model.dart';
import 'utils/journal_helpers.dart';
import 'widgets/mood_selector.dart';
import 'widgets/rich_text_editor.dart';
import 'widgets/sentiment_selector.dart';
import 'widgets/tags_selector.dart';
import 'widgets/trade_overview_selector.dart';
import 'widgets/trade_preview_dialog.dart';
import 'widgets/url_preview_widget.dart';

class JournalEntryForm extends ConsumerStatefulWidget {
  const JournalEntryForm({required this.userId, required this.cubit, required this.portfolioId, super.key, this.entry});

  final String userId;
  final JournalCubit cubit;
  final String portfolioId;
  final JournalEntry? entry;

  @override
  ConsumerState<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends ConsumerState<JournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  late TextEditingController _tradeIdController;
  late TextEditingController _urlController;
  late DateTime _entryDate;
  String? _selectedMood;
  String? _marketSentiment;
  final Set<String> _selectedTags = {};
  List<String> _imageUrls = [];
  bool _isSubmitting = false;
  String? _urlPreview;
  bool _isUrlExpanded = false;

  // Trade overview states
  DateTime _tradeOverviewDate = DateTime.now();
  TradePeriodType _tradePeriod = TradePeriodType.daily;
  List<String> _relatedTradeIds = [];
  List<TradeHoldingViewModel> _availableTrades = [];
  bool _isLoadingTrades = false;
  bool _isEditMode = false; // View mode by default when editing existing entry

  @override
  void initState() {
    super.initState();

    // Set edit mode: true for new entries, false for existing (view mode)
    _isEditMode = widget.entry == null;

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

    if (widget.entry?.imageUrls != null) {
      _imageUrls = List.from(widget.entry!.imageUrls);
    }

    if (widget.entry?.relatedTradeIds != null) {
      _relatedTradeIds = List.from(widget.entry!.relatedTradeIds);
    }

    _tradeOverviewDate = widget.entry?.entryDate ?? DateTime.now();

    _urlController.addListener(_onUrlChanged);

    // Load trades for the entry date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTradesForPeriod(_tradeOverviewDate, _tradePeriod);
    });
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
    print('URL Changed: $text'); // Debug
    if (text.isNotEmpty && (text.startsWith('http://') || text.startsWith('https://'))) {
      print('Setting preview for: $text'); // Debug
      setState(() => _urlPreview = text);
    } else {
      print('Clearing preview'); // Debug
      setState(() => _urlPreview = null);
    }
  }

  Future<void> _loadTradesForPeriod(DateTime date, TradePeriodType period) async {
    setState(() => _isLoadingTrades = true);

    try {
      DateTime startDate;
      DateTime endDate;

      switch (period) {
        case TradePeriodType.daily:
          final getTradeCalendarByDay = ref.read(getTradeCalendarByDayProvider);
          final calendar = await getTradeCalendarByDay(widget.userId, widget.portfolioId, date: date);
          final trades = calendar.allTrades;
          setState(() {
            _availableTrades = TradeHoldingViewModel.fromEntityList(trades);
            _isLoadingTrades = false;
          });
          return;

        case TradePeriodType.weekly:
          startDate = date.subtract(Duration(days: date.weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
          break;

        case TradePeriodType.monthly:
          final getTradeCalendarByMonth = ref.read(getTradeCalendarByMonthProvider);
          final calendar = await getTradeCalendarByMonth(
            widget.userId,
            widget.portfolioId,
            year: date.year,
            month: date.month,
          );
          final trades = calendar.allTrades;
          setState(() {
            _availableTrades = TradeHoldingViewModel.fromEntityList(trades);
            _isLoadingTrades = false;
          });
          return;

        case TradePeriodType.yearly:
          startDate = DateTime(date.year);
          endDate = DateTime(date.year, 12, 31);
          break;
      }

      // For weekly and yearly, use date range
      final getTradeCalendarByDateRange = ref.read(getTradeCalendarByDateRangeProvider);
      final calendar = await getTradeCalendarByDateRange(
        widget.userId,
        widget.portfolioId,
        startDate: startDate,
        endDate: endDate,
      );

      final trades = calendar.allTrades;
      setState(() {
        _availableTrades = TradeHoldingViewModel.fromEntityList(trades);
        _isLoadingTrades = false;
      });
    } catch (e, stackTrace) {
      print('Error loading trades for period: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _availableTrades = [];
        _isLoadingTrades = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trades: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showTradePreview() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => TradePreviewDialog(
        date: _tradeOverviewDate,
        trades: _availableTrades,
        selectedTradeIds: _relatedTradeIds,
        periodType: _tradePeriod,
      ),
    );

    if (result != null) {
      setState(() => _relatedTradeIds = result);
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
            imageUrls: _imageUrls.isEmpty ? null : _imageUrls,
            relatedTradeIds: _relatedTradeIds.isEmpty ? null : _relatedTradeIds,
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
            imageUrls: _imageUrls.isEmpty ? null : _imageUrls,
            relatedTradeIds: _relatedTradeIds.isEmpty ? null : _relatedTradeIds,
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
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: _buildMainContent()),
  );

  Widget _buildMainContent() => Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildLeftColumn(context)),
            const SizedBox(width: 20),
            Expanded(child: _buildRightColumn()),
          ],
        ),
      ],
    ),
  );

  Widget _buildLeftColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildTitleField(),
      const SizedBox(height: 12),
      RichTextEditor(controller: _quillController, readOnly: !_isEditMode),
      const SizedBox(height: 16),
      _buildBottomFields(context),
      const SizedBox(height: 16),
      _buildUpdateButton(),
    ],
  );

  Widget _buildTitleField() => TextFormField(
    controller: _titleController,
    enabled: _isEditMode,
    decoration: InputDecoration(
      label: Container(padding: const EdgeInsets.symmetric(horizontal: 4), child: const Text('Title')),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      hintText: 'e.g., "AAPL Breakout" or "Lesson: Don\'t Chase"',
      prefixIcon: const Icon(Icons.title, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  );

  Widget _buildUrlField() {
    final theme = Theme.of(context);
    final hasUrl = _urlController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasUrl ? theme.colorScheme.primary.withOpacity(0.5) : theme.dividerColor.withOpacity(0.5),
          width: hasUrl ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasUrl ? theme.colorScheme.primaryContainer.withOpacity(0.1) : null,
      ),
      child: TextFormField(
        controller: _urlController,
        decoration: InputDecoration(
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add URL (optional)'),
                if (hasUrl) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle, size: 14, color: theme.colorScheme.primary),
                ],
              ],
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          hintText: 'https://tradingview.com/chart/...',
          prefixIcon: Icon(Icons.link, size: 20, color: hasUrl ? theme.colorScheme.primary : null),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRightColumn() => IgnorePointer(
    ignoring: !_isEditMode,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(
          ignoring: !_isEditMode,
          child: MoodSelector(
            selectedMood: _selectedMood,
            onMoodSelected: (mood) => setState(() => _selectedMood = mood),
          ),
        ),
        const SizedBox(height: 16),
        SentimentSelector(
          selectedSentiment: _marketSentiment,
          onSentimentSelected: (sentiment) => setState(() => _marketSentiment = sentiment),
        ),
        const SizedBox(height: 16),
        TagsSelector(selectedTags: _selectedTags, onTagToggled: _toggleTag),
        const SizedBox(height: 16),

        // Trade Overview Section
        TradeOverviewSelector(
          selectedDate: _tradeOverviewDate,
          selectedPeriod: _tradePeriod,
          selectedTradeIds: _relatedTradeIds,
          availableTrades: _availableTrades,
          onDateChanged: (date) {
            setState(() => _tradeOverviewDate = date);
            _loadTradesForPeriod(date, _tradePeriod);
          },
          onPeriodChanged: (period) {
            setState(() => _tradePeriod = period);
            _loadTradesForPeriod(_tradeOverviewDate, period);
          },
          onTradesSelected: (ids) => setState(() => _relatedTradeIds = ids),
          onViewTrades: _showTradePreview,
        ),
        const SizedBox(height: 16),

        AttachmentPicker(
          initialUrls: _imageUrls,
          onAttachmentsChanged: (urls) {
            print('📎 [FORM] Attachments changed: $urls');
            setState(() => _imageUrls = urls);
          },
          featureName: 'journal',
          userId: widget.userId,
        ),
      ],
    ),
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
        decoration: InputDecoration(
          label: Container(padding: const EdgeInsets.symmetric(horizontal: 4), child: const Text('Date (optional)')),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      decoration: InputDecoration(
        label: Container(padding: const EdgeInsets.symmetric(horizontal: 4), child: const Text('Trade ID (optional)')),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: 'Optional',
        prefixIcon: const Icon(Icons.tag, size: 18),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );

  Widget _buildBottomFields(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Trade ID row (always visible)
          Row(
            children: [
              Expanded(child: _buildDateField(theme)),
              const SizedBox(width: 12),
              Expanded(child: _buildTradeIdField(theme)),
            ],
          ),

          // URL expand/collapse button
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _isUrlExpanded = !_isUrlExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isUrlExpanded
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.dividerColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
                color: _isUrlExpanded ? theme.colorScheme.primaryContainer.withOpacity(0.2) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 18,
                    color: _isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isUrlExpanded ? 'Add URL' : 'Add URL (optional)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: _isUrlExpanded ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isUrlExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: _isUrlExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable URL field
          if (_isUrlExpanded) ...[
            const SizedBox(height: 8),
            _buildUrlField(),
            if (_urlPreview != null) ...[
              const SizedBox(height: 8),
              UrlPreviewWidget(
                url: _urlPreview!,
                onClose: () {
                  _urlController.clear();
                  setState(() => _urlPreview = null);
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    if (!_isEditMode && widget.entry != null) {
      // View mode - show Edit button
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => setState(() => _isEditMode = true),
          icon: const Icon(Icons.edit, size: 20),
          label: const Text('Edit Entry'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
        ),
      );
    }

    // Edit mode or new entry - show Update/Create button
    return Row(
      children: [
        if (widget.entry != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : () => setState(() => _isEditMode = false),
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, size: 20),
            label: Text(widget.entry == null ? 'Create Entry' : 'Update Entry'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
          ),
        ),
      ],
    );
  }
}
