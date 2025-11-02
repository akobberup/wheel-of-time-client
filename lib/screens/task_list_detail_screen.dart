import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task_instance.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/complete_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import 'task_list_members_screen.dart';

class TaskListDetailScreen extends ConsumerWidget {
  final int taskListId;
  final String? taskListName;

  const TaskListDetailScreen({
    super.key,
    required this.taskListId,
    this.taskListName,
  });

  /// Shows a confirmation dialog for deleting a task.
  /// Returns true if user confirms deletion, false otherwise.
  Future<bool> _showDeleteConfirmation(BuildContext context, String taskName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "$taskName"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(taskListId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Members',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskListMembersScreen(
                    taskListId: taskListId,
                    taskListName: taskListName ?? 'Task List',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            onPressed: () {
              // Show options menu
            },
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first task to this list',
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
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: task.taskImagePath != null
                        ? Image.network(
                            'http://localhost:8080${task.taskImagePath}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
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
                          '${task.repeatUnit.name} (every ${task.repeatDelta})',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        if (task.currentStreak != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('${task.currentStreak!.streakCount} day streak'),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.isActive)
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: 'Complete',
                            onPressed: () async {
                              final result = await showDialog<TaskInstanceResponse>(
                                context: context,
                                builder: (context) => CompleteTaskDialog(taskId: task.id),
                              );
                              if (result != null) {
                                ref.read(tasksProvider(taskListId).notifier).loadTasks();
                              }
                            },
                          )
                        else
                          const Icon(Icons.pause_circle_outline, color: Colors.grey),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => EditTaskDialog(task: task),
                            );
                            if (result == true) {
                              ref.read(tasksProvider(taskListId).notifier).loadTasks();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          color: Colors.red,
                          onPressed: () async {
                            final confirmed = await _showDeleteConfirmation(
                              context,
                              task.name,
                            );
                            if (confirmed) {
                              final success = await ref
                                  .read(tasksProvider(taskListId).notifier)
                                  .deleteTask(task.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Task deleted successfully'
                                          : 'Failed to delete task',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
