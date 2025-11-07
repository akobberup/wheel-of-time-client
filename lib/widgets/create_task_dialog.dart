import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../services/ai_suggestion_service.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../models/local_time.dart';
import 'ai_suggestions_bottom_sheet.dart';
import 'common/recurrence_field.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  final int taskListId;

  const CreateTaskDialog({super.key, required this.taskListId});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  RepeatUnit _repeatUnit = RepeatUnit.WEEKS;
  int _repeatDelta = 1;
  DateTime _firstRunDate = DateTime.now();
  LocalTime? _alarmTime;
  int? _completionWindowHours;
  bool _isLoading = false;

  // Progressive disclosure: controls whether optional fields are visible
  bool _showOptionalFields = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    setState(() {
      // Fill the name
      _nameController.text = suggestion.name;

      // Parse and set repeat unit
      try {
        _repeatUnit = RepeatUnit.fromJson(suggestion.repeatUnit);
      } catch (e) {
        // If parsing fails, keep default
        _repeatUnit = RepeatUnit.WEEKS;
      }

      // Set repeat delta
      _repeatDelta = suggestion.repeatDelta;
    });
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

    setState(() => _isLoading = true);

    final request = CreateTaskRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      taskListId: widget.taskListId,
      repeatUnit: _repeatUnit,
      repeatDelta: _repeatDelta,
      firstRunDate: _firstRunDate,
      alarmAtTimeOfDay: _alarmTime,
      completionWindowHours: _completionWindowHours,
    );

    final result = await ref.read(tasksProvider(widget.taskListId).notifier).createTask(request);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Create Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === PRIMARY FIELDS (Always Visible) ===

              // Task name field with AI button as suffix icon
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.task_alt),
                  suffixIcon: IconButton(
                    onPressed: _showAiSuggestions,
                    icon: Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'AI Suggestions',
                  ),
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

              // First run date picker
              ListTile(
                title: const Text('First Run Date'),
                subtitle: Text('${_firstRunDate.year}-${_firstRunDate.month.toString().padLeft(2, '0')}-${_firstRunDate.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
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
              : const Text('Create'),
        ),
      ],
    );
  }
}
