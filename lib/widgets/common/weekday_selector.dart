// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../l10n/app_strings.dart';

/// A Material 3 multi-select weekday picker using FilterChip widgets.
///
/// Displays a horizontal row of chips for each day of the week, allowing users
/// to select multiple days for weekly pattern scheduling.
///
/// Features:
/// - Material 3 FilterChip design
/// - Localized day names (short 2-letter format)
/// - Minimum 48dp touch targets for accessibility
/// - Keyboard navigation support
/// - Semantic labels for screen readers
/// - Optional preset buttons (weekdays, weekends, etc.)
///
/// Example usage:
/// ```dart
/// WeekdaySelector(
///   selectedDays: {DayOfWeek.MONDAY, DayOfWeek.WEDNESDAY},
///   onChanged: (days) => setState(() => _selectedDays = days),
/// )
/// ```
class WeekdaySelector extends StatelessWidget {
  /// Currently selected days of the week
  final Set<DayOfWeek> selectedDays;

  /// Callback when selection changes
  final ValueChanged<Set<DayOfWeek>> onChanged;

  /// Whether the selector is enabled
  final bool enabled;

  /// Whether to show preset buttons (weekdays, weekends)
  final bool showPresets;

  /// Optional theme color from task list for visual consistency
  final Color? themeColor;

  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    this.enabled = true,
    this.showPresets = false,
    this.themeColor,
  });

  /// Returns localized short name for a day of week
  String _getDayShortName(BuildContext context, DayOfWeek day) {
    final strings = AppStrings.of(context);
    switch (day) {
      case DayOfWeek.MONDAY:
        return strings.mondayShort;
      case DayOfWeek.TUESDAY:
        return strings.tuesdayShort;
      case DayOfWeek.WEDNESDAY:
        return strings.wednesdayShort;
      case DayOfWeek.THURSDAY:
        return strings.thursdayShort;
      case DayOfWeek.FRIDAY:
        return strings.fridayShort;
      case DayOfWeek.SATURDAY:
        return strings.saturdayShort;
      case DayOfWeek.SUNDAY:
        return strings.sundayShort;
    }
  }

  /// Returns localized full name for a day of week (for accessibility)
  String _getDayFullName(BuildContext context, DayOfWeek day) {
    final strings = AppStrings.of(context);
    switch (day) {
      case DayOfWeek.MONDAY:
        return strings.monday;
      case DayOfWeek.TUESDAY:
        return strings.tuesday;
      case DayOfWeek.WEDNESDAY:
        return strings.wednesday;
      case DayOfWeek.THURSDAY:
        return strings.thursday;
      case DayOfWeek.FRIDAY:
        return strings.friday;
      case DayOfWeek.SATURDAY:
        return strings.saturday;
      case DayOfWeek.SUNDAY:
        return strings.sunday;
    }
  }

  /// Toggles selection of a specific day
  void _toggleDay(DayOfWeek day) {
    if (!enabled) return;

    final newSelection = Set<DayOfWeek>.from(selectedDays);
    if (newSelection.contains(day)) {
      newSelection.remove(day);
    } else {
      newSelection.add(day);
    }
    onChanged(newSelection);
  }

  /// Applies a preset selection
  void _applyPreset(Set<DayOfWeek> preset) {
    if (!enabled) return;
    onChanged(preset);
  }

  /// Preset: Monday through Friday
  static const Set<DayOfWeek> weekdaysPreset = {
    DayOfWeek.MONDAY,
    DayOfWeek.TUESDAY,
    DayOfWeek.WEDNESDAY,
    DayOfWeek.THURSDAY,
    DayOfWeek.FRIDAY,
  };

  /// Preset: Saturday and Sunday
  static const Set<DayOfWeek> weekendsPreset = {
    DayOfWeek.SATURDAY,
    DayOfWeek.SUNDAY,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    // Brug tema-farve hvis tilgængelig
    final primaryColor = themeColor ?? colorScheme.primary;

    // Days ordered Monday through Sunday (ISO 8601 week standard)
    final orderedDays = [
      DayOfWeek.MONDAY,
      DayOfWeek.TUESDAY,
      DayOfWeek.WEDNESDAY,
      DayOfWeek.THURSDAY,
      DayOfWeek.FRIDAY,
      DayOfWeek.SATURDAY,
      DayOfWeek.SUNDAY,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day selector chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: orderedDays.map((day) {
            final isSelected = selectedDays.contains(day);
            final shortName = _getDayShortName(context, day);
            final fullName = _getDayFullName(context, day);

            return Semantics(
              label: fullName,
              selected: isSelected,
              button: true,
              enabled: enabled,
              child: FilterChip(
                label: Text(shortName),
                selected: isSelected,
                onSelected: enabled ? (_) => _toggleDay(day) : null,
                // Ensure minimum 48dp touch target height
                materialTapTargetSize: MaterialTapTargetSize.padded,
                // Tema-farvede styling
                selectedColor: primaryColor.withValues(alpha: 0.2),
                checkmarkColor: primaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? primaryColor
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                // Ensure consistent width for alignment
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.standard,
              ),
            );
          }).toList(),
        ),

        // Optional preset buttons
        if (showPresets) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Weekdays preset
              OutlinedButton.icon(
                onPressed: enabled
                    ? () => _applyPreset(weekdaysPreset)
                    : null,
                icon: Icon(Icons.work_outline, size: 18, color: primaryColor),
                label: Text(strings.weekdays),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: primaryColor,
                ),
              ),

              // Weekends preset
              OutlinedButton.icon(
                onPressed: enabled
                    ? () => _applyPreset(weekendsPreset)
                    : null,
                icon: Icon(Icons.weekend_outlined, size: 18, color: primaryColor),
                label: Text(strings.weekends),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: primaryColor,
                ),
              ),

              // Clear selection
              if (selectedDays.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: enabled ? () => onChanged({}) : null,
                  icon: const Icon(Icons.clear, size: 18),
                  label: Text(strings.clear),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Extension to provide helper methods for day of week collections
extension DayOfWeekSetExtension on Set<DayOfWeek> {
  /// Returns a human-readable description of selected days
  String describe(BuildContext context) {
    final strings = AppStrings.of(context);

    if (isEmpty) return strings.selectDays;

    // Check for common patterns
    if (containsAll(WeekdaySelector.weekdaysPreset) &&
        length == WeekdaySelector.weekdaysPreset.length) {
      return strings.weekdays;
    }

    if (containsAll(WeekdaySelector.weekendsPreset) &&
        length == WeekdaySelector.weekendsPreset.length) {
      return strings.weekends;
    }

    // List individual days
    final orderedDays = [
      DayOfWeek.MONDAY,
      DayOfWeek.TUESDAY,
      DayOfWeek.WEDNESDAY,
      DayOfWeek.THURSDAY,
      DayOfWeek.FRIDAY,
      DayOfWeek.SATURDAY,
      DayOfWeek.SUNDAY,
    ];

    final selectedInOrder = orderedDays.where((day) => contains(day)).toList();

    // For 3 or fewer days, show short names
    if (selectedInOrder.length <= 3) {
      return selectedInOrder.map((day) {
        switch (day) {
          case DayOfWeek.MONDAY:
            return strings.mondayShort;
          case DayOfWeek.TUESDAY:
            return strings.tuesdayShort;
          case DayOfWeek.WEDNESDAY:
            return strings.wednesdayShort;
          case DayOfWeek.THURSDAY:
            return strings.thursdayShort;
          case DayOfWeek.FRIDAY:
            return strings.fridayShort;
          case DayOfWeek.SATURDAY:
            return strings.saturdayShort;
          case DayOfWeek.SUNDAY:
            return strings.sundayShort;
        }
      }).join(', ');
    }

    // For more than 3 days, show count
    return '$length ${strings.selectDays.toLowerCase()}';
  }
}
