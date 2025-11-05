import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_instance_provider.dart';
import '../models/task_instance.dart';

class CompleteTaskDialog extends ConsumerStatefulWidget {
  final int taskId;
  final String taskName;

  const CompleteTaskDialog({
    super.key,
    required this.taskId,
    required this.taskName,
  });

  @override
  ConsumerState<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends ConsumerState<CompleteTaskDialog> {
  final _commentController = TextEditingController();
  DateTime _completedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final request = CreateTaskInstanceRequest(
      taskId: widget.taskId,
      completedDateTime: _completedDateTime,
      optionalComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    final result = await ref.read(taskInstancesProvider(widget.taskId).notifier).createTaskInstance(request);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.of(context).pop(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete: ${widget.taskName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Completion Time'),
            subtitle: Text(
              '${DateFormat.yMMMd().format(_completedDateTime)} at ${DateFormat.jm().format(_completedDateTime)}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _completedDateTime,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_completedDateTime),
                );
                if (time != null) {
                  setState(() {
                    _completedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
              : const Text('Complete'),
        ),
      ],
    );
  }
}
