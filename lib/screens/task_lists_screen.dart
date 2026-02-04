// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_list_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/invitation_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';
import '../models/task_list.dart';
import '../widgets/create_task_list_dialog.dart';
import '../widgets/create_from_template_dialog.dart';
import '../widgets/edit_task_list_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state_widget.dart';
import '../widgets/common/contextual_delete_dialog.dart';
import '../widgets/common/inline_action_buttons.dart';

/// Viser liste over brugerens opgavelister med mulighed for at oprette, redigere og slette
class TaskListsScreen extends ConsumerStatefulWidget {
  const TaskListsScreen({super.key});

  @override
  ConsumerState<TaskListsScreen> createState() => _TaskListsScreenState();
}

class _TaskListsScreenState extends ConsumerState<TaskListsScreen> {
  // Flag til at spore om vi allerede har vist create-dialogen
  bool _hasShownCreateDialog = false;

  @override
  Widget build(BuildContext context) {
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
    // Onboarding: Åbn create-dialog automatisk hvis ingen lister findes
    // Spring over hvis brugeren har ventende invitationer - de skal håndtere dem først
    final hasPendingInvitations = ref.watch(invitationProvider).valueOrNull?.isNotEmpty ?? false;
    if (taskLists.isEmpty && !_hasShownCreateDialog && !hasPendingInvitations) {
      _hasShownCreateDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboardingCreateDialog(context, ref);
      });
    }

    if (taskLists.isEmpty) {
      return _buildEmptyState(strings, context, ref);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Begræns bredden på desktop for bedre læsbarhed og proportioner
        const maxContentWidth = 700.0;
        final isWideScreen = constraints.maxWidth > maxContentWidth;
        final horizontalPadding =
            isWideScreen ? (constraints.maxWidth - maxContentWidth) / 2 : 24.0;

        return CustomScrollView(
          slivers: [
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

  /// Viser onboarding skabelon-dialog og navigerer til den nye liste
  Future<void> _showOnboardingCreateDialog(
      BuildContext context, WidgetRef ref) async {
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CreateFromTemplateDialog(),
    );

    if (!mounted) return;

    // Bruger valgte "Opret manuelt"
    if (result is OpenManualCreateMarker) {
      final manualResult = await showDialog<TaskListResponse>(
        context: context,
        builder: (context) => const CreateTaskListDialog(),
      );
      if (manualResult != null && mounted) {
        context.push(
          '/lists/${manualResult.id}?name=${Uri.encodeComponent(manualResult.name)}',
        );
      }
      return;
    }

    // Bruger valgte en skabelon og listen blev oprettet
    if (result is TaskListResponse) {
      context.push(
        '/lists/${result.id}?name=${Uri.encodeComponent(result.name)}',
      );
    }
  }

  Future<void> _handleCreateTaskList(
      BuildContext context, WidgetRef ref) async {
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CreateFromTemplateDialog(),
    );

    if (!mounted) return;

    // Bruger valgte "Opret manuelt"
    if (result is OpenManualCreateMarker) {
      final manualResult = await showDialog<TaskListResponse>(
        context: context,
        builder: (context) => const CreateTaskListDialog(),
      );
      if (manualResult != null && mounted) {
        context.push(
          '/lists/${manualResult.id}?name=${Uri.encodeComponent(manualResult.name)}',
        );
      }
      return;
    }

    // Bruger valgte en skabelon og listen blev oprettet
    if (result is TaskListResponse) {
      context.push(
        '/lists/${result.id}?name=${Uri.encodeComponent(result.name)}',
      );
    }
  }
}

