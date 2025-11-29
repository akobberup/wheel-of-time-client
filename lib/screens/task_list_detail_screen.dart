// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/task_provider.dart';
import '../providers/task_history_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../widgets/common/animated_card.dart';
import '../widgets/common/gradient_background.dart';
import '../config/api_config.dart';
import 'task_list_members_screen.dart';
import 'task_history_screen.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../models/schedule.dart';
import '../models/task.dart' show TaskResponse;

/// Viser detaljer for en opgaveliste med alle dens opgaver
class TaskListDetailScreen extends ConsumerStatefulWidget {
  final int taskListId;
  final String? taskListName;

  const TaskListDetailScreen({
    super.key,
    required this.taskListId,
    this.taskListName,
  });

  @override
  ConsumerState<TaskListDetailScreen> createState() =>
      _TaskListDetailScreenState();
}

class _TaskListDetailScreenState extends ConsumerState<TaskListDetailScreen> {
  @override
  void initState() {
    super.initState();
    _preFetchSuggestions();
  }

  /// Pre-henter AI-forslag i baggrunden for bedre brugeroplevelse
  void _preFetchSuggestions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(suggestionCacheProvider.notifier)
          .preFetchSuggestions(widget.taskListId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tasksAsync = ref.watch(tasksProvider(widget.taskListId));
    final themeColor = ref.watch(themeProvider).seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(strings, themeColor, isDark),
          SliverToBoxAdapter(
            child: _buildBody(tasksAsync, strings),
          ),
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(strings, themeColor, isDark),
    );
  }

  /// Bygger custom SliverAppBar med varm, organisk æstetik
  Widget _buildSliverAppBar(AppStrings strings, Color themeColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor:
          isDark ? const Color(0xFF1A1A1C) : const Color(0xFFFAFAF8),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.taskListName != null
              ? strings.tasksIn(widget.taskListName!)
              : strings.tasks,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColor.withValues(alpha: 0.05),
                themeColor.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ),
      actions: [_buildMembersButton(strings)],
    );
  }

  Widget _buildMembersButton(AppStrings strings) {
    return Semantics(
      label: strings.members,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.people),
        tooltip: strings.members,
        onPressed: () => _navigateToMembers(strings),
      ),
    );
  }

  Widget _buildBody(
      AsyncValue<List<TaskResponse>> tasksAsync, AppStrings strings) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(tasksProvider(widget.taskListId).notifier).loadTasks(),
      child: tasksAsync.when(
        data: (tasks) => _buildTasksList(tasks, strings),
        loading: () => const SkeletonListLoader(),
        error: (error, stack) => _buildErrorState(error, strings),
      ),
    );
  }

  Widget _buildTasksList(List<TaskResponse> tasks, AppStrings strings) {
    if (tasks.isEmpty) {
      return _buildEmptyState(strings);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Begrans bredden pa desktop for bedre laesbarhed og proportioner
        const maxContentWidth = 700.0;
        final isWideScreen = constraints.maxWidth > maxContentWidth;
        final horizontalPadding =
            isWideScreen ? (constraints.maxWidth - maxContentWidth) / 2 : 16.0;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) => _TaskCard(
            task: tasks[index],
            taskListId: widget.taskListId,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return EmptyState(
      title: strings.noTasks,
      subtitle: strings.addFirstTask,
      action: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(strings.createTask),
        onPressed: () => _handleCreateTask(),
      ),
    );
  }

  Widget _buildErrorState(Object error, AppStrings strings) {
    return Center(
      child: Text(strings.networkError(error.toString())),
    );
  }

  /// Bygger FAB med tema-farve og glow effekt (Design 1.0.0)
  Widget _buildFloatingActionButton(
      AppStrings strings, Color themeColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Glow effekt med tema-farven
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _handleCreateTask(),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _navigateToMembers(AppStrings strings) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskListMembersScreen(
          taskListId: widget.taskListId,
          taskListName: widget.taskListName ?? strings.taskLists,
        ),
      ),
    );
  }

  Future<void> _handleCreateTask() async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(taskListId: widget.taskListId),
    );
    if (result == true && mounted) {
      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
    }
  }
}

/// Kort der viser en enkelt opgave med hero-billede, detaljer og handlinger (Design 1.0.0)
class _TaskCard extends ConsumerWidget {
  final TaskResponse task;
  final int taskListId;

  const _TaskCard({
    required this.task,
    required this.taskListId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Bløde kort med borderRadius: 16 (Design 1.0.0)
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? const Color(0xFF222226) // Overflade (cards) mørk
            : const Color(0xFFFFFFFF), // Overflade (cards) lys
        // Subtile skygger (Niveau 2: cards)
        boxShadow: isDark
            ? [] // I mørk tilstand: Brug lysere baggrunde i stedet for shadows
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
          onTap: () => _navigateToTaskHistory(context),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero billede eller gradient
              _buildHeroSection(context),
              // Indhold
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel og menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                        _buildPopupMenu(context, ref),
                      ],
                    ),
                    // Beskrivelse
                    if (task.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFA0A0A0) // Tekst sekundær mørk
                              : const Color(0xFF6B6B6B), // Tekst sekundær lys
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Metadata række
                    _buildMetadataRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bygger hero sektionen med billede eller gradient
  Widget _buildHeroSection(BuildContext context) {
    const heroHeight = 80.0;
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    );

