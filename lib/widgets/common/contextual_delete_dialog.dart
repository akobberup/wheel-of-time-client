import 'package:flutter/material.dart';

/// Data returned from async context fetcher to build contextual warning messages.
/// Contains counts and other relevant information about what will be deleted.
class DeletionContext {
  /// The primary count of items (e.g., tasks in a list, completions for a task)
  final int primaryCount;

  /// Optional secondary count (e.g., completion records)
  final int? secondaryCount;

  /// Optional tertiary count (e.g., active streaks)
  final int? tertiaryCount;

  /// Whether the item has an active streak that will be lost
  final bool hasActiveStreak;

  /// The streak count if applicable
  final int? streakCount;

  /// Whether the deletion is considered "safe" (empty or minimal impact)
  final bool isSafe;

  const DeletionContext({
    required this.primaryCount,
    this.secondaryCount,
    this.tertiaryCount,
    this.hasActiveStreak = false,
    this.streakCount,
    this.isSafe = false,
  });

  /// Creates a safe deletion context (e.g., empty task list)
  const DeletionContext.safe()
      : primaryCount = 0,
        secondaryCount = null,
        tertiaryCount = null,
        hasActiveStreak = false,
        streakCount = null,
        isSafe = true;
}

/// Builder function that creates the warning message based on the deletion context.
/// Takes the fetched context and returns a human-readable warning message.
typedef ContextualMessageBuilder = String Function(DeletionContext context);

/// Shows a confirmation dialog with contextual warnings based on actual data.
///
/// This dialog fetches relevant context data asynchronously before displaying,
/// allowing it to show specific counts and consequences rather than generic warnings.
///
/// Example usage:
/// ```dart
/// final confirmed = await showContextualDeleteDialog(
///   context: context,
///   title: 'Delete Task List?',
///   itemName: 'Morning Routine',
///   fetchContext: () async {
///     final tasks = await apiService.getTasks(taskListId);
///     final instances = await apiService.getInstances(taskListId);
///     return DeletionContext(
///       primaryCount: tasks.length,
///       secondaryCount: instances.length,
///       isSafe: tasks.isEmpty,
///     );
///   },
///   buildMessage: (context) {
///     if (context.isSafe) {
///       return 'This list is empty and can be safely deleted.';
///     }
///     return 'This will permanently delete ${context.primaryCount} tasks '
///         'and ${context.secondaryCount} completion records.';
///   },
/// );
/// ```
Future<bool> showContextualDeleteDialog({
  required BuildContext context,
  required String title,
  required String itemName,
  required Future<DeletionContext> Function() fetchContext,
  required ContextualMessageBuilder buildMessage,
  String? deleteButtonLabel,
  String? cancelButtonLabel,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ContextualDeleteDialog(
          title: title,
          itemName: itemName,
          fetchContext: fetchContext,
          buildMessage: buildMessage,
          deleteButtonLabel: deleteButtonLabel,
          cancelButtonLabel: cancelButtonLabel,
        ),
      ) ??
      false;
}

/// Internal stateful widget that handles the async data fetching and display.
class _ContextualDeleteDialog extends StatefulWidget {
  final String title;
  final String itemName;
  final Future<DeletionContext> Function() fetchContext;
  final ContextualMessageBuilder buildMessage;
  final String? deleteButtonLabel;
  final String? cancelButtonLabel;

  const _ContextualDeleteDialog({
    required this.title,
    required this.itemName,
    required this.fetchContext,
    required this.buildMessage,
    this.deleteButtonLabel,
    this.cancelButtonLabel,
  });

  @override
  State<_ContextualDeleteDialog> createState() =>
      _ContextualDeleteDialogState();
}

class _ContextualDeleteDialogState extends State<_ContextualDeleteDialog> {
  late Future<DeletionContext> _contextFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching context data immediately when dialog opens
    _contextFuture = widget.fetchContext();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.title),
          ),
        ],
      ),
      content: FutureBuilder<DeletionContext>(
        future: _contextFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error);
          }

          if (snapshot.hasData) {
            return _buildContentState(context, snapshot.data!);
          }

          return const SizedBox.shrink();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            widget.cancelButtonLabel ?? 'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        FutureBuilder<DeletionContext>(
          future: _contextFuture,
          builder: (context, snapshot) {
            // Disable delete button while loading
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                widget.deleteButtonLabel ?? 'Delete',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
      ],
    ),
    );
  }

  /// Builds the loading state while fetching deletion context
  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text(
          'Checking what will be deleted...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Builds the error state if context fetching fails
  Widget _buildErrorState(BuildContext context, Object? error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unable to load deletion details',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Delete "${widget.itemName}"?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'This action cannot be undone. Proceed with caution.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Builds the content state with the fetched deletion context
  Widget _buildContentState(BuildContext context, DeletionContext deletionContext) {
    final message = widget.buildMessage(deletionContext);
    final isSafe = deletionContext.isSafe;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item name with special styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSafe
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSafe
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSafe ? Icons.info_outline : Icons.warning_amber_rounded,
                color: isSafe
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.itemName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSafe
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.error,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Contextual warning message
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
        ),
        if (!isSafe) ...[
          const SizedBox(height: 12),
          // Warning about permanence
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.block,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action cannot be undone',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
