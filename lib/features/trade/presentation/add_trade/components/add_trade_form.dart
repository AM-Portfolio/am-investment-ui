import 'package:flutter/material.dart';

import '../../../internal/domain/entities/trade_controller_entities.dart';
import '../../../internal/domain/enums/broker_types.dart';
import '../../../internal/domain/enums/derivative_types.dart';
import '../../../internal/domain/enums/exchange_types.dart';
import '../../../internal/domain/enums/fundamental_reasons.dart';
import '../../../internal/domain/enums/market_segments.dart';
import '../../../internal/domain/enums/option_types.dart';
import '../../../internal/domain/enums/order_types.dart';
import '../../../internal/domain/enums/psychology_factors.dart';
import '../../../internal/domain/enums/technical_reasons.dart';
import '../../../internal/domain/enums/trade_directions.dart';
import '../../../internal/domain/enums/trade_statuses.dart';
import '../steps/optional_details_step.dart';
import '../steps/review_step.dart';
// Modular step components
import '../steps/trade_details_step.dart';

/// Modular 3-step Add Trade Form
/// Step 1: Trade Details (instrument + entry/exit combined)
/// Step 2: Optional Details (psychology, reasoning, strategy - OPTIONAL)
/// Step 3: Review & Submit
class AddTradeForm extends StatefulWidget {
  const AddTradeForm({super.key, this.onCancel, this.onSave, this.isLoading = false, this.initialData});
  final VoidCallback? onCancel;
  final Function(TradeDetails)? onSave;
  final bool isLoading;
  final TradeDetails? initialData;

  @override
  State<AddTradeForm> createState() => _AddTradeFormState();
}

