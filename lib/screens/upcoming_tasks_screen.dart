import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../widgets/complete_task_dialog.dart';
import '../l10n/app_strings.dart';

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
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      return Colors.red;
    } else if (difference == 0) {
      return Colors.orange;
    } else if (difference == 1) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  /// Handles task completion and shows appropriate success message
  Future<void> _handleTaskCompletion(
    BuildContext context,
    UpcomingTaskOccurrenceResponse occurrence,
  ) async {
    final result = await showDialog<TaskInstanceResponse>(
      context: context,
      builder: (context) => CompleteTaskDialog(taskId: occurrence.taskId),
    );

    if (result != null && context.mounted) {
      final strings = AppStrings.of(context);

      // Refresh the list
      ref.read(upcomingTasksProvider.notifier).refresh();

      // Show success message with streak info if applicable
      String message = strings.taskCompletedSuccess;
      if (result.contributedToStreak) {
        message = strings.streakContinued;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = ref.watch(upcomingTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.upcomingTasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refresh,
            onPressed: () {
              ref.read(upcomingTasksProvider.notifier).refresh();
            },
          ),
        ],
      ),
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
      return const Center(child: CircularProgressIndicator());
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noUpcomingTasks,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                strings.allCaughtUpWithTasks,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ),
          ],
        ),
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
        final dueDateColor = _getDueDateColor(occurrence.dueDate);
        final dueDateText = _formatDueDate(context, occurrence.dueDate);
        final isOverdue = occurrence.dueDate.isBefore(DateTime.now());
        final isClickable = occurrence.isNextOccurrence;

        return Opacity(
          opacity: isClickable ? 1.0 : 0.5,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isOverdue ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
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
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        occurrence.taskListName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                        color: Colors.grey[700],
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          occurrence.alarmAtTimeOfDay!.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Streak info if available (only show for next occurrence)
                  if (isClickable && occurrence.currentStreak != null && occurrence.currentStreak!.isActive) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            strings.dayStreak(occurrence.currentStreak!.streakCount),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}
