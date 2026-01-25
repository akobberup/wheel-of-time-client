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
import '../widgets/create_task_from_template_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../widgets/common/inline_action_buttons.dart';
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
  /// Viser den nye "Opret fra skabelon" dialog med AI-forslag
  Future<void> _showOnboardingCreateTaskDialog(
    Color primaryColor,
    Color secondaryColor,
  ) async {
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CreateTaskFromTemplateDialog(
        taskListId: widget.taskListId,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );

    if (!mounted) return;

    // Bruger valgte "Opret manuelt" - åbn tom CreateTaskDialog
    if (result is OpenManualTaskCreateMarker) {
      final manualResult = await showDialog<bool>(
        context: context,
        builder: (context) => CreateTaskDialog(
          taskListId: widget.taskListId,
          themeColor: primaryColor,
          secondaryThemeColor: secondaryColor,
        ),
      );
      if (manualResult == true && mounted) {
        ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
      }
      return;
    }

    // Bruger valgte "Rediger" på et forslag - åbn CreateTaskDialog med præudfyldt data
    if (result is EditTaskSuggestionMarker) {
      final editResult = await showDialog<bool>(
        context: context,
        builder: (context) => CreateTaskDialog(
          taskListId: widget.taskListId,
          themeColor: primaryColor,
          secondaryThemeColor: secondaryColor,
          initialSuggestion: result.suggestion,
        ),
      );
      if (editResult == true && mounted) {
        ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
      }
      return;
    }

    // Bruger valgte "Opret" på et forslag - task blev oprettet direkte
    if (result is TaskResponse) {
      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
    }
  }

  Future<void> _handleCreateTask() async {
    final taskListAsync = ref.read(taskListDetailProvider(widget.taskListId));
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

    // Vis "Opret fra skabelon" dialog med AI-forslag
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CreateTaskFromTemplateDialog(
        taskListId: widget.taskListId,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );

    if (!mounted) return;

    // Bruger valgte "Opret manuelt" - åbn tom CreateTaskDialog
    if (result is OpenManualTaskCreateMarker) {
      final manualResult = await showDialog<bool>(
        context: context,
        builder: (context) => CreateTaskDialog(
          taskListId: widget.taskListId,
          themeColor: primaryColor,
          secondaryThemeColor: secondaryColor,
        ),
      );
      if (manualResult == true && mounted) {
        ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
      }
      return;
    }

    // Bruger valgte "Rediger" på et forslag - åbn CreateTaskDialog med præudfyldt data
    if (result is EditTaskSuggestionMarker) {
      final editResult = await showDialog<bool>(
        context: context,
        builder: (context) => CreateTaskDialog(
          taskListId: widget.taskListId,
          themeColor: primaryColor,
          secondaryThemeColor: secondaryColor,
          initialSuggestion: result.suggestion,
        ),
      );
      if (editResult == true && mounted) {
        ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
      }
      return;
    }

    // Bruger valgte "Opret" på et forslag - task blev oprettet direkte
    if (result is TaskResponse) {
      ref.read(tasksProvider(widget.taskListId).notifier).loadTasks();
    }
  }
}

/// Tema-farvet opgavekort - horisontalt layout med stort billede
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
      height: 160, // Fast højde for konsistent layout
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
      clipBehavior: Clip.antiAlias, // Klip indhold til afrundede hjørner
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTaskHistory(context),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient accent border i toppen
              _buildThemeAccent(),
              // Horisontalt layout: billede til venstre, indhold til højre
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stort billede til venstre (ca 1/3 af bredden)
                    _buildLargeImage(context),
                    // Indhold til højre (ca 2/3 af bredden)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titel
                            Text(
                              task.name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? const Color(0xFFF5F5F5)
                                    : const Color(0xFF1A1A1A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Beskrivelse
                            if (task.description != null &&
                                task.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
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
                            const Spacer(),
                            // Metadata chips og inline action buttons
                            _buildMetadataAndActionsRow(context, ref),
                          ],
                        ),
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

  /// Bygger stort billede til venstre side af kortet (ligner hero cards)
  Widget _buildLargeImage(BuildContext context) {
    final hasImage =
        task.taskImagePath != null && task.taskImagePath!.isNotEmpty;

    // Lysere baggrund baseret på tema farve (ligner hero cards)
    final backgroundColor = Color.lerp(primaryColor, Colors.white, 0.7) ??
        primaryColor.withValues(alpha: 0.3);

    return Container(
      width: 140, // Fast bredde for billedsektionen
      decoration: BoxDecoration(
        color: backgroundColor,
        // Ingen afrunding her - kortet håndterer det via clipBehavior
      ),
      child: hasImage
          ? Padding(
              // Padding omkring billedet for "åndehul" (som hero cards)
              padding: const EdgeInsets.all(12),
              child: Container(
                // Kun én container med afrunding og border
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.getImageUrl(task.taskImagePath!),
                  fit: BoxFit.contain, // Bevar billedets proportioner
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) => _buildImagePlaceholder(),
                ),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  /// Placeholder når der ikke er noget billede
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.check_circle_outline,
        color: primaryColor.withValues(alpha: 0.4),
        size: 48,
      ),
    );
  }

  /// Bygger metadata række med tema-farvede chips og inline action buttons
  Widget _buildMetadataAndActionsRow(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Metadata chips (venstre side)
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // Schedule chip
              _buildThemedChip(
                icon: Icons.repeat_rounded,
                label: _formatSchedule(task.schedule),
              ),
              // Streak chip hvis aktiv
              if (task.currentStreak != null &&
                  task.currentStreak!.streakCount > 0)
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
          ),
        ),
        // Inline action buttons (højre side)
        const SizedBox(width: 8),
        InlineActionButtons(
          onEdit: () => _handleEdit(context, ref),
          onDelete: () => _handleDelete(context, ref),
          themeColor: primaryColor,
          isDark: isDark,
          itemName: task.name,
          editLabel: strings.edit,
          deleteLabel: strings.delete,
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

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );
    if (result == true && context.mounted) {
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
