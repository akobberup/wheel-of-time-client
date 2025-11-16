import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_instance_provider.dart';
import '../providers/auth_provider.dart';
import '../models/task_instance.dart';
import '../models/streak.dart';

/// A celebratory dialog for completing tasks with animations and encouraging messages.
///
/// This dialog provides a delightful experience when users complete tasks,
/// featuring entrance animations, haptic feedback, streak encouragement,
/// and progressive disclosure for optional features.
class CompleteTaskDialog extends ConsumerStatefulWidget {
  final int taskId;
  final String taskName;
  final StreakResponse? currentStreak;

  const CompleteTaskDialog({
    super.key,
    required this.taskId,
    required this.taskName,
    this.currentStreak,
  });

  @override
  ConsumerState<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends ConsumerState<CompleteTaskDialog>
    with SingleTickerProviderStateMixin {
  // Constants for consistent spacing and sizing
  static const double _verticalSpacing = 16.0;
  static const double _headerPadding = 24.0;
  static const double _contentPadding = 20.0;
  static const double _borderRadius = 28.0;
  static const double _iconSize = 48.0;
  static const double _buttonIconSize = 20.0;

  // Controllers and state
  final _commentController = TextEditingController();
  DateTime _completedDateTime = DateTime.now();
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _showCommentField = false;
  bool _isTimeSelected = false;
  String? _completionMessage;

  // Animation controller for entrance animation
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupEntranceAnimation();
    _fetchCompletionMessage();
  }

  /// Sets up the bouncy entrance animation for the dialog.
  void _setupEntranceAnimation() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack, // Bouncy entrance effect
    );
    _scaleController.forward();
  }

  /// Fetches the completion message from the API in the background.
  ///
  /// This is called when the dialog opens and runs asynchronously
  /// so the message is ready when the user clicks "Complete".
  Future<void> _fetchCompletionMessage() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final message = await apiService.getTaskCompletionMessage(widget.taskId);

      if (mounted) {
        setState(() {
          _completionMessage = message;
        });
      }
    } catch (e) {
      // Silently fail - completion message is optional
      // The animation will just show without a message if the API call fails
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Opens time/date pickers and updates the completion timestamp.
  ///
  /// Shows date picker first, then time picker. If user cancels either,
  /// the completion time remains unchanged. Provides haptic feedback on interaction.
  Future<void> _selectCompletionTime() async {
    HapticFeedback.selectionClick();

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
          _isTimeSelected = true;
        });
        HapticFeedback.selectionClick();
      }
    }
  }

  /// Submits the task completion with success state animation.
  ///
  /// Shows loading state, creates task instance, displays brief success state
  /// with haptic feedback, then dismisses the dialog.
  Future<void> _submit() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    final request = CreateTaskInstanceRequest(
      taskId: widget.taskId,
      completedDateTime: _completedDateTime,
      optionalComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    final result = await ref
        .read(taskInstancesProvider(widget.taskId).notifier)
        .createTaskInstance(request);

    if (mounted) {
      if (result != null) {
        // Show success state briefly
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });

        HapticFeedback.heavyImpact();

        // Wait a moment to show the success state
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Return both the result and the completion message
          Navigator.of(context).pop({
            'result': result,
            'message': _completionMessage,
          });
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory header with gradient
            _buildCelebratoryHeader(colorScheme, textTheme),

            // Main content area
            Padding(
              padding: const EdgeInsets.all(_contentPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streak encouragement message (if applicable)
                  if (_shouldShowStreakEncouragement())
                    _buildStreakEncouragement(colorScheme),

                  const SizedBox(height: _verticalSpacing),

                  // Time selection with micro-interaction
                  _buildTimeSelector(colorScheme),

                  const SizedBox(height: _verticalSpacing),

                  // Progressive disclosure: comment field or "add note" button
                  _showCommentField
                      ? _buildCommentField()
                      : _buildAddNoteButton(),

                  const SizedBox(height: _verticalSpacing * 1.5),

                  // Action buttons
                  _buildActionButtons(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the celebratory header with a clean background and icon.
  Widget _buildCelebratoryHeader(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(_headerPadding),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: _iconSize,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            widget.taskName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Determines if we should show streak encouragement message.
  bool _shouldShowStreakEncouragement() {
    return widget.currentStreak != null &&
        widget.currentStreak!.isActive &&
        widget.currentStreak!.streakCount > 0;
  }

  /// Builds the streak encouragement message container.
  Widget _buildStreakEncouragement(ColorScheme colorScheme) {
    final streakCount = widget.currentStreak!.streakCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Keep your $streakCount-day streak going!',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the time selector with animated highlight on selection.
  Widget _buildTimeSelector(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isTimeSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isTimeSelected
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          'When did you complete this?',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${DateFormat.yMMMd().format(_completedDateTime)} at ${DateFormat.jm().format(_completedDateTime)}',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: Icon(
          Icons.access_time,
          color: colorScheme.primary,
        ),
        onTap: _selectCompletionTime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// Builds the comment text field.
  Widget _buildCommentField() {
    return TextFormField(
      controller: _commentController,
      decoration: const InputDecoration(
        labelText: 'How did it go?',
        hintText: 'Add a note about this completion...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Builds the "Add a note" button for progressive disclosure.
  Widget _buildAddNoteButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() => _showCommentField = true);
        },
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Add a note'),
      ),
    );
  }

  /// Builds the action buttons with success state handling.
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button
        OutlinedButton(
          onPressed: _isLoading || _isSuccess
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),

        // Complete button with success state
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilledButton.icon(
            onPressed: _isLoading || _isSuccess ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _isSuccess
                  ? Colors.green.shade700
                  : Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: _buildButtonIcon(),
            label: Text(_getButtonLabel()),
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate icon for the complete button based on state.
  Widget _buildButtonIcon() {
    if (_isSuccess) {
      return const Icon(Icons.check_circle, size: _buttonIconSize);
    } else if (_isLoading) {
      return const SizedBox(
        width: _buttonIconSize,
        height: _buttonIconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return const Icon(Icons.check_circle_outline, size: _buttonIconSize);
    }
  }

  /// Returns the appropriate label for the complete button based on state.
  String _getButtonLabel() {
    if (_isSuccess) {
      return 'Done!';
    } else if (_isLoading) {
      return 'Completing...';
    } else {
      return 'Complete Task!';
    }
  }
}
