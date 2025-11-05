import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_provider.dart';
import '../providers/task_history_provider.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../config/api_config.dart';
import 'task_list_members_screen.dart';
import 'task_history_screen.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../models/enums.dart';

class TaskListDetailScreen extends ConsumerWidget {
  final int taskListId;
  final String? taskListName;

  const TaskListDetailScreen({
    super.key,
    required this.taskListId,
    this.taskListName,
  });

  /// Formats the repeat pattern into a natural, readable string.
  /// Examples: "Daily", "Weekly", "Every 3 months"
  String _formatRepeat(RepeatUnit unit, int delta) {
    if (delta == 1) {
      switch (unit) {
        case RepeatUnit.DAYS:
          return 'Daily';
        case RepeatUnit.WEEKS:
          return 'Weekly';
        case RepeatUnit.MONTHS:
          return 'Monthly';
        case RepeatUnit.YEARS:
          return 'Yearly';
      }
    }
    final unitName = unit.name.toLowerCase();
    return 'Every $delta $unitName';
  }

  /// Shows a contextual confirmation dialog for deleting a task.
  /// Fetches task instances and streak data to provide specific warnings.
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    int taskId,
    String taskName,
  ) async {
    final strings = AppStrings.of(context);

    return await showContextualDeleteDialog(
      context: context,
      title: strings.deleteTask,
      itemName: taskName,
      fetchContext: () async {
        try {
          // Fetch task instances to get completion count
          final taskHistoryNotifier = ref.read(taskHistoryProvider(taskId).notifier);
          await taskHistoryNotifier.refresh();
          final instances = ref.read(taskHistoryProvider(taskId)).value ?? [];

          // Get task details for streak information
          final tasks = ref.read(tasksProvider(taskListId)).value ?? [];
          final task = tasks.firstWhere((t) => t.id == taskId);

          final hasStreak = task.currentStreak != null && task.currentStreak!.streakCount > 0;
          final streakCount = task.currentStreak?.streakCount ?? 0;
          final completionCount = instances.length;

          if (completionCount == 0) {
            return const DeletionContext.safe();
          }

          return DeletionContext(
            primaryCount: completionCount,
            hasActiveStreak: hasStreak,
            streakCount: streakCount,
            isSafe: false,
          );
        } catch (e) {
          // If we can't fetch the data, return a non-safe default context
          return const DeletionContext(primaryCount: 0, isSafe: false);
        }
      },
      buildMessage: (context) {
        if (context.isSafe) {
          return 'This task has no completion records and can be safely deleted.';
        }

        if (context.hasActiveStreak && context.streakCount != null) {
          return 'This will permanently delete:\n\n'
              '• Your ${context.streakCount}-day streak\n'
              '• ${context.primaryCount} completion ${context.primaryCount == 1 ? 'record' : 'records'}';
        }

        if (context.primaryCount > 0) {
          return 'This will permanently delete ${context.primaryCount} completion ${context.primaryCount == 1 ? 'record' : 'records'}.';
        }

        return 'This task will be permanently deleted.';
      },
      deleteButtonLabel: strings.delete,
      cancelButtonLabel: strings.cancel,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final tasksAsync = ref.watch(tasksProvider(taskListId));

    return Scaffold(
      appBar: AppBar(
        title: Text(taskListName != null ? strings.tasksIn(taskListName!) : strings.tasks),
        actions: [
          Semantics(
            label: strings.members,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.people),
              tooltip: strings.members,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskListMembersScreen(
                      taskListId: taskListId,
                      taskListName: taskListName ?? strings.taskLists,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(tasksProvider(taskListId).notifier).loadTasks();
        },
        child: tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return EmptyState(
                title: strings.noTasks,
                subtitle: strings.addFirstTask,
                action: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(strings.createTask),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => CreateTaskDialog(taskListId: taskListId),
                    );
                    if (result == true && context.mounted) {
                      ref.read(tasksProvider(taskListId).notifier).loadTasks();
                    }
                  },
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskHistoryScreen(
                            taskId: task.id,
                            taskName: task.name,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: task.taskImagePath != null
                          ? CachedNetworkImage(
                              imageUrl: ApiConfig.getImageUrl(task.taskImagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 50,
                                height: 50,
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                size: 40,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 40),
                      title: Text(task.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            _formatRepeat(task.repeatUnit, task.repeatDelta),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          if (task.currentStreak != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(strings.dayStreak(task.currentStreak!.streakCount)),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 12),
                                Text(strings.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 20, color: Colors.red),
                                const SizedBox(width: 12),
                                Text(strings.delete, style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => EditTaskDialog(task: task),
                            );
                            if (result == true) {
                              ref.read(tasksProvider(taskListId).notifier).loadTasks();
                            }
                          } else if (value == 'delete') {
                            final confirmed = await _showDeleteConfirmation(
                              context,
                              ref,
                              task.id,
                              task.name,
                            );
                            if (confirmed) {
                              final success = await ref
                                  .read(tasksProvider(taskListId).notifier)
                                  .deleteTask(task.id);
                              if (context.mounted) {
                                final strings = AppStrings.of(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? strings.taskDeletedSuccess
                                          : strings.failedToDeleteTask,
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const SkeletonListLoader(),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => CreateTaskDialog(taskListId: taskListId),
          );
          if (result == true) {
            ref.read(tasksProvider(taskListId).notifier).loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
