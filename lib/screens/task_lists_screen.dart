import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_list_provider.dart';
import '../providers/auth_provider.dart';
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

/// Viser liste over brugerens opgavelister med mulighed for at oprette, redigere og slette
class TaskListsScreen extends HookConsumerWidget {
  const TaskListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final taskListsAsync = ref.watch(taskListProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskListProvider.notifier).loadAllTaskLists(),
        child: taskListsAsync.when(
          data: (taskLists) => _buildTaskListsContent(taskLists, strings, context, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error, strings, ref),
        ),
      ),
      floatingActionButton: _buildCreateButton(context, ref),
    );
  }

  Widget _buildTaskListsContent(
    List<dynamic> taskLists,
    AppStrings strings,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (taskLists.isEmpty) {
      return _buildEmptyState(strings, context, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.lg),
      itemCount: taskLists.length,
      itemBuilder: (context, index) => _TaskListCard(taskList: taskLists[index]),
    );
  }

  Widget _buildEmptyState(AppStrings strings, BuildContext context, WidgetRef ref) {
    return EmptyState(
      title: strings.noTaskListsYet,
      subtitle: strings.createFirstTaskList,
      action: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(strings.createTaskList),
        onPressed: () => _handleCreateTaskList(context, ref),
      ),
    );
  }

  Widget _buildErrorState(Object error, AppStrings strings, WidgetRef ref) {
    return ErrorStateWidget(
      message: '${strings.error}: $error',
      onRetry: () => ref.read(taskListProvider.notifier).loadAllTaskLists(),
      retryLabel: strings.retry,
    );
  }

  Widget _buildCreateButton(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _handleCreateTaskList(context, ref),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _handleCreateTaskList(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateTaskListDialog(),
    );
    if (result == true) {
      ref.read(taskListProvider.notifier).loadAllTaskLists();
    }
  }
}

/// Kort der viser en enkelt opgaveliste med billede, titel, beskrivelse og statistik
class _TaskListCard extends HookConsumerWidget {
  final dynamic taskList;

  const _TaskListCard({required this.taskList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: ListTile(
        leading: _buildLeadingImage(),
        title: Text(taskList.name),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildMenuButton(context, ref, strings),
        onTap: () => _handleNavigateToDetail(context),
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (taskList.taskListImagePath == null) {
      return const Icon(Icons.list_alt, size: 40);
    }

    return CachedNetworkImage(
      imageUrl: ApiConfig.getImageUrl(taskList.taskListImagePath!),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.list_alt),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
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
        _buildMetrics(context),
      ],
    );
  }

  Widget _buildMetrics(BuildContext context) {
    return Wrap(
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
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref, AppStrings strings) {
    return Semantics(
      label: '${strings.moreOptions} ${taskList.name}',
      button: true,
      child: PopupMenuButton<String>(
        itemBuilder: (context) => _buildMenuItems(strings),
        onSelected: (value) => _handleMenuSelection(value, context, ref, strings),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(AppStrings strings) {
    return [
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
    ];
  }

  Future<void> _handleMenuSelection(
    String value,
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    if (value == 'edit') {
      await _handleEdit(context, ref);
    } else if (value == 'delete') {
      await _handleDelete(context, ref, strings);
    }
  }

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditTaskListDialog(taskList: taskList),
    );
    if (result == true) {
      ref.read(taskListProvider.notifier).loadAllTaskLists();
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final confirmed = await _showDeleteConfirmation(context, ref, strings);
    if (!confirmed) return;

    final success = await ref
        .read(taskListProvider.notifier)
        .deleteTaskList(taskList.id);

    if (context.mounted) {
      _showDeleteResultSnackBar(context, strings, success);
    }
  }

  /// Viser bekræftelsesdialog med kontekstuel information om opgavelistens indhold
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final apiService = ref.read(apiServiceProvider);

    return await showContextualDeleteDialog(
      context: context,
      title: strings.deleteTaskList,
      itemName: taskList.name,
      fetchContext: () => _fetchDeletionContext(apiService),
      buildMessage: (context) => _buildDeleteMessage(context, strings),
      deleteButtonLabel: strings.delete,
      cancelButtonLabel: strings.cancel,
    );
  }

  /// Henter information om opgavelistens indhold for at give kontekst til sletning
  Future<DeletionContext> _fetchDeletionContext(dynamic apiService) async {
    try {
      final tasks = await apiService.getTasksByTaskList(taskList.id);

      if (tasks.isEmpty) {
        return const DeletionContext.safe();
      }

      int totalInstances = 0;
      int activeStreaksCount = 0;

      for (final task in tasks) {
        totalInstances += task.totalCompletions as int;
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
      return const DeletionContext(primaryCount: 0, isSafe: false);
    }
  }

  String _buildDeleteMessage(DeletionContext context, AppStrings strings) {
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
  }

  void _showDeleteResultSnackBar(
    BuildContext context,
    AppStrings strings,
    bool success,
  ) {
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

  void _handleNavigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskListDetailScreen(
          taskListId: taskList.id,
          taskListName: taskList.name,
        ),
      ),
    );
  }
}
