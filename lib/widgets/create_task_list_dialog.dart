import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_list_provider.dart';
import '../models/task_list.dart';
import '../l10n/app_strings.dart';
import 'task_list_suggestions_bottom_sheet.dart';

class CreateTaskListDialog extends ConsumerStatefulWidget {
  const CreateTaskListDialog({super.key});

  @override
  ConsumerState<CreateTaskListDialog> createState() => _CreateTaskListDialogState();
}

class _CreateTaskListDialogState extends ConsumerState<CreateTaskListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Shows the AI suggestions bottom sheet
  void _showAiSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskListSuggestionsBottomSheet(
        currentInput: _nameController.text,
        onSuggestionSelected: (suggestion) {
          _nameController.text = suggestion;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = CreateTaskListRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final result = await ref.read(taskListProvider.notifier).createTaskList(request);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create task list')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Create Task List'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task list name field with AI button as suffix icon
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.name,
                  hintText: 'Enter task list name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.list_alt),
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
                    return 'Please enter a name';
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
                maxLines: 3,
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
