import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../models/schedule.dart';
import '../../l10n/app_strings.dart';
import 'recurrence_interval_field.dart';
import 'seasonal_scheduling_section.dart';
import 'weekday_selector.dart';

/// A comprehensive recurrence editor with clear mode selection for better UX.
///
/// This widget provides two distinct modes:
/// 1. **Simple Interval**: "Every X days/weeks/months/years" - uses interval logic
/// 2. **Specific Days**: "Every X weeks on [selected days]" - uses weekly pattern with day selection
///
/// The key UX improvement: Users explicitly choose which mode they want BEFORE
/// seeing the relevant controls. This eliminates confusion about what happens when
/// both interval and day controls are visible simultaneously.
///
/// Features:
/// - Segmented button for clear mode selection
/// - Mode-specific UI: Only shows relevant controls
/// - Real-time schedule description preview
/// - Material 3 design with proper touch targets (48dp minimum)
/// - Full localization support
///
/// Usage:
/// ```dart
/// RecurrenceEditor(
///   initialSchedule: TaskSchedule.interval(
///     repeatUnit: RepeatUnit.WEEKS,
///     repeatDelta: 1,
///     description: 'Weekly',
///   ),
///   onScheduleChanged: (schedule) {
///     setState(() => _taskSchedule = schedule);
///   },
/// )
/// ```
class RecurrenceEditor extends StatefulWidget {
  /// Initial schedule (can be either interval or weeklyPattern)
  final TaskSchedule initialSchedule;

  /// Callback when the schedule changes
  final ValueChanged<TaskSchedule> onScheduleChanged;

  /// Whether the editor is enabled
  final bool enabled;

  const RecurrenceEditor({
    super.key,
    required this.initialSchedule,
    required this.onScheduleChanged,
    this.enabled = true,
  });

  @override
  State<RecurrenceEditor> createState() => _RecurrenceEditorState();
}

/// Enum representing the two distinct recurrence modes
enum _RecurrenceMode {
  /// Simple interval: Every X days/weeks/months/years
  simpleInterval,

  /// Specific days: Every X weeks on selected weekdays
  specificDays,
}

class _RecurrenceEditorState extends State<RecurrenceEditor> {
  late int _repeatDelta;
  late RepeatUnit _repeatUnit;
  late Set<DayOfWeek> _selectedDays;
  late _RecurrenceMode _mode;
  Set<Month>? _activeMonths;

  @override
  void initState() {
    super.initState();
    _initializeFromSchedule(widget.initialSchedule);
  }

