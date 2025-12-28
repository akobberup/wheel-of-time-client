// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_history_provider.dart';
import '../providers/suggestion_cache_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../config/api_config.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../models/schedule.dart';
import '../models/task.dart' show TaskResponse;

/// Viser detaljer for en opgaveliste med alle dens opgaver
/// Hele skærmen er farvet af opgavelistens tema (primary/secondary colors)
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
  // Flag til at spore om vi allerede har vist create-task dialogen (onboarding)
  bool _hasShownCreateTaskDialog = false;

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

  /// Parser hex color string til Color objekt
  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;

    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF');
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      return fallback;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tasksAsync = ref.watch(tasksProvider(widget.taskListId));
    final taskListAsync = ref.watch(taskListDetailProvider(widget.taskListId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackColor = ref.watch(themeProvider).seedColor;

    // Hent tema farver fra opgavelisten
    final primaryColor = taskListAsync.whenOrNull(
          data: (taskList) =>
              _parseHexColor(taskList.visualTheme.primaryColor, fallbackColor),
        ) ??
        fallbackColor;

    final secondaryColor = taskListAsync.whenOrNull(
          data: (taskList) =>
              _parseHexColor(taskList.visualTheme.secondaryColor, fallbackColor),
        ) ??
        fallbackColor;

    // Baggrund med subtil tema-tint
    final backgroundColor = isDark
        ? Color.lerp(const Color(0xFF121214), primaryColor, 0.03)!
        : Color.lerp(const Color(0xFFFAFAF8), primaryColor, 0.05)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(
              strings, primaryColor, secondaryColor, isDark),
          SliverToBoxAdapter(
            child: _buildBody(
                tasksAsync, strings, primaryColor, secondaryColor, isDark),
          ),
        ],
      ),
      floatingActionButton:
          _buildFloatingActionButton(strings, primaryColor, isDark),
    );
  }

  /// Bygger custom SliverAppBar med opgavelistens tema-gradient
  Widget _buildSliverAppBar(
    AppStrings strings,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.taskListName != null
              ? strings.tasksIn(widget.taskListName!)
              : strings.tasks,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
          // Subtilt mønster overlay
          child: Stack(
            children: [
              // Dekorativt cirkulært element (wheel motiv)
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [_buildMembersButton(strings, primaryColor, secondaryColor)],
    );
  }

  Widget _buildMembersButton(AppStrings strings, Color primaryColor, Color secondaryColor) {
    return Semantics(
      label: strings.members,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.people),
        tooltip: strings.members,
        onPressed: () => _navigateToMembers(strings, primaryColor, secondaryColor),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<TaskResponse>> tasksAsync,
    AppStrings strings,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () =>
          ref.read(tasksProvider(widget.taskListId).notifier).loadTasks(),
      child: tasksAsync.when(
        data: (tasks) =>
            _buildTasksList(tasks, strings, primaryColor, secondaryColor, isDark),
        loading: () => const SkeletonListLoader(),
        error: (error, stack) => _buildErrorState(error, strings),
      ),
    );
  }

  Widget _buildTasksList(
    List<TaskResponse> tasks,
    AppStrings strings,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    // Onboarding: Åbn create-task dialog automatisk hvis ingen opgaver findes
    if (tasks.isEmpty && !_hasShownCreateTaskDialog) {
      _hasShownCreateTaskDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboardingCreateTaskDialog(primaryColor, secondaryColor);
      });
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(strings, primaryColor);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
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
          itemBuilder: (context, index) => _ThemedTaskCard(
            task: tasks[index],
            taskListId: widget.taskListId,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppStrings strings, Color primaryColor) {
    return EmptyState(
      title: strings.noTasks,
      subtitle: strings.addFirstTask,
      action: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(strings.createTask),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _handleCreateTask(),
      ),
    );
  }

  Widget _buildErrorState(Object error, AppStrings strings) {
    return Center(
      child: Text(strings.networkError(error.toString())),
    );
  }

  /// Bygger FAB med tema-farve og glow effekt
  Widget _buildFloatingActionButton(
      AppStrings strings, Color primaryColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _handleCreateTask(),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _navigateToMembers(AppStrings strings, Color primaryColor, Color secondaryColor) {
    final listName = widget.taskListName ?? strings.taskLists;
    final primaryHex = '#${primaryColor.value.toRadixString(16).substring(2)}';
    final secondaryHex = '#${secondaryColor.value.toRadixString(16).substring(2)}';
    
    context.push(
      '/lists/${widget.taskListId}/members?name=${Uri.encodeComponent(listName)}&primaryColor=${Uri.encodeComponent(primaryHex)}&secondaryColor=${Uri.encodeComponent(secondaryHex)}',
    );
  }

  /// Viser onboarding create-task dialog (bruges kun første gang)
  Future<void> _showOnboardingCreateTaskDialog(
    Color primaryColor,
    Color secondaryColor,
  ) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CreateTaskDialog(
        taskListId: widget.taskListId,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );
    if (result == true && mounted) {
      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
    }
  }

  Future<void> _handleCreateTask() async {
    final taskListAsync = ref.read(taskListDetailProvider(widget.taskListId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackColor = ref.read(themeProvider).seedColor;

    // Hent tema farver fra opgavelisten
    final primaryColor = taskListAsync.whenOrNull(
          data: (taskList) =>
              _parseHexColor(taskList.visualTheme.primaryColor, fallbackColor),
        ) ??
        fallbackColor;

    final secondaryColor = taskListAsync.whenOrNull(
          data: (taskList) =>
              _parseHexColor(taskList.visualTheme.secondaryColor, fallbackColor),
        ) ??
        fallbackColor;

    final result = await showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        taskListId: widget.taskListId,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );
    if (result == true && mounted) {
      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
    }
  }
}

