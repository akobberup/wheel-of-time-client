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

/// Skærm der viser kommende opgaver med uendelig scroll-paginering
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

  /// Registrerer når bruger scroller tæt på bunden og indlæser mere data
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(upcomingTasksProvider.notifier).loadMore();
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

    if (state.isLoading && state.occurrences.isEmpty) {
      return const SkeletonListLoader();
    }

    if (state.error != null && state.occurrences.isEmpty) {
      return _buildErrorState(strings, state.error!);
    }

    if (state.occurrences.isEmpty) {
      return EmptyState(
        title: strings.noUpcomingTasks,
        subtitle: strings.allCaughtUpWithTasks,
      );
    }

    return _buildTaskList(state);
  }

  Widget _buildErrorState(AppStrings strings, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            '${strings.error}: $error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(upcomingTasksProvider.notifier).refresh(),
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(UpcomingTasksState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.occurrences.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.occurrences.length) {
          return _buildLoadingIndicator(state.isLoadingMore);
        }

        return _TaskOccurrenceCard(
          occurrence: state.occurrences[index],
          onQuickComplete: _handleQuickComplete,
          onTap: _handleTaskCompletion,
        );
      },
    );
  }

  Widget _buildLoadingIndicator(bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Hurtig fuldførelse med nuværende tidsstempel (til swipe-handling)
  Future<void> _handleQuickComplete(UpcomingTaskOccurrenceResponse occurrence) async {
    final request = CreateTaskInstanceRequest(
      taskId: occurrence.taskId,
      completedDateTime: DateTime.now(),
      optionalComment: null,
    );

    final result = await ref
        .read(taskInstancesProvider(occurrence.taskId).notifier)
        .createTaskInstance(request);

    if (result != null && mounted) {
      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
      );

      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }

  /// Håndterer opgavefuldførelse og viser passende succesbesked
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

      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
        completionMessage: completionMessage,
      );

      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }
}

/// Kort der viser en enkelt opgaveforekomst med swipe-til-fuldførelse
class _TaskOccurrenceCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final Future<void> Function(UpcomingTaskOccurrenceResponse) onQuickComplete;
  final Future<void> Function(BuildContext, UpcomingTaskOccurrenceResponse) onTap;

  const _TaskOccurrenceCard({
    required this.occurrence,
    required this.onQuickComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = occurrence.isNextOccurrence;

    return Dismissible(
      key: Key(occurrence.occurrenceId),
      direction: isClickable ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (!isClickable) return false;
        await onQuickComplete(occurrence);
        return false;
      },
      background: _buildDismissBackground(),
      child: _buildCardContent(context, isClickable),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
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
    );
  }

  Widget _buildCardContent(BuildContext context, bool isClickable) {
    return Stack(
      children: [
        Opacity(
          opacity: isClickable ? 1.0 : 0.6,
          child: _TaskCard(
            occurrence: occurrence,
            isClickable: isClickable,
            onTap: () => onTap(context, occurrence),
          ),
        ),
        if (!isClickable) _buildLockedOverlay(context),
      ],
    );
  }

  Widget _buildLockedOverlay(BuildContext context) {
    final strings = AppStrings.of(context);

    return Positioned.fill(
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
    );
  }
}

/// Opgavekort der viser detaljer om en opgaveforekomst
class _TaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.occurrence,
    required this.isClickable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = occurrence.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isOverdue
          ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.05)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isClickable ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildTaskList(context),
              const SizedBox(height: 4),
              _buildMetadataRow(context),
              if (occurrence.description != null && occurrence.description!.isNotEmpty)
                _buildDescription(context),
              if (occurrence.alarmAtTimeOfDay != null)
                _buildAlarmTime(context),
              if (isClickable && _shouldShowStreakWarning())
                _buildStreakWarning(context),
              if (isClickable && occurrence.currentStreak != null && occurrence.currentStreak!.isActive)
                _buildStreakInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        _DueDateBadge(dueDate: occurrence.dueDate),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    final strings = AppStrings.of(context);

    return Row(
      children: [
        if (occurrence.totalCompletions > 0) ...[
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            strings.timesCompleted(occurrence.totalCompletions),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Icon(
          Icons.repeat,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          occurrence.schedule.description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        occurrence.description!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAlarmTime(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
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
    );
  }

  Widget _buildStreakWarning(BuildContext context) {
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
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
    );
  }

  Widget _buildStreakInfo(BuildContext context) {
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 4),
          Text(
            strings.streakCount(occurrence.currentStreak!.streakCount),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowStreakWarning() {
    if (occurrence.currentStreak == null || !occurrence.currentStreak!.isActive) {
      return false;
    }

    final now = DateTime.now();
    final hoursUntilDue = occurrence.dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}

/// Badge der viser forfaldsdato med farve baseret på hastværk
class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;

  const _DueDateBadge({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dueDateColor = _getDueDateColor(context);
    final dueDateText = _formatDueDate(strings);

    return Container(
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
    );
  }

  /// Formaterer forfaldsdato til menneskeligt læsbar streng
  String _formatDueDate(AppStrings strings) {
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

  /// Returnerer farve for forfaldsdato-badge baseret på hastværk
  Color _getDueDateColor(BuildContext context) {
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
}
