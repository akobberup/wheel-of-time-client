import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../models/local_time.dart';

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
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepeatUnit>(
                initialValue: _repeatUnit,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                items: RepeatUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _repeatUnit = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _repeatDelta.toString(),
                decoration: const InputDecoration(
                  labelText: 'Every (number)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n < 1) {
                    return 'Please enter a valid number (1 or more)';
                  }
                  return null;
                },
                onChanged: (value) {
                  final n = int.tryParse(value);
                  if (n != null && n > 0) {
                    _repeatDelta = n;
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Alarm Time (optional)'),
                subtitle: Text(_alarmTime != null ? _alarmTime!.toDisplayString() : 'No alarm set'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_alarmTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _alarmTime = null),
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
              TextFormField(
                initialValue: _completionWindowHours?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Completion Window (hours, optional)',
                  border: OutlineInputBorder(),
                  helperText: 'How many hours after alarm to complete',
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Inactive tasks won\'t show up for completion'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
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
