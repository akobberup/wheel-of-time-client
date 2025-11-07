import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/enums.dart';

/// A Material 3 recurrence field that combines numerical delta and unit selection
/// in a single, cohesive TextField component.
///
/// The field displays as: "every [number] [unit]"
/// - Prefix: Static "every" text
/// - Main input: Numerical delta (positive integers only)
/// - Suffix: Current unit with dropdown icon (tappable to change unit)
///
/// Example: "every 2 weeks"
class RecurrenceField extends StatefulWidget {
  /// Initial repeat delta value (defaults to 1)
  final int initialDelta;

  /// Initial repeat unit (defaults to WEEKS)
  final RepeatUnit initialUnit;

  /// Callback when delta changes (triggered on valid input)
  final ValueChanged<int> onDeltaChanged;

  /// Callback when unit changes (triggered immediately on selection)
  final ValueChanged<RepeatUnit> onUnitChanged;

  /// Optional validator for the delta input
  final FormFieldValidator<String>? validator;

  /// Whether the field is enabled
  final bool enabled;

  const RecurrenceField({
    super.key,
    this.initialDelta = 1,
    this.initialUnit = RepeatUnit.WEEKS,
    required this.onDeltaChanged,
    required this.onUnitChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<RecurrenceField> createState() => _RecurrenceFieldState();
}

class _RecurrenceFieldState extends State<RecurrenceField> {
  late TextEditingController _deltaController;
  late RepeatUnit _currentUnit;

  @override
  void initState() {
    super.initState();
    _deltaController = TextEditingController(text: widget.initialDelta.toString());
    _currentUnit = widget.initialUnit;
  }

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  /// Converts RepeatUnit enum to singular display format
  /// DAYS -> "day", WEEKS -> "week", MONTHS -> "month", YEARS -> "year"
  String _getUnitDisplayName(RepeatUnit unit) {
    switch (unit) {
      case RepeatUnit.DAYS:
        return 'day';
      case RepeatUnit.WEEKS:
        return 'week';
      case RepeatUnit.MONTHS:
        return 'month';
      case RepeatUnit.YEARS:
        return 'year';
    }
  }

  /// Converts RepeatUnit enum to plural display format for menu items
  /// DAYS -> "Days", WEEKS -> "Weeks", etc.
  String _getUnitMenuLabel(RepeatUnit unit) {
    switch (unit) {
      case RepeatUnit.DAYS:
        return 'Days';
      case RepeatUnit.WEEKS:
        return 'Weeks';
      case RepeatUnit.MONTHS:
        return 'Months';
      case RepeatUnit.YEARS:
        return 'Years';
    }
  }

  /// Shows a menu to select the repeat unit
  void _showUnitMenu() async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Show menu anchored to the text field
    final selected = await showMenu<RepeatUnit>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width - 200, // Align to right side of field
        offset.dy + size.height, // Below the field
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: RepeatUnit.values.map((unit) {
        return PopupMenuItem<RepeatUnit>(
          value: unit,
          child: Row(
            children: [
              // Show checkmark for currently selected unit
              SizedBox(
                width: 24,
                child: _currentUnit == unit
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(_getUnitMenuLabel(unit)),
            ],
          ),
        );
      }).toList(),
      elevation: 8,
    );

    // Update unit if selection was made
    if (selected != null && selected != _currentUnit) {
      setState(() {
        _currentUnit = selected;
      });
      widget.onUnitChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: _deltaController,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      // Only allow digits to be entered
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Recurrence',
        border: const OutlineInputBorder(),
        // Prefix shows static "every" text in a muted color
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0,
            child: Text(
              'every',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        // Suffix shows current unit with dropdown icon, tappable to open menu
        suffixIcon: InkWell(
          onTap: widget.enabled ? _showUnitMenu : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pluralize the unit name if delta > 1
                Text(
                  int.tryParse(_deltaController.text) == 1
                      ? _getUnitDisplayName(_currentUnit)
                      : '${_getUnitDisplayName(_currentUnit)}s',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: widget.enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ],
            ),
          ),
        ),
      ),
      // Validate that input is a positive integer
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number';
            }
            final n = int.tryParse(value);
            if (n == null || n < 1) {
              return 'Please enter a valid number (1 or more)';
            }
            return null;
          },
      // Notify parent of valid delta changes
      onChanged: (value) {
        // Trigger rebuild to update plural/singular unit display
        setState(() {});

        final n = int.tryParse(value);
        if (n != null && n > 0) {
          widget.onDeltaChanged(n);
        }
      },
    );
  }
}
