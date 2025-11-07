import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../models/local_time.dart';
import 'common/recurrence_field.dart';

/// Dialog for editing an existing task.
/// Allows users to update task name, description, repeat settings, alarm time,
/// completion window, and active status.
class EditTaskDialog extends ConsumerStatefulWidget {
  final TaskResponse task;

  const EditTaskDialog({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late RepeatUnit _repeatUnit;
  late int _repeatDelta;
  late bool _isActive;
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
    _repeatUnit = widget.task.repeatUnit;
    _repeatDelta = widget.task.repeatDelta;
    _isActive = widget.task.isActive;
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
      repeatUnit: _repeatUnit,
      repeatDelta: _repeatDelta,
      isActive: _isActive,
      alarmAtTimeOfDay: _alarmTime,
      completionWindowHours: _completionWindowHours,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === PRIMARY FIELDS (Always Visible) ===

              // Task name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Combined recurrence field with numerical delta and unit selector
              RecurrenceField(
                initialDelta: _repeatDelta,
                initialUnit: _repeatUnit,
                onDeltaChanged: (delta) {
                  setState(() => _repeatDelta = delta);
                },
                onUnitChanged: (unit) {
                  setState(() => _repeatUnit = unit);
                },
              ),
              const SizedBox(height: 16),

              // Active status toggle - important for task management
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Inactive tasks won\'t show up for completion'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
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
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _showOptionalFields ? 'Hide optional details' : 'Show optional details',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.primary,
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
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Subtle hint about what's inside
                      if (!_showOptionalFields)
                        Text(
                          'Description, Alarm, Window',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add task details',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    // Alarm time picker
                    ListTile(
                      title: const Text('Alarm Time'),
                      subtitle: Text(_alarmTime != null ? _alarmTime!.toDisplayString() : 'No alarm set'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_alarmTime != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _alarmTime = null),
                              tooltip: 'Clear alarm',
                            ),
                          const Icon(Icons.alarm),
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
                    const SizedBox(height: 16),

                    // Completion window field
                    TextFormField(
                      initialValue: _completionWindowHours?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Completion Window (hours)',
                        hintText: 'e.g., 24',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.hourglass_empty),
                        helperText: 'Hours after alarm to complete',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final n = int.tryParse(value);
                          if (n == null || n < 1) {
                            return 'Please enter a valid number (1 or more)';
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
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