/// Kort der viser en enkelt opgaveliste med hero-billede, fremskridtsindikator og medlemmer
class _TaskListCard extends ConsumerWidget {
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
              // Subtil farvet top border som tema accent
              _buildThemeAccent(context, isDark),
              // Hovedindhold
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel
                    Text(
                      taskList.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    // Tema display name med ikon
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 14,
                          color: _parseHexColor(taskList.visualTheme.primaryColor),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          taskList.visualTheme.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _parseHexColor(taskList.visualTheme.primaryColor),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Beskrivelse
                    if (taskList.description != null) ...[
                      const SizedBox(height: 8),
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
                    // Statistik række med inline action buttons
                    _buildStatsRow(context, ref, strings, themeState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bygger en subtil farvet border/accent baseret på tema farver
  Widget _buildThemeAccent(BuildContext context, bool isDark) {
    // Parse hex farver fra tema
    final primaryColor = _parseHexColor(taskList.visualTheme.primaryColor);
    
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            _parseHexColor(taskList.visualTheme.secondaryColor),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  /// Parser hex color string (f.eks. "#A8D5A2") til Color objekt
  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('FF'); // Tilføj alpha hvis ikke angivet
      buffer.write(hexString.replaceFirst('#', ''));
    } else if (hexString.length == 9) {
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      // Fallback til grå hvis format er ugyldigt
      return Colors.grey;
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Bygger statistik række med fremskridtsindikator, medlemmer og inline action buttons
  Widget _buildStatsRow(
      BuildContext context, WidgetRef ref, AppStrings strings, ThemeState themeState) {
    final isDark = themeState.isDarkMode;
    final primaryTextColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A);
    final secondaryTextColor =
        isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);

    // Brug tema farver til fremskridtsindikator
    final themeColor = _parseHexColor(taskList.visualTheme.primaryColor);

    return Row(
      children: [
        // Cirkulær fremskridtsindikator med tema farve
        _buildProgressIndicator(themeColor, isDark),
        const SizedBox(width: 12),
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

        // Inline action buttons
        InlineActionButtons(
          onEdit: () => _handleEdit(context, ref),
          onShare: () => _handleShare(context),
          onDelete: () => _handleDelete(context, ref, strings),
          themeColor: themeColor,
          isDark: isDark,
          itemName: taskList.name,
          editLabel: strings.edit,
          shareLabel: strings.members,
          deleteLabel: strings.delete,
        ),
      ],
    );
  }
  
  /// Bygger en cirkulær fremskridtsindikator med tema farve
  Widget _buildProgressIndicator(Color themeColor, bool isDark) {
    final total = taskList.taskCount as int;
    final completed = taskList.activeTaskCount as int;
    final progress = total > 0 ? completed / total : 0.0;
    
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          // Baggrundscirkel
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          // Fremskridt med tema farve
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
          // Ikon i midten
          Center(
            child: Icon(
              Icons.task_alt,
              size: 18,
              color: progress == 1.0 
                ? themeColor 
                : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  /// Returnerer progress tekst baseret på fuldførelsesprocent
  String _getProgressText(AppStrings strings) {
    final total = taskList.taskCount as int;
    final completed = taskList.activeTaskCount as int;

    if (total == 0) return strings.noTasks;

    final percent = total > 0 ? ((completed / total) * 100).round() : 0;
    return strings.percentComplete(percent);
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

  /// Navigerer til medlemmer-skærmen for denne opgaveliste
  void _handleShare(BuildContext context) {
    final primaryColor = _parseHexColor(taskList.visualTheme.primaryColor);
    final secondaryColor = _parseHexColor(taskList.visualTheme.secondaryColor);
    final primaryHex = '#${primaryColor.value.toRadixString(16).substring(2)}';
    final secondaryHex = '#${secondaryColor.value.toRadixString(16).substring(2)}';

    context.push(
      '/lists/${taskList.id}/members?name=${Uri.encodeComponent(taskList.name)}&primaryColor=${Uri.encodeComponent(primaryHex)}&secondaryColor=${Uri.encodeComponent(secondaryHex)}',
    );
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
      return strings.taskListSafeToDelete;
    }

    return strings.taskListDeletionSummary(
      context.primaryCount,
      context.secondaryCount ?? 0,
      context.tertiaryCount ?? 0,
    );
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
    context.push(
      '/lists/${taskList.id}?name=${Uri.encodeComponent(taskList.name)}',
    );
  }
}
