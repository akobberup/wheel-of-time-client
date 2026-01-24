// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/schedule.dart';
import '../models/local_time.dart';
import '../l10n/app_strings.dart';
import 'common/recurrence_editor.dart';

/// Dialog for editing an existing task.
/// Allows users to update task name, description, repeat settings, alarm time,
/// completion window, and active status.
/// Supports optional theme colors from the task list for visual consistency.
class EditTaskDialog extends ConsumerStatefulWidget {
  final TaskResponse task;

  /// Optional primary theme color from task list
  final Color? themeColor;

  /// Optional secondary theme color from task list
  final Color? secondaryThemeColor;

  const EditTaskDialog({
    super.key,
    required this.task,
    this.themeColor,
    this.secondaryThemeColor,
  });

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late TaskSchedule _schedule;
  late bool _isActive;
  late bool _scheduleFromCompletion;
  LocalTime? _alarmTime;
  int? _completionWindowHours;
  bool _isLoading = false;

  // Progressive disclosure: controls whether optional fields are visible
  bool _showOptionalFields = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task data
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _schedule = widget.task.schedule;
    _isActive = widget.task.isActive;
    _scheduleFromCompletion = widget.task.scheduleFromCompletion;
    _alarmTime = widget.task.alarmAtTimeOfDay;
    _completionWindowHours = widget.task.completionWindowHours;

    // Auto-expand optional fields if they already have data
    _showOptionalFields = _descriptionController.text.isNotEmpty ||
        _alarmTime != null ||
        _completionWindowHours != null;
  }

  /// Checks if any optional fields have been filled by the user.
  /// Used to show a visual indicator on the expansion toggle.
  bool get _hasOptionalFieldsData {
    return _descriptionController.text.trim().isNotEmpty ||
        _alarmTime != null ||
        _completionWindowHours != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validates and submits the form to update the task.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = UpdateTaskRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      schedule: _schedule,
      isActive: _isActive,
      alarmAtTimeOfDay: _alarmTime,
      completionWindowHours: _completionWindowHours,
      scheduleFromCompletion: _scheduleFromCompletion,
    );

    final result = await ref.read(tasksProvider(widget.task.taskListId).notifier).updateTask(
          widget.task.id,
          request,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.of(context).pop(true);
      } else {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.failedToUpdateTask)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Brug task list tema farver hvis tilgængelige
    final primaryColor = widget.themeColor ?? colorScheme.primary;
    final secondaryColor = widget.secondaryThemeColor ?? primaryColor;

    return AlertDialog(
      title: Text(strings.editTask),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // === PRIMARY FIELDS (Always Visible) ===

              // Task name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.taskName,
                  hintText: strings.enterTaskName,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt, color: primaryColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  floatingLabelStyle: TextStyle(color: primaryColor),
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
                onScheduleChanged: (schedule) {
                  setState(() => _schedule = schedule);
                },
                themeColor: primaryColor,
              ),
              const SizedBox(height: 8),

              // Schedule from completion toggle
              SwitchListTile(
                title: Text(strings.scheduleFromCompletionLabel),
                subtitle: Text(
                  strings.scheduleFromCompletionDescription,
                  style: const TextStyle(fontSize: 12),
                ),
                value: _scheduleFromCompletion,
                activeTrackColor: primaryColor.withValues(alpha: 0.5),
                activeThumbColor: primaryColor,
                onChanged: (value) => setState(() => _scheduleFromCompletion = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Active status toggle - themed
              SwitchListTile(
                title: Text(strings.active),
                subtitle: Text(strings.inactiveTasksWontShow),
                value: _isActive,
                activeColor: primaryColor,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
              const SizedBox(height: 8),

              // === PROGRESSIVE DISCLOSURE SECTION ===

              // Divider to separate primary from optional fields
              const Divider(),

              // Expansion toggle button with theme color
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
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes, color: primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        floatingLabelStyle: TextStyle(color: primaryColor),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    // Alarm time picker
                    ListTile(
                      title: Text(strings.alarmTime),
                      subtitle: Text(_alarmTime != null ? _alarmTime!.toDisplayString() : strings.noAlarm),
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
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: colorScheme.copyWith(
                                  primary: primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() => _alarmTime = LocalTime.fromTimeOfDay(time.hour, time.minute));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Completion window field
                    TextFormField(
                      initialValue: _completionWindowHours?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: strings.completionWindowHours,
                        hintText: strings.completionWindowHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.hourglass_empty, color: primaryColor),
                        helperText: strings.hoursAfterAlarm,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        floatingLabelStyle: TextStyle(color: primaryColor),
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
      ), // Closes SingleChildScrollView
      ), // Closes ConstrainedBox (content parameter)
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
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
              : Text(strings.save),
        ),
      ],
    );
  }
}
