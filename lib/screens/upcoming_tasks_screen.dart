import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/task_instance_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../widgets/complete_task_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/task_completion_animation.dart';

/// Screen displaying upcoming task occurrences with infinite scroll pagination
class UpcomingTasksScreen extends ConsumerStatefulWidget {
  const UpcomingTasksScreen({super.key});

  @override
  ConsumerState<UpcomingTasksScreen> createState() => _UpcomingTasksScreenState();
}

class _UpcomingTasksScreenState extends ConsumerState<UpcomingTasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detects when user scrolls near the bottom and loads more data
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(upcomingTasksProvider.notifier).loadMore();
    }
  }

  /// Formats the due date of a task into a human-readable string
  String _formatDueDate(BuildContext context, DateTime dueDate) {
    final strings = AppStrings.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      final daysAgo = difference.abs();
      return daysAgo == 1 ? strings.dueDaysAgo(1) : strings.dueDaysAgo(daysAgo);
    } else if (difference == 0) {
      return strings.dueToday;
    } else if (difference == 1) {
      return strings.dueTomorrow;
    } else {
      return strings.dueInDays(difference);
    }
  }

  /// Returns the color for the due date badge based on urgency
  Color _getDueDateColor(BuildContext context, DateTime dueDate) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      return colorScheme.error;
    } else if (difference == 0) {
      return colorScheme.tertiary;
    } else if (difference == 1) {
      return colorScheme.primary;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }

  /// Quick complete with current timestamp (for swipe action)
  Future<void> _quickComplete(UpcomingTaskOccurrenceResponse occurrence) async {
    final request = CreateTaskInstanceRequest(
      taskId: occurrence.taskId,
      completedDateTime: DateTime.now(),
      optionalComment: null,
    );

    final result = await ref
        .read(taskInstancesProvider(occurrence.taskId).notifier)
        .createTaskInstance(request);

    if (result != null && mounted) {
      // Calculate new streak count (current + 1 if contributed to streak)
      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      // Show success animation
      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
      );

      // Refresh the list after animation completes
      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }

  /// Handles task completion and shows appropriate success message
  Future<void> _handleTaskCompletion(
    BuildContext context,
    UpcomingTaskOccurrenceResponse occurrence,
  ) async {
    HapticFeedback.mediumImpact();
    final dialogResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CompleteTaskDialog(
        taskId: occurrence.taskId,
        taskName: occurrence.taskName,
        currentStreak: occurrence.currentStreak,
      ),
    );

    if (dialogResult != null && context.mounted) {
      final result = dialogResult['result'] as TaskInstanceResponse;
      final completionMessage = dialogResult['message'] as String?;

      // Calculate new streak count (current + 1 if contributed to streak)
      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      // Show success animation with completion message
      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
        completionMessage: completionMessage,
      );

      // Refresh the list after animation completes
      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingTasksProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(upcomingTasksProvider.notifier).refresh(),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UpcomingTasksState state) {
    final strings = AppStrings.of(context);

    // Initial loading
    if (state.isLoading && state.occurrences.isEmpty) {
      return const SkeletonListLoader();
    }

    // Error state
    if (state.error != null && state.occurrences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              '${strings.error}: ${state.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(upcomingTasksProvider.notifier).refresh();
              },
              child: Text(strings.retry),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.occurrences.isEmpty) {
      return EmptyState(
        title: strings.noUpcomingTasks,
        subtitle: strings.allCaughtUpWithTasks,
      );
    }

    // List with data
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.occurrences.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == state.occurrences.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: state.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }

        final occurrence = state.occurrences[index];
        final dueDateColor = _getDueDateColor(context, occurrence.dueDate);
        final dueDateText = _formatDueDate(context, occurrence.dueDate);
        final isOverdue = occurrence.dueDate.isBefore(DateTime.now());
        final isClickable = occurrence.isNextOccurrence;

        return Dismissible(
          key: Key(occurrence.occurrenceId),
          direction: isClickable ? DismissDirection.endToStart : DismissDirection.none,
          confirmDismiss: (direction) async {
            if (!isClickable) return false;

            await _quickComplete(occurrence);
            return false; // Don't actually dismiss, just trigger action
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          child: Stack(
          children: [
            Opacity(
              opacity: isClickable ? 1.0 : 0.6,
              child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            color: isOverdue
                ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.05)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isOverdue
                    ? Theme.of(context).colorScheme.error.withOpacity(0.6)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isClickable ? () => _handleTaskCompletion(context, occurrence) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name and due date badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          occurrence.taskName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: dueDateColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dueDateColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          dueDateText,
                          style: TextStyle(
                            color: dueDateColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // List name
                  Row(
                    children: [
                      Icon(
                        Icons.list,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        occurrence.taskListName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Metadata row: completions and repeat pattern
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (occurrence.totalCompletions > 0) ...[
                        Icon(Icons.check_circle_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${occurrence.totalCompletions}x completed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.repeat, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        occurrence.schedule.description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Description if available
                  if (occurrence.description != null && occurrence.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      occurrence.description!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Alarm time if set
                  if (occurrence.alarmAtTimeOfDay != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          occurrence.alarmAtTimeOfDay!.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Streak warning if at risk (within 6 hours of due time)
                  if (isClickable &&
                      occurrence.currentStreak != null &&
                      occurrence.currentStreak!.isActive &&
                      _isStreakAtRisk(occurrence.dueDate)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.streakAtRisk(occurrence.currentStreak!.streakCount),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Streak info if available (only show for next occurrence)
                  if (isClickable && occurrence.currentStreak != null && occurrence.currentStreak!.isActive) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${occurrence.currentStreak!.streakCount}x ${strings.dayStreak(occurrence.currentStreak!.streakCount)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
              ),
            ),
            if (!isClickable)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Chip(
                      label: Text(strings.completeEarlierTasksFirst),
                      avatar: const Icon(Icons.lock_outline, size: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
        );
      },
    );
  }

  /// Checks if a streak is at risk based on the due date
  /// Returns true if the task is due within 6 hours
  bool _isStreakAtRisk(DateTime dueDate) {
    final now = DateTime.now();
    final hoursUntilDue = dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}
