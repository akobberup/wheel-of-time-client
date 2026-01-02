// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ai_suggestion_service.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../models/schedule.dart';
import '../models/local_time.dart';
import '../l10n/app_strings.dart';
import 'ai_suggestions_bottom_sheet.dart';
import 'common/recurrence_editor.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  final int taskListId;
  final Color? themeColor;
  final Color? secondaryThemeColor;

  const CreateTaskDialog({
    super.key,
    required this.taskListId,
    this.themeColor,
    this.secondaryThemeColor,
  });

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskSchedule _schedule = const TaskSchedule.interval(
    repeatUnit: RepeatUnit.WEEKS,
    repeatDelta: 1,
    description: 'Weekly',
  );
  DateTime _firstRunDate = DateTime.now();
  LocalTime? _alarmTime;
  int? _completionWindowHours;
  bool _isLoading = false;

  // Progressive disclosure: controls whether optional fields are visible
  bool _showOptionalFields = false;

  // Animation controller for entrance animation
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  /// Setup entrance animation
  void _setupAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Beregner den første gyldige forekomstdato baseret på den aktuelle schedule.
  /// Tager højde for aktive måneder og ugedage (for weekly pattern).
  DateTime _calculateFirstOccurrence(TaskSchedule schedule) {
    DateTime date = DateTime.now();

    // Hent aktive måneder fra schedule
    final activeMonths = schedule.when(
      interval: (_, __, ___, months) => months,
      weeklyPattern: (_, __, ___, months) => months,
    );

    // For weekly pattern, find første gyldige ugedag
    schedule.when(
      interval: (_, __, ___, ____) {
        // Interval schedule - bare find første gyldige måned
      },
      weeklyPattern: (_, daysOfWeek, __, ___) {
        if (daysOfWeek.isNotEmpty) {
          // Find næste dag der matcher en af de valgte ugedage
          for (int i = 0; i < 7; i++) {
            final checkDate = date.add(Duration(days: i));
            // DateTime.weekday: Monday=1, Sunday=7
            // DayOfWeek enum: MONDAY=0, SUNDAY=6
            final dayOfWeek = DayOfWeek.values[checkDate.weekday - 1];
            if (daysOfWeek.contains(dayOfWeek)) {
              date = checkDate;
              break;
            }
          }
        }
      },
    );

    // Hvis der er aktive måneder, find første dato i en aktiv måned
    if (activeMonths != null && activeMonths.isNotEmpty) {
      // Tjek op til 12 måneder frem
      for (int i = 0; i < 12; i++) {
        final checkMonth = Month.values[date.month - 1];
        if (activeMonths.contains(checkMonth)) {
          break; // Datoen er allerede i en aktiv måned
        }
        // Gå til første dag i næste måned
        date = DateTime(date.year, date.month + 1, 1);
      }

      // For weekly pattern, juster til den korrekte ugedag i den nye måned
      schedule.when(
        interval: (_, __, ___, ____) {},
        weeklyPattern: (_, daysOfWeek, __, ___) {
          if (daysOfWeek.isNotEmpty) {
            // Find næste gyldige ugedag fra den nye dato
            for (int i = 0; i < 7; i++) {
              final checkDate = date.add(Duration(days: i));
              final dayOfWeek = DayOfWeek.values[checkDate.weekday - 1];
              if (daysOfWeek.contains(dayOfWeek)) {
                // Tjek at datoen stadig er i en aktiv måned
                final checkMonth = Month.values[checkDate.month - 1];
                if (activeMonths.contains(checkMonth)) {
                  date = checkDate;
                  break;
                }
              }
            }
          }
        },
      );
    }

    return date;
  }

  /// Opdaterer schedule og genberegner første forekomst.
  /// Bruger addPostFrameCallback for at undgå setState() under build.
  void _updateSchedule(TaskSchedule newSchedule) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _schedule = newSchedule;
          _firstRunDate = _calculateFirstOccurrence(newSchedule);
        });
      }
    });
  }

  /// Checks if any optional fields have been filled by the user.
  /// Used to show a visual indicator on the expansion toggle.
  bool get _hasOptionalFieldsData {
    return _descriptionController.text.trim().isNotEmpty ||
        _alarmTime != null ||
        _completionWindowHours != null;
  }

  /// Auto-fills form fields from a task suggestion.
  /// Includes subtle animation to highlight the auto-filled fields.
  void _autoFillFromSuggestion(TaskSuggestion suggestion) {
    // Fill the name
    _nameController.text = suggestion.name;

    // Parse repeat unit and create schedule
    TaskSchedule newSchedule;
    try {
      final repeatUnit = RepeatUnit.fromJson(suggestion.repeatUnit);
      newSchedule = TaskSchedule.interval(
        repeatUnit: repeatUnit,
        repeatDelta: suggestion.repeatDelta,
        description: _buildIntervalDescription(repeatUnit, suggestion.repeatDelta),
      );
    } catch (e) {
      // If parsing fails, keep default
      newSchedule = const TaskSchedule.interval(
        repeatUnit: RepeatUnit.WEEKS,
        repeatDelta: 1,
        description: 'Weekly',
      );
    }

    // Opdater schedule og genberegn første forekomst
    _updateSchedule(newSchedule);
  }

  /// Builds a simple description for interval schedules
  String _buildIntervalDescription(RepeatUnit unit, int delta) {
    if (delta == 1) {
      switch (unit) {
        case RepeatUnit.DAYS:
          return 'Daily';
        case RepeatUnit.WEEKS:
          return 'Weekly';
        case RepeatUnit.MONTHS:
          return 'Monthly';
        case RepeatUnit.YEARS:
          return 'Yearly';
      }
    }

    final unitName = unit.toString().split('.').last.toLowerCase();
    return 'Every $delta $unitName';
  }

  /// Shows the AI suggestions bottom sheet
  void _showAiSuggestions() {
    final suggestionCache = ref.read(suggestionCacheProvider.notifier);
    final cachedSuggestions = suggestionCache.getCachedSuggestions(widget.taskListId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiSuggestionsBottomSheet(
        taskListId: widget.taskListId,
        currentInput: _nameController.text,
        initialSuggestions: cachedSuggestions,
        onSuggestionSelected: (suggestion) {
          _autoFillFromSuggestion(suggestion);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final request = CreateTaskRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      taskListId: widget.taskListId,
      schedule: _schedule,
      firstRunDate: _firstRunDate,
      alarmAtTimeOfDay: _alarmTime,
      completionWindowHours: _completionWindowHours,
    );

    setState(() => _isLoading = true);

    try {
      await ref.read(tasksProvider(widget.taskListId).notifier).createTask(request);
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.vibrate();
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.translateApiException(e))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.vibrate();
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.failedToCreateTask)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeState = ref.watch(themeProvider);
    
    // Brug tema farver fra opgavelisten eller fallback til global tema
    final primaryColor = widget.themeColor ?? themeState.seedColor;
    final secondaryColor = widget.secondaryThemeColor ?? primaryColor;

    // Lys baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.85) ??
        primaryColor.withValues(alpha: 0.15);
    final borderColor = Color.lerp(primaryColor, Colors.black, 0.1) ??
        primaryColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        backgroundColor: backgroundColor,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Themed header with icon
            _buildThemedHeader(strings, primaryColor, secondaryColor, isDark),
            
            // Content area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildForm(strings, theme, primaryColor, isDark),
              ),
            ),
            
            // Action buttons
            _buildActionButtons(strings, primaryColor, isDark),
          ],
        ),
        ),
      ),
    );
  }

  /// Bygger themed header med gradient og ikon
  Widget _buildThemedHeader(
    AppStrings strings,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: Column(
        children: [
          // Cirkulær ikon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.createTask.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.taskDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Bygger form indhold
  Widget _buildForm(
    AppStrings strings,
    ThemeData theme,
    Color primaryColor,
    bool isDark,
  ) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 500, // Fixed width to prevent shrinking when content expands
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === PRIMARY FIELDS (Always Visible) ===

            // Task name field with AI button as suffix icon
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: strings.taskName,
                hintText: strings.enterTaskName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.task_alt),
                suffixIcon: IconButton(
                  onPressed: _showAiSuggestions,
                  icon: Icon(
                    Icons.auto_awesome,
                    color: primaryColor,
                  ),
                  tooltip: strings.aiSuggestions,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return strings.pleaseEnterTaskName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Comprehensive recurrence editor with interval and weekly pattern support
            RecurrenceEditor(
              initialSchedule: _schedule,
              onScheduleChanged: _updateSchedule,
            ),
            const SizedBox(height: 16),

            // First run date picker
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.12),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(strings.firstRunDate),
                subtitle: Text(
                  '${_firstRunDate.year}-${_firstRunDate.month.toString().padLeft(2, '0')}-${_firstRunDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(Icons.calendar_today, color: primaryColor),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _firstRunDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _firstRunDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),

            // === PROGRESSIVE DISCLOSURE SECTION ===

            // Divider to separate primary from optional fields
            const Divider(),

            // Expansion toggle button with Material 3 styling
            InkWell(
              onTap: () {
                setState(() {
                  _showOptionalFields = !_showOptionalFields;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _showOptionalFields ? Icons.expand_less : Icons.expand_more,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _showOptionalFields ? strings.hideOptionalDetails : strings.showOptionalDetails,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Visual indicator if optional fields have data
                    if (_hasOptionalFieldsData && !_showOptionalFields) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // === OPTIONAL FIELDS (Hidden by Default) ===

            // AnimatedCrossFade provides smooth expansion/collapse animation
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: strings.description,
                      hintText: strings.addTaskDetails,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Alarm time picker
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.12),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(strings.alarmTime),
                      subtitle: Text(
                        _alarmTime != null ? _alarmTime!.toDisplayString() : strings.noAlarm,
                        style: _alarmTime != null
                            ? TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              )
                            : null,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_alarmTime != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _alarmTime = null),
                              tooltip: strings.clearAlarm,
                            ),
                          Icon(Icons.alarm, color: primaryColor),
                        ],
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: _alarmTime?.hour ?? 9,
                            minute: _alarmTime?.minute ?? 0,
                          ),
                        );
                        if (time != null) {
                          setState(() => _alarmTime = LocalTime.fromTimeOfDay(time.hour, time.minute));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Completion window field
                  TextFormField(
                    initialValue: _completionWindowHours?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: strings.completionWindowHours,
                      hintText: strings.completionWindowHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.hourglass_empty),
                      helperText: strings.hoursAfterAlarm,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final n = int.tryParse(value);
                        if (n == null || n < 1) {
                          return strings.pleaseEnterValidNumber;
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _completionWindowHours = null;
                      } else {
                        final n = int.tryParse(value);
                        if (n != null && n > 0) {
                          _completionWindowHours = n;
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              crossFadeState: _showOptionalFields
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  /// Bygger action buttons med tema-farvet gradient knap
  Widget _buildActionButtons(AppStrings strings, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel button
          Flexible(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
          ),
          const SizedBox(width: 12),

          // Create button med gradient
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor,
                    Color.lerp(primaryColor, Colors.black, 0.15) ?? primaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(strings.create),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
