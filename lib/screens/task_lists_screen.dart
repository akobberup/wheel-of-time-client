// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_list_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';
import 'task_list_detail_screen.dart';
import '../widgets/create_task_list_dialog.dart';
import '../widgets/edit_task_list_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../widgets/common/animated_card.dart';
import '../widgets/common/circular_progress_indicator_with_icon.dart';
import '../widgets/common/gradient_background.dart';
import '../widgets/common/stacked_avatars.dart';
import '../constants/spacing.dart';

/// Viser liste over brugerens opgavelister med mulighed for at oprette, redigere og slette
class TaskListsScreen extends HookConsumerWidget {
  const TaskListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final taskListsAsync = ref.watch(taskListProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final backgroundColor =
        isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskListProvider.notifier).loadAllTaskLists(),
        child: taskListsAsync.when(
          data: (taskLists) =>
              _buildTaskListsContent(taskLists, strings, context, ref),
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

    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Begræns bredden på desktop for bedre læsbarhed og proportioner
        const maxContentWidth = 700.0;
        final isWideScreen = constraints.maxWidth > maxContentWidth;
        final horizontalPadding =
            isWideScreen ? (constraints.maxWidth - maxContentWidth) / 2 : 24.0;

        return CustomScrollView(
          slivers: [
            // Custom SliverAppBar med varm æstetik
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor:
                  isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  strings.taskLists,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: themeState.seedColor,
                  ),
                ),
                titlePadding: EdgeInsets.only(
                  left: horizontalPadding,
                  bottom: 16,
                ),
              ),
            ),
            // Liste af opgavelister
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TaskListCard(taskList: taskLists[index]),
                  childCount: taskLists.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
      AppStrings strings, BuildContext context, WidgetRef ref) {
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

  Future<void> _handleCreateTaskList(
      BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateTaskListDialog(),
    );
    if (result == true) {
      ref.read(taskListProvider.notifier).loadAllTaskLists();
    }
  }
}

/// Kort der viser en enkelt opgaveliste med hero-billede, fremskridtsindikator og medlemmer
class _TaskListCard extends HookConsumerWidget {
  final dynamic taskList;

  const _TaskListCard({required this.taskList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final cardColor =
        isDark ? const Color(0xFF222226) : const Color(0xFFFFFFFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        // Subtil skygge i lyst tema, lysere baggrund i mørkt tema
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNavigateToDetail(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero billede eller gradient baggrund
              _buildHeroSection(context),
              // Indhold under hero
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel og menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            taskList.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFF5F5F5)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        _buildMenuButton(context, ref, strings),
                      ],
                    ),
                    // Beskrivelse
                    if (taskList.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        taskList.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFA0A0A0)
                              : const Color(0xFF6B6B6B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Statistik række
                    _buildStatsRow(context, strings, themeState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bygger hero sektionen med billede eller gradient baggrund
  Widget _buildHeroSection(BuildContext context) {
    const heroHeight = 100.0;
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    );

    if (taskList.taskListImagePath != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: ApiConfig.getImageUrl(taskList.taskListImagePath!),
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(context),
            errorWidget: (context, url, error) => GradientBackground(
              seed: taskList.name,
              height: heroHeight,
              showOverlay: false,
            ),
          ),
        ),
      );
    }

    return GradientBackground(
      seed: taskList.name,
      height: heroHeight,
      borderRadius: borderRadius,
      showOverlay: false,
      child: Center(
        child: Icon(
          Icons.list_alt,
          size: 40,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Bygger statistik række med fremskridtsindikator og medlemmer
  Widget _buildStatsRow(
      BuildContext context, AppStrings strings, ThemeState themeState) {
    final isDark = themeState.isDarkMode;
    final primaryTextColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A);
    final secondaryTextColor =
        isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);

    return Row(
      children: [
        // Cirkulær fremskridtsindikator
        CircularProgressIndicatorWithIcon(
          completed: taskList.activeTaskCount as int,
          total: taskList.taskCount as int,
          icon: Icons.task_alt,
          size: 40,
          strokeWidth: 3,
        ),
        const SizedBox(width: 8),
        // Tekst med opgavestatus
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${taskList.activeTaskCount}/${taskList.taskCount} ${strings.tasks.toLowerCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: primaryTextColor,
                ),
              ),
              Text(
                _getProgressText(strings),
                style: TextStyle(
                  fontSize: 11,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        // Stablede medlems-avatarer
        if (taskList.memberCount > 0)
          StackedAvatars(
            memberCount: taskList.memberCount as int,
            avatarSize: 28,
            maxVisible: 3,
          ),
      ],
    );
  }

  /// Returnerer progress tekst baseret på fuldførelsesprocent
  String _getProgressText(AppStrings strings) {
    final total = taskList.taskCount as int;
    final completed = taskList.activeTaskCount as int;

    if (total == 0) return strings.noTasks;

    final percent = total > 0 ? ((completed / total) * 100).round() : 0;
    return '$percent% fuldført';
  }

  Widget _buildMenuButton(
      BuildContext context, WidgetRef ref, AppStrings strings) {
    return Semantics(
      label: '${strings.moreOptions} ${taskList.name}',
      button: true,
      child: PopupMenuButton<String>(
        itemBuilder: (context) => _buildMenuItems(strings),
        onSelected: (value) =>
            _handleMenuSelection(value, context, ref, strings),
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

    final success =
        await ref.read(taskListProvider.notifier).deleteTaskList(taskList.id);

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
    parts.add(
        '\n\n• ${context.primaryCount} ${context.primaryCount == 1 ? 'task' : 'tasks'}');

    if (context.secondaryCount != null && context.secondaryCount! > 0) {
      parts.add(
          '\n• ${context.secondaryCount} completion ${context.secondaryCount == 1 ? 'record' : 'records'}');
    }

    if (context.tertiaryCount != null && context.tertiaryCount! > 0) {
      parts.add(
          '\n• ${context.tertiaryCount} active ${context.tertiaryCount == 1 ? 'streak' : 'streaks'}');
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
