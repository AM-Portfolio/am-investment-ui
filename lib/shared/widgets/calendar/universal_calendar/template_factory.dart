import 'package:flutter/material.dart';

import 'config.dart';
import 'templates/display_template.dart';
import 'templates/filter_template.dart';
import 'templates/layout_template.dart';
import 'types.dart';

/// Factory for creating calendar template components
/// Handles the creation of filter, display, and layout templates
class UniversalCalendarTemplateFactory {
  /// Create filter template for date selection logic
  static Widget createFilterTemplate({
    required CalendarConfig config,
    required DateSelection currentSelection,
    required Function(DateSelection) onSelectionChanged,
  }) => CalendarFilterTemplate(
    config: config.filterConfig,
    currentSelection: currentSelection,
    onSelectionChanged: onSelectionChanged,
  );

  /// Create display template for visual presentation
  static Widget createDisplayTemplate({
    required CalendarConfig config,
    required DateSelection currentSelection,
    required Function(DateSelection) onSelectionChanged,
    Widget? customContent,
  }) => CalendarDisplayTemplate(
    config: config.displayConfig,
    filterConfig: config.filterConfig,
    currentSelection: currentSelection,
    onSelectionChanged: onSelectionChanged,
    customContent: customContent,
  );

  /// Create layout template for overall structure
  static Widget createLayoutTemplate({
    required BuildContext context,
    required CalendarConfig config,
    required DateSelection currentSelection,
    required Function(DateSelection) onSelectionChanged,
    Widget? customHeader,
    Widget? customFooter,
  }) {
    // Create child templates based on configuration
    final filterTemplate = createFilterTemplate(
      config: config,
      currentSelection: currentSelection,
      onSelectionChanged: onSelectionChanged,
    );

    final displayTemplate = createDisplayTemplate(
      config: config,
      currentSelection: currentSelection,
      onSelectionChanged: onSelectionChanged,
      customContent: filterTemplate,
    );

    return CalendarLayoutTemplate(
      config: config.layoutConfig,
      currentSelection: currentSelection,
      onSelectionChanged: onSelectionChanged,
      customHeader: customHeader,
      customFooter: customFooter,
      child: displayTemplate,
    );
  }

  /// Create complete calendar widget with all templates composed
  static Widget createCalendarWidget({
    required BuildContext context,
    required CalendarConfig config,
    required Function(DateSelection) onSelectionChanged,
    DateSelection? initialSelection,
    Widget? customHeader,
    Widget? customFooter,
  }) {
    final currentSelection =
        initialSelection ??
        const DateSelection(
          startDate: null,
          endDate: null,
          description: 'All Time',
          filterType: DateFilterMode.quick,
        );

    return createLayoutTemplate(
      context: context,
      config: config,
      currentSelection: currentSelection,
      onSelectionChanged: onSelectionChanged,
      customHeader: customHeader,
      customFooter: customFooter,
    );
  }

  /// Helper method to get template type based on screen size and config
  static CalendarTemplateType getAdaptiveTemplateType(
    BuildContext context,
    CalendarConfig config,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If explicitly set, use that
    if (config.layoutConfig.templateType != CalendarTemplateType.adaptive) {
      return config.layoutConfig.templateType;
    }

    // Adaptive logic
    if (screenWidth < 600) {
      return config.displayConfig.compactMode
          ? CalendarTemplateType.minimal
          : CalendarTemplateType.compact;
    } else if (screenWidth < 900) {
      return CalendarTemplateType.compact;
    } else {
      return CalendarTemplateType.full;
    }
  }
}