    final hasImage =
        task.taskImagePath != null && task.taskImagePath!.isNotEmpty;
    if (hasImage) {
      return HeroImageContainer(
        height: heroHeight,
        borderRadius: borderRadius,
        image: CachedNetworkImage(
          imageUrl: ApiConfig.getImageUrl(task.taskImagePath!),
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(context),
          errorWidget: (context, url, error) => GradientBackground(
            seed: task.name,
            height: heroHeight,
            showOverlay: false,
          ),
        ),
      );
    }

    return GradientBackground(
      seed: task.name,
      height: heroHeight,
      borderRadius: borderRadius,
      showOverlay: false,
      child: Center(
        child: Icon(
          Icons.check_circle_outline,
          size: 32,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Bygger metadata række med schedule og streak (Design 1.0.0)
  Widget _buildMetadataRow(BuildContext context) {
    final strings = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Schedule chip
        _buildChip(
          context,
          icon: Icons.repeat_rounded,
          label: _formatSchedule(task.schedule),
          color: colorScheme.primary,
        ),
        // Streak chip hvis aktiv (brug ikon fra design guidelines)
        if (task.currentStreak != null && task.currentStreak!.streakCount > 0)
          _buildChip(
            context,
            icon: Icons.local_fire_department,
            label: strings.streakCount(task.currentStreak!.streakCount),
            color: colorScheme.tertiary,
          ),
        // Completions chip (brug check_circle_outline fra guidelines)
        if (task.totalCompletions > 0)
          _buildChip(
            context,
            icon: Icons.check_circle_outline,
            label: '${task.totalCompletions}x',
            color: colorScheme.secondary,
          ),
      ],
    );
  }

  /// Bygger chip med bløde kanter (borderRadius: 8px for små elementer - Design 1.0.0)
  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(8), // Små elementer (badges, chips): 8px
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        _buildEditMenuItem(strings),
        _buildDeleteMenuItem(strings),
      ],
      onSelected: (value) => _handleMenuSelection(context, ref, value),
    );
  }

  PopupMenuItem<String> _buildEditMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          const Icon(Icons.edit, size: 20),
          const SizedBox(width: 12),
          Text(strings.edit),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildDeleteMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          const Icon(Icons.delete, size: 20, color: Colors.red),
          const SizedBox(width: 12),
          Text(strings.delete, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  String _formatSchedule(TaskSchedule schedule) {
    return schedule.when(
      interval: (unit, delta, description) => description,
      weeklyPattern: (weeks, days, description) => description,
    );
  }

  void _navigateToTaskHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskHistoryScreen(
          taskId: task.id,
          taskName: task.name,
        ),
      ),
    );
  }

  Future<void> _handleMenuSelection(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    if (value == 'edit') {
      await _handleEdit(context, ref);
    } else if (value == 'delete') {
      await _handleDelete(context, ref);
    }
  }

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditTaskDialog(task: task),
    );
    if (result == true) {
      ref.read(tasksProvider(taskListId).notifier).loadTasks();
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final confirmed = await _showDeleteConfirmation(context, ref, strings);

    if (!confirmed) return;

    final success =
        await ref.read(tasksProvider(taskListId).notifier).deleteTask(task.id);

    if (context.mounted) {
      _showDeleteResult(context, success, strings);
    }
  }

  /// Viser bekræftelsesdialog med kontekstuel information om sletning
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    return await showContextualDeleteDialog(
      context: context,
      title: strings.deleteTask,
      itemName: task.name,
      fetchContext: () => _fetchDeletionContext(ref),
      buildMessage: _buildDeletionMessage,
      deleteButtonLabel: strings.delete,
      cancelButtonLabel: strings.cancel,
    );
  }

  /// Henter kontekst for sletning (antal completions og streak-info)
  Future<DeletionContext> _fetchDeletionContext(WidgetRef ref) async {
    try {
      final taskHistoryNotifier =
          ref.read(taskHistoryProvider(task.id).notifier);
      await taskHistoryNotifier.refresh();
      final instances = ref.read(taskHistoryProvider(task.id)).value ?? [];

      final hasStreak =
          task.currentStreak != null && task.currentStreak!.streakCount > 0;
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
      return const DeletionContext(primaryCount: 0, isSafe: false);
    }
  }

  String _buildDeletionMessage(DeletionContext context) {
    if (context.isSafe) {
      return 'This task has no completion records and can be safely deleted.';
    }

    if (context.hasActiveStreak && context.streakCount != null) {
      return 'This will permanently delete:\n\n'
          '• Your ${context.streakCount}x streak\n'
          '• ${context.primaryCount} completion ${context.primaryCount == 1 ? 'record' : 'records'}';
    }

    if (context.primaryCount > 0) {
      return 'This will permanently delete ${context.primaryCount} completion ${context.primaryCount == 1 ? 'record' : 'records'}.';
    }

    return 'This task will be permanently deleted.';
  }

  void _showDeleteResult(
      BuildContext context, bool success, AppStrings strings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? strings.taskDeletedSuccess : strings.failedToDeleteTask,
        ),
      ),
    );
  }
}
