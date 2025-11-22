import 'package:flutter/material.dart';

import '../../../../../shared/core/ui/components/trade/derivative_card.dart';
import '../../../../../shared/core/ui/components/trade/direction_status_selector.dart';
import '../../../../../shared/core/ui/components/trade/entry_card.dart';
import '../../../../../shared/core/ui/components/trade/exit_card.dart';
import '../../../../../shared/core/ui/components/trade/instrument_card.dart';
import '../../../../../shared/core/ui/components/trade/trade_settings_card.dart';
import '../../../internal/domain/enums/broker_types.dart';
import '../../../internal/domain/enums/derivative_types.dart';
import '../../../internal/domain/enums/exchange_types.dart';
import '../../../internal/domain/enums/market_segments.dart';
import '../../../internal/domain/enums/option_types.dart';
import '../../../internal/domain/enums/order_types.dart';
import '../../../internal/domain/enums/trade_directions.dart';
import '../../../internal/domain/enums/trade_statuses.dart';
import '../widgets/attachment_picker.dart';

/// Trade Details Step - Combined Instrument + Entry/Exit
class TradeDetailsStep extends StatelessWidget {
  const TradeDetailsStep({
    required this.symbolController,
    required this.selectedExchange,
    required this.selectedSegment,
    required this.selectedDirection,
    required this.selectedStatus,
    required this.entryDate,
    required this.entryPriceController,
    required this.entryQuantityController,
    required this.exitDate,
    required this.exitPriceController,
    required this.exitQuantityController,
    required this.selectedBroker,
    required this.selectedOrderType,
    required this.selectedDerivativeType,
    required this.selectedOptionType,
    required this.strikePriceController,
    required this.expiryDate,
    required this.attachments,
    required this.onExchangeChanged,
    required this.onSegmentChanged,
    required this.onDirectionChanged,
    required this.onStatusChanged,
    required this.onEntryDateSelected,
    required this.onExitDateSelected,
    required this.onBrokerChanged,
    required this.onOrderTypeChanged,
    required this.onDerivativeTypeChanged,
    required this.onOptionTypeChanged,
    required this.onExpiryDateSelected,
    required this.onAttachmentsChanged,
    super.key,
  });

  final TextEditingController symbolController;
  final ExchangeTypes? selectedExchange;
  final MarketSegments? selectedSegment;
  final TradeDirections selectedDirection;
  final TradeStatuses selectedStatus;
  final DateTime? entryDate;
  final TextEditingController entryPriceController;
  final TextEditingController entryQuantityController;
  final DateTime? exitDate;
  final TextEditingController exitPriceController;
  final TextEditingController exitQuantityController;
  final BrokerTypes? selectedBroker;
  final OrderTypes? selectedOrderType;
  final DerivativeTypes? selectedDerivativeType;
  final OptionTypes? selectedOptionType;
  final TextEditingController strikePriceController;
  final DateTime? expiryDate;
  final List<String> attachments;

  final ValueChanged<ExchangeTypes?> onExchangeChanged;
  final ValueChanged<MarketSegments?> onSegmentChanged;
  final ValueChanged<TradeDirections> onDirectionChanged;
  final ValueChanged<TradeStatuses> onStatusChanged;
  final ValueChanged<DateTime> onEntryDateSelected;
  final ValueChanged<DateTime> onExitDateSelected;
  final ValueChanged<BrokerTypes?> onBrokerChanged;
  final ValueChanged<OrderTypes?> onOrderTypeChanged;
  final ValueChanged<DerivativeTypes?> onDerivativeTypeChanged;
  final ValueChanged<OptionTypes?> onOptionTypeChanged;
  final ValueChanged<DateTime> onExpiryDateSelected;
  final ValueChanged<List<String>> onAttachmentsChanged;

  bool get _isDerivativeSegment =>
      selectedSegment == MarketSegments.equityFutures ||
      selectedSegment == MarketSegments.indexFutures ||
      selectedSegment == MarketSegments.equityOptions ||
      selectedSegment == MarketSegments.indexOptions;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 1200;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction & Status Row
          DirectionStatusSelector(
            selectedDirection: selectedDirection,
            selectedStatus: selectedStatus,
            onDirectionChanged: onDirectionChanged,
            onStatusChanged: onStatusChanged,
          ),

          const SizedBox(height: 12),

          // Instrument & Entry in 2 columns (desktop) or stacked (mobile)
          if (isDesktop || isTablet)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InstrumentCard(
                    symbolController: symbolController,
                    selectedExchange: selectedExchange,
                    selectedSegment: selectedSegment,
                    onExchangeChanged: onExchangeChanged,
                    onSegmentChanged: onSegmentChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EntryCard(
                    entryDate: entryDate,
                    entryPriceController: entryPriceController,
                    entryQuantityController: entryQuantityController,
                    onDateTap: () => _selectEntryDate(context),
                  ),
                ),
              ],
            )
          else ...[
            InstrumentCard(
              symbolController: symbolController,
              selectedExchange: selectedExchange,
              selectedSegment: selectedSegment,
              onExchangeChanged: onExchangeChanged,
              onSegmentChanged: onSegmentChanged,
            ),
            const SizedBox(height: 16),
            EntryCard(
              entryDate: entryDate,
              entryPriceController: entryPriceController,
              entryQuantityController: entryQuantityController,
              onDateTap: () => _selectEntryDate(context),
            ),
          ],

          // Exit Section (if closed)
          if (selectedStatus == TradeStatuses.closed) ...[
            const SizedBox(height: 16),
            ExitCard(
              exitDate: exitDate,
              exitPriceController: exitPriceController,
              exitQuantityController: exitQuantityController,
              entryDate: entryDate,
              onDateTap: () => _selectExitDate(context),
            ),
          ],

          // Broker & Order Type Row
          const SizedBox(height: 16),
          TradeSettingsCard(
            selectedBroker: selectedBroker,
            selectedOrderType: selectedOrderType,
            onBrokerChanged: onBrokerChanged,
            onOrderTypeChanged: onOrderTypeChanged,
          ),

          // Derivatives (if any)
          if (_isDerivativeSegment) ...[
            const SizedBox(height: 16),
            DerivativeCard(
              selectedDerivativeType: selectedDerivativeType,
              selectedOptionType: selectedOptionType,
              strikePriceController: strikePriceController,
              expiryDate: expiryDate,
              onDerivativeTypeChanged: onDerivativeTypeChanged,
              onOptionTypeChanged: onOptionTypeChanged,
              onExpiryDateTap: () => _selectExpiryDate(context),
            ),
          ],

          // Attachments
          const SizedBox(height: 16),
          AttachmentPicker(attachments: attachments, onAttachmentsChanged: onAttachmentsChanged),
        ],
      ),
    );
  }

  Future<void> _selectEntryDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: entryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) onEntryDateSelected(date);
  }

  Future<void> _selectExitDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: exitDate ?? DateTime.now(),
      firstDate: entryDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) onExitDateSelected(date);
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) onExpiryDateSelected(date);
  }
}
