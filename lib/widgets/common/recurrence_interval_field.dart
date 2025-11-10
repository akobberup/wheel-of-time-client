import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/enums.dart';
import '../../l10n/app_strings.dart';

/// A Material 3 recurrence interval field for selecting repeat delta and unit.
///
/// This is a composable version of the original RecurrenceField, designed to work
/// within the RecurrenceEditor. It displays as: "every [number] [unit]"
///
/// Example: "every 2 weeks"
///
/// Features:
/// - Prefix: Static "every" text
/// - Main input: Numerical delta (positive integers only)
/// - Suffix: Current unit with dropdown icon (tappable to change unit)
/// - Clean separation of concerns for use in composite widgets
///
/// Usage:
/// ```dart
/// RecurrenceIntervalField(
///   repeatDelta: 2,
///   repeatUnit: RepeatUnit.WEEKS,
///   onChanged: (delta, unit) {
///     setState(() {
///       _delta = delta;
///       _unit = unit;
///     });
///   },
/// )
/// ```
class RecurrenceIntervalField extends StatefulWidget {
  /// Current repeat delta value
  final int repeatDelta;

  /// Current repeat unit
  final RepeatUnit repeatUnit;

  /// Callback when either delta or unit changes
  /// Parameters: (newDelta, newUnit)
  final void Function(int delta, RepeatUnit unit) onChanged;

  /// Optional validator for the delta input
  final FormFieldValidator<String>? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Optional label text (defaults to localized "Recurrence")
  final String? labelText;

  const RecurrenceIntervalField({
    super.key,
    required this.repeatDelta,
    required this.repeatUnit,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.labelText,
  });

  @override
  State<RecurrenceIntervalField> createState() => _RecurrenceIntervalFieldState();
}

class _RecurrenceIntervalFieldState extends State<RecurrenceIntervalField> {
  late TextEditingController _deltaController;
  late RepeatUnit _currentUnit;

  @override
  void initState() {
    super.initState();
    _deltaController = TextEditingController(text: widget.repeatDelta.toString());
    _currentUnit = widget.repeatUnit;
  }

  @override
  void didUpdateWidget(RecurrenceIntervalField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if delta changed externally
    if (widget.repeatDelta != oldWidget.repeatDelta) {
      _deltaController.text = widget.repeatDelta.toString();
    }

    // Update unit if changed externally
    if (widget.repeatUnit != oldWidget.repeatUnit) {
      setState(() {
        _currentUnit = widget.repeatUnit;
      });
    }
  }

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  /// Converts RepeatUnit enum to singular display format
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

      // Parse current delta and notify parent
      final delta = int.tryParse(_deltaController.text) ?? 1;
      widget.onChanged(delta, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return TextFormField(
      controller: _deltaController,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      // Only allow digits to be entered
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: widget.labelText ?? strings.recurrence,
        border: const OutlineInputBorder(),
        // Prefix shows static "every" text in a muted color
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0,
            child: Text(
              strings.every,
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
          widget.onChanged(n, _currentUnit);
        }
      },
    );
  }
}
