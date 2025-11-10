import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_provider.dart';
import '../providers/task_history_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../config/api_config.dart';
import 'task_list_members_screen.dart';
import 'task_history_screen.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../models/schedule.dart';

class TaskListDetailScreen extends ConsumerStatefulWidget {
  final int taskListId;
  final String? taskListName;

  const TaskListDetailScreen({
    super.key,
    required this.taskListId,
    this.taskListName,
  });

  @override
  ConsumerState<TaskListDetailScreen> createState() => _TaskListDetailScreenState();
}

class _TaskListDetailScreenState extends ConsumerState<TaskListDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-fetch suggestions in the background when screen loads
    // This is non-blocking and will silently enhance UX
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(suggestionCacheProvider.notifier).preFetchSuggestions(widget.taskListId);
    });
  }

  /// Formats the schedule into a natural, readable string.
  /// Supports both interval and weekly pattern schedules.
  /// The schedule already contains a description, so we use that directly.
  String _formatSchedule(TaskSchedule schedule) {
    return schedule.when(
      interval: (unit, delta, description) => description,
      weeklyPattern: (weeks, days, description) => description,
    );
  }

  /// Shows a contextual confirmation dialog for deleting a task.
  /// Fetches task instances and streak data to provide specific warnings.
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
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
          final tasks = ref.read(tasksProvider(widget.taskListId)).value ?? [];
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
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tasksAsync = ref.watch(tasksProvider(widget.taskListId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskListName != null ? strings.tasksIn(widget.taskListName!) : strings.tasks),
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
                      taskListId: widget.taskListId,
                      taskListName: widget.taskListName ?? strings.taskLists,
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
          await ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
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
                      builder: (context) => CreateTaskDialog(taskListId: widget.taskListId),
                    );
                    if (result == true && context.mounted) {
                      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
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
                            _formatSchedule(task.schedule),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          if (task.currentStreak != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
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
                              ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
                            }
                          } else if (value == 'delete') {
                            final confirmed = await _showDeleteConfirmation(
                              context,
                              task.id,
                              task.name,
                            );
                            if (confirmed) {
                              final success = await ref
                                  .read(tasksProvider(widget.taskListId).notifier)
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
            builder: (context) => CreateTaskDialog(taskListId: widget.taskListId),
          );
          if (result == true) {
            ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