class _AddTradeFormState extends State<AddTradeForm> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Combined Trade Details
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _isinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ExchangeTypes? _selectedExchange;
  MarketSegments? _selectedSegment;
  DerivativeTypes? _selectedDerivativeType;
  OptionTypes? _selectedOptionType;
  final TextEditingController _strikePriceController = TextEditingController();
  DateTime? _expiryDate;

  // Entry & Exit (same step)
  TradeDirections _selectedDirection = TradeDirections.long;
  TradeStatuses _selectedStatus = TradeStatuses.open;
  DateTime? _entryDate;
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _entryQuantityController = TextEditingController();
  DateTime? _exitDate;
  final TextEditingController _exitPriceController = TextEditingController();
  final TextEditingController _exitQuantityController = TextEditingController();
  BrokerTypes? _selectedBroker;
  OrderTypes? _selectedOrderType;
  List<String> _attachments = [];

  // Step 2: Optional Details
  final TextEditingController _strategyController = TextEditingController();
  List<EntryPsychologyFactors> _selectedEntryPsychology = [];
  List<ExitPsychologyFactors> _selectedExitPsychology = [];
  List<TechnicalReasons> _selectedTechnicalReasons = [];
  List<FundamentalReasons> _selectedFundamentalReasons = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    // TODO: Load from initialData if editing
  }

  @override
  void dispose() {
    _pageController.dispose();
    _symbolController.dispose();
    _isinController.dispose();
    _descriptionController.dispose();
    _strikePriceController.dispose();
    _entryPriceController.dispose();
    _entryQuantityController.dispose();
    _exitPriceController.dispose();
    _exitQuantityController.dispose();
    _strategyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _saveTrade() {
    // TODO: Implement proper TradeDetails construction with nested entities
    // See IMPLEMENTATION_STATUS.md for the correct structure

    // For now, show a placeholder message
    if (widget.onSave != null) {
      // This will be replaced with proper entity construction
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Save functionality pending - see IMPLEMENTATION_STATUS.md')));
    }

    /* 
    Proper implementation should construct:
    1. InstrumentInfo from symbol, exchange, segment, derivative fields
    2. EntryExitInfo for entry and exit data
    3. TradePsychologyData from psychology selections
    4. TradeEntryExitReasoning from reasoning selections
    5. Then pass complete TradeDetails entity to widget.onSave
    
    See IMPLEMENTATION_STATUS.md for complete code example
    */
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Column(
      children: [
        // Progress Stepper
        _buildProgressStepper(theme),

        // Content Area with Modular Step Components
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Trade Details (modular component)
              TradeDetailsStep(
                symbolController: _symbolController,
                selectedExchange: _selectedExchange,
                onExchangeChanged: (value) => setState(() => _selectedExchange = value),
                selectedSegment: _selectedSegment,
                onSegmentChanged: (value) => setState(() => _selectedSegment = value),
                selectedDirection: _selectedDirection,
                onDirectionChanged: (value) => setState(() => _selectedDirection = value),
                selectedStatus: _selectedStatus,
                onStatusChanged: (value) => setState(() => _selectedStatus = value),
                entryDate: _entryDate,
                onEntryDateSelected: (date) => setState(() => _entryDate = date),
                entryPriceController: _entryPriceController,
                entryQuantityController: _entryQuantityController,
                exitDate: _exitDate,
                onExitDateSelected: (date) => setState(() => _exitDate = date),
                exitPriceController: _exitPriceController,
                exitQuantityController: _exitQuantityController,
                selectedBroker: _selectedBroker,
                onBrokerChanged: (value) => setState(() => _selectedBroker = value),
                selectedOrderType: _selectedOrderType,
                onOrderTypeChanged: (value) => setState(() => _selectedOrderType = value),
                selectedDerivativeType: _selectedDerivativeType,
                onDerivativeTypeChanged: (value) => setState(() => _selectedDerivativeType = value),
                strikePriceController: _strikePriceController,
                selectedOptionType: _selectedOptionType,
                onOptionTypeChanged: (value) => setState(() => _selectedOptionType = value),
                expiryDate: _expiryDate,
                onExpiryDateSelected: (date) => setState(() => _expiryDate = date),
                attachments: _attachments,
                onAttachmentsChanged: (files) => setState(() => _attachments = files),
              ),

              // Step 2: Optional Details (modular component)
              OptionalDetailsStep(
                strategyController: _strategyController,
                selectedEntryPsychology: _selectedEntryPsychology,
                onEntryPsychologyChanged: (factors) => setState(() => _selectedEntryPsychology = factors),
                selectedExitPsychology: _selectedExitPsychology,
                onExitPsychologyChanged: (factors) => setState(() => _selectedExitPsychology = factors),
                selectedTechnicalReasons: _selectedTechnicalReasons,
                onTechnicalReasonsChanged: (reasons) => setState(() => _selectedTechnicalReasons = reasons),
                selectedFundamentalReasons: _selectedFundamentalReasons,
                onFundamentalReasonsChanged: (reasons) => setState(() => _selectedFundamentalReasons = reasons),
                notesController: _notesController,
              ),

              // Step 3: Review (modular component)
              ReviewStep(
                symbol: _symbolController.text,
                selectedExchange: _selectedExchange,
                selectedSegment: _selectedSegment,
                selectedDirection: _selectedDirection,
                selectedStatus: _selectedStatus,
                entryDate: _entryDate,
                entryPrice: _entryPriceController.text,
                entryQuantity: _entryQuantityController.text,
                exitDate: _exitDate,
                exitPrice: _exitPriceController.text,
                exitQuantity: _exitQuantityController.text,
                selectedBroker: _selectedBroker,
                selectedOrderType: _selectedOrderType,
                strategy: _strategyController.text,
                selectedDerivativeType: _selectedDerivativeType,
                strikePrice: _strikePriceController.text,
                selectedOptionType: _selectedOptionType,
                expiryDate: _expiryDate,
                selectedEntryPsychology: _selectedEntryPsychology,
                selectedExitPsychology: _selectedExitPsychology,
                selectedTechnicalReasons: _selectedTechnicalReasons,
                selectedFundamentalReasons: _selectedFundamentalReasons,
                attachments: _attachments,
                notes: _notesController.text,
              ),
            ],
          ),
        ),

        // Navigation Buttons
        _buildNavigationButtons(theme, isDesktop),
      ],
    );
  }

  Widget _buildProgressStepper(ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStepTitle(index),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (index < _totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
        );
      }),
    ),
  );

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Trade Details';
      case 1:
        return 'Optional';
      case 2:
        return 'Review';
      default:
        return '';
    }
  }

  Widget _buildNavigationButtons(ThemeData theme, bool isDesktop) => Container(
    padding: EdgeInsets.all(isDesktop ? 24 : 16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          OutlinedButton.icon(
            onPressed: widget.isLoading ? null : _previousStep,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          )
        else
          const SizedBox(),
        Row(
          children: [
            if (widget.onCancel != null)
              TextButton(onPressed: widget.isLoading ? null : widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: widget.isLoading
                  ? null
                  : _currentStep == _totalSteps - 1
                  ? _saveTrade
                  : _nextStep,
              icon: widget.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_currentStep == _totalSteps - 1 ? Icons.save : Icons.arrow_forward),
              label: Text(_currentStep == _totalSteps - 1 ? 'Save Trade' : 'Next'),
            ),
          ],
        ),
      ],
    ),
  );
}
