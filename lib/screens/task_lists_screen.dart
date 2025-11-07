import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_list_provider.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';
import 'task_list_detail_screen.dart';
import '../widgets/create_task_list_dialog.dart';
import '../widgets/edit_task_list_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/metric_chip.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../constants/spacing.dart';

class TaskListsScreen extends ConsumerWidget {
  const TaskListsScreen({super.key});

  /// Shows a contextual confirmation dialog for deleting a task list.
  /// Fetches actual task and instance counts to provide specific warnings.
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    int taskListId,
    String taskListName,
  ) async {
    final strings = AppStrings.of(context);
    final apiService = ref.read(apiServiceProvider);

    return await showContextualDeleteDialog(
      context: context,
      title: strings.deleteTaskList,
      itemName: taskListName,
      fetchContext: () async {
        try {
          // Fetch tasks and their instances to get accurate counts
          final tasks = await apiService.getTasksByTaskList(taskListId);

          if (tasks.isEmpty) {
            return const DeletionContext.safe();
          }

          // Count total completions across all tasks
          int totalInstances = 0;
          int activeStreaksCount = 0;

          for (final task in tasks) {
            totalInstances += task.totalCompletions;
            if (task.currentStreak != null && task.currentStreak!.streakCount > 0) {
              activeStreaksCount++;
            }
          }

          return DeletionContext(
            primaryCount: tasks.length,
            secondaryCount: totalInstances,
            tertiaryCount: activeStreaksCount,
            hasActiveStreak: activeStreaksCount > 0,
            isSafe: false,
          );
        } catch (e) {
          // If we can't fetch the data, return a non-safe default context
          return const DeletionContext(primaryCount: 0, isSafe: false);
        }
      },
      buildMessage: (context) {
        if (context.isSafe) {
          return strings.confirmDeleteTaskListEmpty;
        }

        final parts = <String>[];

        parts.add('This will permanently delete:');
        parts.add('\n\n• ${context.primaryCount} ${context.primaryCount == 1 ? 'task' : 'tasks'}');

        if (context.secondaryCount != null && context.secondaryCount! > 0) {
          parts.add('\n• ${context.secondaryCount} completion ${context.secondaryCount == 1 ? 'record' : 'records'}');
        }

        if (context.tertiaryCount != null && context.tertiaryCount! > 0) {
          parts.add('\n• ${context.tertiaryCount} active ${context.tertiaryCount == 1 ? 'streak' : 'streaks'}');
        }

        return parts.join('');
      },
      deleteButtonLabel: strings.delete,
      cancelButtonLabel: strings.cancel,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final taskListsAsync = ref.watch(taskListProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskListProvider.notifier).loadAllTaskLists();
        },
        child: taskListsAsync.when(
          data: (taskLists) {
            if (taskLists.isEmpty) {
              return EmptyState(
                title: strings.noTaskListsYet,
                subtitle: strings.createFirstTaskList,
                action: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(strings.createTaskList),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const CreateTaskListDialog(),
                    );
                    if (result == true && context.mounted) {
                      ref.read(taskListProvider.notifier).loadAllTaskLists();
                    }
                  },
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(Spacing.lg),
              itemCount: taskLists.length,
              itemBuilder: (context, index) {
                final taskList = taskLists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  child: ListTile(
                    leading: taskList.taskListImagePath != null
                        ? CachedNetworkImage(
                            imageUrl: ApiConfig.getImageUrl(taskList.taskListImagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.list_alt),
                          )
                        : const Icon(Icons.list_alt, size: 40),
                    title: Text(taskList.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (taskList.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            taskList.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            MetricChip(
                              icon: Icons.task,
                              label: '${taskList.activeTaskCount}/${taskList.taskCount}',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            MetricChip(
                              icon: Icons.people,
                              label: '${taskList.memberCount}',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Semantics(
                      label: '${strings.moreOptions} ${taskList.name}',
                      button: true,
                      child: PopupMenuButton<String>(
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
                            builder: (context) => EditTaskListDialog(taskList: taskList),
                          );
                          if (result == true) {
                            ref.read(taskListProvider.notifier).loadAllTaskLists();
                          }
                        } else if (value == 'delete') {
                          final confirmed = await _showDeleteConfirmation(
                            context,
                            ref,
                            taskList.id,
                            taskList.name,
                          );
                          if (confirmed) {
                            final success = await ref
                                .read(taskListProvider.notifier)
                                .deleteTaskList(taskList.id);
                            if (context.mounted) {
                              final strings = AppStrings.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? strings.taskListDeletedSuccess
                                        : strings.failedToDeleteTaskList,
                                  ),
                                ),
                              );
                            }
                          }
                        }
                        },
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskListDetailScreen(
                            taskListId: taskList.id,
                            taskListName: taskList.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorStateWidget(
            message: '${strings.error}: $error',
            onRetry: () => ref.read(taskListProvider.notifier).loadAllTaskLists(),
            retryLabel: strings.retry,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const CreateTaskListDialog(),
          );
          if (result == true) {
            ref.read(taskListProvider.notifier).loadAllTaskLists();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