/// Tema-farvet opgavekort - kompakt design med gradient-accent
class _ThemedTaskCard extends ConsumerWidget {
  final TaskResponse task;
  final int taskListId;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  const _ThemedTaskCard({
    required this.task,
    required this.taskListId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardColor = isDark
        ? const Color(0xFF222226)
        : const Color(0xFFFFFFFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
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
              // Gradient accent border i toppen
              _buildThemeAccent(),
              // Kompakt indhold
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cirkulær thumbnail med billede eller ikon
                    _buildThumbnail(context),
                    const SizedBox(width: 14),
                    // Titel, beskrivelse og metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titel og menu
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  task.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                    color: isDark
                                        ? const Color(0xFFF5F5F5)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              _buildPopupMenu(context, ref),
                            ],
                          ),
                          // Beskrivelse
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
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
                          const SizedBox(height: 10),
                          // Metadata chips
                          _buildMetadataRow(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bygger gradient accent i toppen af kortet
  Widget _buildThemeAccent() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  /// Bygger cirkulær thumbnail med billede eller tema-farvet ikon
  Widget _buildThumbnail(BuildContext context) {
    final hasImage =
        task.taskImagePath != null && task.taskImagePath!.isNotEmpty;
    final size = 52.0;

    // Lysere baggrund baseret på tema farve
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.85) ??
        primaryColor.withValues(alpha: 0.15);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: ApiConfig.getImageUrl(task.taskImagePath!),
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildThumbnailPlaceholder(),
              errorWidget: (context, url, error) => _buildThumbnailPlaceholder(),
            )
          : _buildThumbnailPlaceholder(),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Center(
      child: Icon(
        Icons.check_circle_outline,
        color: primaryColor.withValues(alpha: 0.6),
        size: 26,
      ),
    );
  }

  /// Bygger metadata række med tema-farvede chips
  Widget _buildMetadataRow(BuildContext context) {
    final strings = AppStrings.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Schedule chip
        _buildThemedChip(
          icon: Icons.repeat_rounded,
          label: _formatSchedule(task.schedule),
        ),
        // Streak chip hvis aktiv
        if (task.currentStreak != null && task.currentStreak!.streakCount > 0)
          _buildThemedChip(
            icon: Icons.local_fire_department,
            label: strings.streakCount(task.currentStreak!.streakCount),
            isHighlight: true,
          ),
        // Completions chip
        if (task.totalCompletions > 0)
          _buildThemedChip(
            icon: Icons.check_circle_outline,
            label: '${task.totalCompletions}x',
          ),
      ],
    );
  }

  /// Bygger tema-farvet chip
  Widget _buildThemedChip({
    required IconData icon,
    required String label,
    bool isHighlight = false,
  }) {
    final chipColor = isHighlight ? secondaryColor : primaryColor;
    final bgAlpha = isDark ? 0.20 : 0.12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
        size: 20,
      ),
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
      interval: (unit, delta, description, activeMonths) => description,
      weeklyPattern: (weeks, days, description, activeMonths) => description,
    );
  }

  void _navigateToTaskHistory(BuildContext context) {
    context.push(
      '/lists/$taskListId/tasks/${task.id}?name=${Uri.encodeComponent(task.name)}',
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
      builder: (context) => EditTaskDialog(
        task: task,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
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
      buildMessage: (deletionContext) => _buildDeletionMessage(deletionContext, strings),
      deleteButtonLabel: strings.delete,
      cancelButtonLabel: strings.cancel,
    );
  }

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

  String _buildDeletionMessage(DeletionContext deletionContext, AppStrings strings) {
    if (deletionContext.isSafe) {
      return strings.taskSafeToDelete;
    }

    if (deletionContext.hasActiveStreak && deletionContext.streakCount != null) {
      return strings.taskDeletionWithStreak(deletionContext.streakCount!, deletionContext.primaryCount);
    }

    if (deletionContext.primaryCount > 0) {
      return strings.taskDeletionWithCompletions(deletionContext.primaryCount);
    }

    return strings.taskWillBeDeleted;
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
