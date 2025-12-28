// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_list_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../models/task_list.dart';
import '../models/visual_theme.dart';
import '../l10n/app_strings.dart';
import 'theme_selector.dart';

/// Dialog for editing an existing task list.
/// Allows users to update the name and description of a task list.
class EditTaskListDialog extends ConsumerStatefulWidget {
  final TaskListResponse taskList;

  const EditTaskListDialog({
    super.key,
    required this.taskList,
  });

  @override
  ConsumerState<EditTaskListDialog> createState() => _EditTaskListDialogState();
}

class _EditTaskListDialogState extends ConsumerState<EditTaskListDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  List<VisualThemeResponse>? _availableThemes;
  VisualThemeResponse? _selectedTheme;
  bool _isLoadingThemes = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing task list data
    _nameController = TextEditingController(text: widget.taskList.name);
    _descriptionController = TextEditingController(
      text: widget.taskList.description ?? '',
    );
    _selectedTheme = widget.taskList.visualTheme;
    _loadAvailableThemes();
  }

  /// Indlæser alle tilgængelige temaer fra serveren
  Future<void> _loadAvailableThemes() async {
    setState(() => _isLoadingThemes = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final themes = await apiService.getAllVisualThemes();
      if (mounted) {
        setState(() {
          _availableThemes = themes;
          _isLoadingThemes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingThemes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).failedToLoadThemes)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validates and submits the form to update the task list.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = UpdateTaskListRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      visualThemeId: _selectedTheme?.id,
    );

    final result = await ref.read(taskListProvider.notifier).updateTaskList(
          widget.taskList.id,
          request,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).failedToUpdateTaskList)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return AlertDialog(
      title: Text(strings.editTaskList),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navn felt
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Beskrivelse felt
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: strings.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Tema vælger
              Text(
                strings.visualTheme,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoadingThemes)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableThemes != null)
                CompactThemeSelector(
                  currentTheme: _selectedTheme,
                  availableThemes: _availableThemes!,
                  onThemeSelected: (theme) {
                    setState(() => _selectedTheme = theme);
                  },
                  isDarkMode: isDark,
                )
              else
                Text(
                  strings.failedToLoadThemes,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF6B6B6B),
                  ),
                ),
            ],
          ),
        ),
      )),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.save),
        ),
      ],
    );
  }
}