  @override
  void didUpdateWidget(RecurrenceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSchedule != oldWidget.initialSchedule) {
      _initializeFromSchedule(widget.initialSchedule);
    }
  }

  /// Initializes state from a TaskSchedule and determines the appropriate mode
  void _initializeFromSchedule(TaskSchedule schedule) {
    schedule.when(
      interval: (unit, delta, description, activeMonths) {
        _repeatDelta = delta;
        _repeatUnit = unit;
        _selectedDays = {};
        _mode = _RecurrenceMode.simpleInterval;
        _activeMonths = activeMonths;
      },
      weeklyPattern: (weeks, days, description, activeMonths) {
        _repeatDelta = weeks;
        _repeatUnit = RepeatUnit.WEEKS;
        _selectedDays = days;
        // Weekly pattern always means specificDays mode, even with empty days
        _mode = _RecurrenceMode.specificDays;
        _activeMonths = activeMonths;
      },
    );
  }

  /// Builds a TaskSchedule from current state
  TaskSchedule _buildSchedule() {
    // In specificDays mode, always create weekly pattern (even if no days selected yet)
    if (_mode == _RecurrenceMode.specificDays) {
      return TaskSchedule.weeklyPattern(
        repeatWeeks: _repeatDelta,
        daysOfWeek: _selectedDays,
        description: _buildDescription(),
        activeMonths: _activeMonths,
      );
    }

    // In simpleInterval mode, create interval schedule
    return TaskSchedule.interval(
      repeatUnit: _repeatUnit,
      repeatDelta: _repeatDelta,
      description: _buildDescription(),
      activeMonths: _activeMonths,
    );
  }

  /// Builds a human-readable description of the current schedule
  String _buildDescription() {
    final strings = AppStrings.of(context);

    // Specific days mode: Include day information
    if (_mode == _RecurrenceMode.specificDays) {
      if (_selectedDays.isEmpty) {
        // No days selected yet
        if (_repeatDelta == 1) {
          return '${strings.weekly} (${strings.selectDays.toLowerCase()})';
        }
        return '${strings.every} $_repeatDelta weeks (${strings.selectDays.toLowerCase()})';
      }

      // Days are selected
      final daysDesc = _selectedDays.describe(context);
      if (_repeatDelta == 1) {
        return '${strings.weekly} on $daysDesc';
      }
      return '${strings.every} $_repeatDelta weeks on $daysDesc';
    }

    // Simple interval mode: Just interval description
    final unitName = _getUnitName(_repeatUnit);
    if (_repeatDelta == 1) {
      return _getSingularDescription(_repeatUnit);
    }
    return '${strings.every} $_repeatDelta $unitName';
  }

  /// Returns singular description for delta = 1
  String _getSingularDescription(RepeatUnit unit) {
    final strings = AppStrings.of(context);
    switch (unit) {
      case RepeatUnit.DAYS:
        return strings.daily;
      case RepeatUnit.WEEKS:
        return strings.weekly;
      case RepeatUnit.MONTHS:
        return strings.monthly;
      case RepeatUnit.YEARS:
        return strings.yearly;
    }
  }

  /// Returns plural unit name
  String _getUnitName(RepeatUnit unit) {
    switch (unit) {
      case RepeatUnit.DAYS:
        return 'days';
      case RepeatUnit.WEEKS:
        return 'weeks';
      case RepeatUnit.MONTHS:
        return 'months';
      case RepeatUnit.YEARS:
        return 'years';
    }
  }

  /// Handles mode changes from the segmented button
  void _handleModeChanged(_RecurrenceMode? newMode) {
    if (newMode == null || newMode == _mode) return;

    setState(() {
      _mode = newMode;

      // When switching TO specificDays mode, force WEEKS unit
      if (newMode == _RecurrenceMode.specificDays) {
        _repeatUnit = RepeatUnit.WEEKS;
        // Keep existing days if any, or start with empty set
      } else {
        // When switching TO simpleInterval mode, clear selected days
        _selectedDays = {};
        // Keep current unit and delta
      }
    });

    widget.onScheduleChanged(_buildSchedule());
  }

  /// Handles changes to interval (delta or unit) in simple mode
  void _handleIntervalChanged(int delta, RepeatUnit unit) {
    setState(() {
      _repeatDelta = delta;
      _repeatUnit = unit;
    });

    widget.onScheduleChanged(_buildSchedule());
  }

  /// Handles changes to the repeat weeks in specific days mode
  void _handleWeeksChanged(int weeks) {
    setState(() {
      _repeatDelta = weeks;
    });

    widget.onScheduleChanged(_buildSchedule());
  }

  /// Handles changes to selected weekdays in specific days mode
  void _handleDaysChanged(Set<DayOfWeek> days) {
    setState(() {
      _selectedDays = days;
    });

    widget.onScheduleChanged(_buildSchedule());
  }

  /// Handles changes to active months for seasonal scheduling
  void _handleActiveMonthsChanged(Set<Month>? months) {
    setState(() {
      _activeMonths = months;
    });

    widget.onScheduleChanged(_buildSchedule());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode selector: Segmented button
        _buildModeSelector(theme, colorScheme, strings),

        const SizedBox(height: 20),

        // Mode-specific content with smooth transitions
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _mode == _RecurrenceMode.simpleInterval
              ? _buildSimpleIntervalMode(theme, colorScheme, strings)
              : _buildSpecificDaysMode(theme, colorScheme, strings),
        ),

        // Seasonal scheduling section (collapsed by default)
        const SizedBox(height: 8),
        SeasonalSchedulingSection(
          selectedMonths: _activeMonths,
          onChanged: _handleActiveMonthsChanged,
          initiallyExpanded: _activeMonths != null && _activeMonths!.isNotEmpty,
        ),

        // Schedule description preview (always shown)
        const SizedBox(height: 16),
        _buildDescriptionPreview(theme, colorScheme),
      ],
    );
  }

  /// Builds the mode selector segmented button
  Widget _buildModeSelector(ThemeData theme, ColorScheme colorScheme, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            strings.repeatMode,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Segmented button
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<_RecurrenceMode>(
            segments: [
              ButtonSegment(
                value: _RecurrenceMode.simpleInterval,
                label: Text(strings.simpleInterval),
                icon: const Icon(Icons.repeat, size: 18),
              ),
              ButtonSegment(
                value: _RecurrenceMode.specificDays,
                label: Text(strings.specificDays),
                icon: const Icon(Icons.calendar_today, size: 18),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: widget.enabled
                ? (Set<_RecurrenceMode> selection) {
                    _handleModeChanged(selection.first);
                  }
                : null,
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.comfortable,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the UI for simple interval mode
  Widget _buildSimpleIntervalMode(ThemeData theme, ColorScheme colorScheme, AppStrings strings) {
    return Column(
      key: const ValueKey('simple_interval'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Helper text
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strings.simpleIntervalDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Interval selector (delta + unit dropdown)
        RecurrenceIntervalField(
          repeatDelta: _repeatDelta,
          repeatUnit: _repeatUnit,
          onChanged: _handleIntervalChanged,
          enabled: widget.enabled,
        ),
      ],
    );
  }

  /// Builds the UI for specific days mode
  Widget _buildSpecificDaysMode(ThemeData theme, ColorScheme colorScheme, AppStrings strings) {
    return Column(
      key: const ValueKey('specific_days'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Helper text
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strings.specificDaysDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Week interval selector (simplified - just a number input)
        _buildWeekIntervalSelector(theme, colorScheme, strings),

        const SizedBox(height: 16),

        // Weekday selector
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            strings.onDays,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        WeekdaySelector(
          selectedDays: _selectedDays,
          onChanged: _handleDaysChanged,
          enabled: widget.enabled,
          showPresets: false, // Presets are at the top level
        ),
      ],
    );
  }

  /// Builds a simplified week interval selector for specific days mode
  Widget _buildWeekIntervalSelector(ThemeData theme, ColorScheme colorScheme, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            strings.every,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(width: 12),

          // Number input with increment/decrement buttons
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: widget.enabled && _repeatDelta > 1
                      ? () => _handleWeeksChanged(_repeatDelta - 1)
                      : null,
                  tooltip: 'Decrease',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  child: Text(
                    '$_repeatDelta',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: widget.enabled
                      ? () => _handleWeeksChanged(_repeatDelta + 1)
                      : null,
                  tooltip: 'Increase',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
          Text(
            strings.weekUnit(_repeatDelta),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Builds the schedule description preview
  Widget _buildDescriptionPreview(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 18,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildDescription(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
