import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_list_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';
import 'task_list_detail_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import '../widgets/create_task_list_dialog.dart';
import '../widgets/edit_task_list_dialog.dart';

class TaskListsScreen extends ConsumerWidget {
  const TaskListsScreen({super.key});

  /// Shows a confirmation dialog for deleting a task list.
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool> _showDeleteConfirmation(BuildContext context, String taskListName) async {
    final strings = AppStrings.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.deleteTaskList),
            content: Text(strings.confirmDeleteTaskList(taskListName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(strings.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final taskListsAsync = ref.watch(taskListProvider);
    final notificationCount = ref.watch(notificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: notificationCount > 0,
              label: Text('$notificationCount'),
              child: const Icon(Icons.notifications),
            ),
            tooltip: strings.notifications,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: strings.logout,
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskListProvider.notifier).loadAllTaskLists();
        },
        child: taskListsAsync.when(
          data: (taskLists) {
            if (taskLists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.noTaskListsYet,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.createFirstTaskList,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: taskLists.length,
              itemBuilder: (context, index) {
                final taskList = taskLists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                        Row(
                          children: [
                            Icon(Icons.task, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${taskList.activeTaskCount}/${taskList.taskCount}'),
                            const SizedBox(width: 16),
                            Icon(Icons.people, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${taskList.memberCount}'),
                          ],
                        ),
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
                            builder: (context) => EditTaskListDialog(taskList: taskList),
                          );
                          if (result == true) {
                            ref.read(taskListProvider.notifier).loadAllTaskLists();
                          }
                        } else if (value == 'delete') {
                          final confirmed = await _showDeleteConfirmation(
                            context,
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
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(taskListProvider.notifier).loadAllTaskLists();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
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
