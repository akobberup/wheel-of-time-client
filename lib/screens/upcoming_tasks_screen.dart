// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/completed_tasks_provider.dart';
import '../providers/task_instance_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../widgets/complete_task_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/task_completion_animation.dart';
import '../widgets/common/timeline_separator.dart';
import '../widgets/task_cards/task_cards.dart';

/// Grupperer opgaver efter dato-sektion
Map<String, List<UpcomingTaskOccurrenceResponse>> _groupByDate(
  List<UpcomingTaskOccurrenceResponse> occurrences,
  AppStrings strings,
) {
  final Map<String, List<UpcomingTaskOccurrenceResponse>> grouped = {};

  for (final occurrence in occurrences) {
    final urgency = getTaskUrgency(occurrence.dueDate);
    final key = switch (urgency) {
      TaskUrgency.overdue => strings.overdue,
      TaskUrgency.today => strings.dueToday,
      TaskUrgency.tomorrow => strings.dueTomorrow,
      TaskUrgency.thisWeek => strings.thisWeek,
      TaskUrgency.future => strings.later,
    };

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(occurrence);
  }

  return grouped;
}

/// Skærm der viser kommende opgaver med uendelig scroll-paginering
class UpcomingTasksScreen extends ConsumerStatefulWidget {
  const UpcomingTasksScreen({super.key});

  @override
  ConsumerState<UpcomingTasksScreen> createState() =>
      _UpcomingTasksScreenState();
}

class _UpcomingTasksScreenState extends ConsumerState<UpcomingTasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Registrerer når bruger scroller tæt på bunden og indlæser mere data
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(upcomingTasksProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingTasksProvider);
    final completedState = ref.watch(completedTasksProvider);
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    // Brugerens valgte tema-farve
    final seedColor = themeState.seedColor;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(upcomingTasksProvider.notifier).refresh(),
            ref.read(completedTasksProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Body content
            SliverToBoxAdapter(
              child: _buildBody(context, state, completedState),
            ),
            // Loading indicator ved bunden
            if (state.hasMore)
              SliverToBoxAdapter(
                child: _buildLoadingIndicator(state.isLoadingMore),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UpcomingTasksState state,
    CompletedTasksState completedState,
  ) {
    final strings = AppStrings.of(context);

    if (state.isLoading && state.occurrences.isEmpty) {
      return const SizedBox(
        height: 400,
        child: SkeletonListLoader(),
      );
    }

    if (state.error != null && state.occurrences.isEmpty) {
      return SizedBox(
        height: 400,
        child: _buildErrorState(strings, state.error!),
      );
    }

    // Vis empty state kun hvis ingen upcoming OG ingen completed
    if (state.occurrences.isEmpty &&
        completedState.completedTasks.isEmpty &&
        !completedState.isExpanded) {
      return SizedBox(
        height: 400,
        child: EmptyState(
          title: strings.noUpcomingTasks,
          subtitle: strings.allCaughtUpWithTasks,
        ),
      );
    }

    return _buildTaskList(state, completedState);
  }

  Widget _buildErrorState(AppStrings strings, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            '${strings.error}: $error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(upcomingTasksProvider.notifier).refresh(),
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    UpcomingTasksState state,
    CompletedTasksState completedState,
  ) {
    final strings = AppStrings.of(context);
    final grouped = _groupByDate(state.occurrences, strings);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = _getColumnCount(width);
        final isDesktop = width >= 900;

        // Beregn responsiv padding baseret på skærmbredde
        final horizontalPadding = _getResponsivePadding(width);

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Completed tasks section (collapsible)
                  _CompletedTasksSection(
                    completedState: completedState,
                    isDesktop: isDesktop,
                    onToggleExpand: () {
                      ref
                          .read(completedTasksProvider.notifier)
                          .toggleExpanded();
                    },
                    onLoadMore: () {
                      ref.read(completedTasksProvider.notifier).loadMore();
                    },
                  ),
                  // Timeline separator (NOW marker)
                  if (completedState.completedTasks.isNotEmpty ||
                      completedState.isExpanded)
                    TimelineSeparator(isDesktop: isDesktop),
                  // Upcoming tasks
                  ..._buildResponsiveContent(
                      grouped, strings, columnCount, isDesktop),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Beregner responsiv horisontal padding baseret på skærmbredde
  /// Begrænser indholdsbredden til maxContentWidth for bedre læsbarhed
  double _getResponsivePadding(double width) {
    const maxContentWidth = 800.0;
    if (width > maxContentWidth) {
      // Centrer indholdet med lige meget padding på begge sider
      return (width - maxContentWidth) / 2;
    }
    return 16.0;
  }

  /// Returnerer antal kolonner - altid 1 for konsistens med andre skærme
  int _getColumnCount(double width) {
    return 1;
  }

  /// Bygger responsive widgets med sektioner og grid layouts
  List<Widget> _buildResponsiveContent(
    Map<String, List<UpcomingTaskOccurrenceResponse>> grouped,
    AppStrings strings,
    int columnCount,
    bool isDesktop,
  ) {
    final List<Widget> widgets = [];
    final sectionOrder = [
      strings.overdue,
      strings.dueToday,
      strings.dueTomorrow,
      strings.thisWeek,
      strings.later,
    ];

    final state = ref.watch(upcomingTasksProvider);

    for (final section in sectionOrder) {
      final tasks = grouped[section];
      if (tasks != null && tasks.isNotEmpty) {
        final color = _getSectionColor(section, strings);
        final isLaterSection = section == strings.later;

        // Bestem hvor mange opgaver der skal vises i "Senere" sektionen
        final tasksToShow = isLaterSection && !state.isLaterExpanded
            ? tasks.take(5).toList()
            : tasks;
        final hasMoreToShow =
            isLaterSection && tasks.length > 5 && !state.isLaterExpanded;

        // Sektionsoverskrift
        widgets.add(
          _SectionHeader(
            title: section,
            accentColor: color,
            taskCount: tasks.length,
            isDesktop: isDesktop,
          ),
        );

        // Opgaver i grid eller liste baseret på kolonneantal
        if (columnCount == 1) {
          // Mobil: enkelt kolonne liste
          for (final task in tasksToShow) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskOccurrenceCard(
                  occurrence: task,
                  onQuickComplete: _handleQuickComplete,
                  onTap: _handleTaskCompletion,
                  isDesktop: false,
                ),
              ),
            );
          }
        } else {
          // Desktop/tablet: grid layout med forbedret spacing
          final crossAxisSpacing = isDesktop ? 16.0 : 12.0;
          final mainAxisSpacing = isDesktop ? 12.0 : 8.0;

          widgets.add(
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio:
                    _getAspectRatio(section, strings, columnCount, isDesktop),
              ),
              itemCount: tasksToShow.length,
              itemBuilder: (context, index) => TaskOccurrenceCard(
                occurrence: tasksToShow[index],
                onQuickComplete: _handleQuickComplete,
                onTap: _handleTaskCompletion,
                isDesktop: isDesktop,
              ),
            ),
          );
        }

        // Vis "Se alle" knap for "Senere" sektionen hvis der er flere opgaver
        if (hasMoreToShow) {
          widgets.add(
            _ExpandLaterButton(
              remainingCount: tasks.length - 5,
              isDesktop: isDesktop,
              onTap: () => ref
                  .read(upcomingTasksProvider.notifier)
                  .toggleLaterExpanded(),
            ),
          );
        }

        // Vis "Vis færre" knap hvis sektionen er udvidet
        if (isLaterSection && state.isLaterExpanded && tasks.length > 5) {
          widgets.add(
            _CollapseLaterButton(
              isDesktop: isDesktop,
              onTap: () => ref
                  .read(upcomingTasksProvider.notifier)
                  .toggleLaterExpanded(),
            ),
          );
        }
      }
    }

    return widgets;
  }

  /// Returnerer aspect ratio baseret på sektionstype, kolonneantal og skærmstørrelse
  /// Optimeret til at give kortene en passende størrelse på alle skærme
  /// OBS: Hero-kort ratio matcher HeroTaskCard's interne AspectRatio (2.5 desktop, 1.8 mobil)
  double _getAspectRatio(
      String section, AppStrings strings, int columnCount, bool isDesktop) {
    final isHero = section == strings.overdue || section == strings.dueToday;
    final isMedium =
        section == strings.dueTomorrow || section == strings.thisWeek;

    // Hero-kort (overdue/today) - matcher HeroTaskCard's AspectRatio
    if (isHero) {
      // Desktop aspect ratio ~2.5, med lidt variation for kolonneantal
      if (columnCount >= 4) return 2.3; // 4 kolonner: lidt smallere
      if (columnCount >= 3) return 2.5; // 3 kolonner: standard desktop
      return 2.2; // 2 kolonner: lidt smallere
    }

    // Medium-kort (tomorrow/this week)
    if (isMedium) {
      if (columnCount >= 4) return 3.0; // 4 kolonner: kompakt
      if (columnCount >= 3) return 2.5; // 3 kolonner: medium bredde
      return 2.2; // 2 kolonner: standard
    }

    // Kompakte kort (later) - smallere på desktop for at vise flere
    if (columnCount >= 4) return 4.0;
    if (columnCount >= 3) return 3.5;
    return 3.0;
  }

  /// Returnerer farve for en sektion baseret på urgency
  /// Bruger brugerens valgte tema-farve for relevante sektioner
  Color _getSectionColor(String section, AppStrings strings) {
    final themeState = ref.read(themeProvider);
    final seedColor = themeState.seedColor;
    final colorScheme = Theme.of(context).colorScheme;

    if (section == strings.overdue)
      return const Color(0xFFEF4444); // Status farve: Fejl
    if (section == strings.dueToday)
      return const Color(0xFFF59E0B); // Status farve: Advarsel
    if (section == strings.dueTomorrow)
      return seedColor; // Brugerens tema-farve
    if (section == strings.thisWeek) return seedColor.withValues(alpha: 0.7);
    return colorScheme.onSurfaceVariant;
  }

  Widget _buildLoadingIndicator(bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Hurtig fuldførelse med nuværende tidsstempel (til swipe-handling)
  Future<void> _handleQuickComplete(
      UpcomingTaskOccurrenceResponse occurrence) async {
    final request = CreateTaskInstanceRequest(
      taskId: occurrence.taskId,
      completedDateTime: DateTime.now(),
      optionalComment: null,
    );

    final result = await ref
        .read(taskInstancesProvider(occurrence.taskId).notifier)
        .createTaskInstance(request);

    if (result != null && mounted) {
      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
      );

      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }

  /// Håndterer opgavefuldførelse og viser passende succesbesked
  Future<void> _handleTaskCompletion(
    BuildContext context,
    UpcomingTaskOccurrenceResponse occurrence,
  ) async {
    HapticFeedback.mediumImpact();
    final dialogResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CompleteTaskDialog(
        taskId: occurrence.taskId,
        taskName: occurrence.taskName,
        currentStreak: occurrence.currentStreak,
        taskImagePath: occurrence.taskImagePath,
        taskListPrimaryColor: occurrence.taskListPrimaryColor,
        taskListSecondaryColor: occurrence.taskListSecondaryColor,
      ),
    );

    if (dialogResult != null && context.mounted) {
      final result = dialogResult['result'] as TaskInstanceResponse;
      final completionMessage = dialogResult['message'] as String?;

      final newStreakCount = result.contributedToStreak
          ? (occurrence.currentStreak?.streakCount ?? 0) + 1
          : null;

      await TaskCompletionAnimation.show(
        context: context,
        streakCount: newStreakCount,
        completionMessage: completionMessage,
      );

      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }
}

/// Sektionsoverskrift med titel, farveaccent og opgaveantal
/// Design: Varm, organisk æstetik med bløde former og tema-farver
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final int taskCount;
  final bool isDesktop;

  const _SectionHeader({
    required this.title,
    required this.accentColor,
    required this.taskCount,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tjek om det er en hastende sektion (overdue eller today)
    final isUrgent = accentColor == const Color(0xFFEF4444) ||
        accentColor == const Color(0xFFF59E0B);

    // Typografi følger design guidelines (H2: 22px, vægt 600)
    final titleStyle = TextStyle(
      fontSize: isDesktop ? 22 : 18,
      fontWeight: FontWeight.w600,
      color: accentColor,
      letterSpacing: -0.3,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 32 : 24, // Spacing: lg-xl mellem sektioner
        bottom: isDesktop ? 16 : 12,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 14 : 12,
        ),
        decoration: BoxDecoration(
          // Blødt kort med borderRadius: 16px (Design Guidelines)
          borderRadius: BorderRadius.circular(16),
          // Varm baggrund der passer til tema
          color: isDark
              ? const Color(0xFF222226) // Overflade (cards) - mørk
              : const Color(0xFFFFFFFF), // Overflade (cards) - lys
          // Subtil skygge (Niveau 1: subtle)
          boxShadow: isDark
              ? null // Ingen skygger i mørk tilstand
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          // Subtil border i mørk tilstand
          border: isDark
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Cirkulært ikon-element (reference til "hjulet")
            Container(
              width: isDesktop ? 36 : 32,
              height: isDesktop ? 36 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isUrgent ? Icons.priority_high : Icons.calendar_today,
                size: isDesktop ? 18 : 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            // Sektions-titel
            Expanded(
              child: Text(
                title,
                style: titleStyle,
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 8),
            // Opgave-antal badge med bløde kanter
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 12 : 10,
                vertical: isDesktop ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(8), // Border radius: 8px for badges
              ),
              child: Text(
                '$taskCount',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Knap til at udvide "Senere" sektionen
/// Design: Varm, indbydende knap der matcher den organiske æstetik
class _ExpandLaterButton extends ConsumerWidget {
  final int remainingCount;
  final bool isDesktop;
  final VoidCallback onTap;

  const _ExpandLaterButton({
    required this.remainingCount,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeState = ref.watch(themeProvider);
    final seedColor = themeState.seedColor;
    final strings = AppStrings.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 16 : 12,
        bottom: isDesktop ? 8 : 6,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 20,
            vertical: isDesktop ? 16 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Subtil gradient baggrund med tema-farve
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                seedColor.withValues(alpha: 0.08),
                seedColor.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: seedColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            // Subtil skygge
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: seedColor.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Expand ikon
              Icon(
                Icons.expand_more,
                color: seedColor,
                size: isDesktop ? 24 : 22,
              ),
              SizedBox(width: isDesktop ? 12 : 10),
              // Tekst
              Text(
                '${strings.showMore} ($remainingCount ${strings.tasks.toLowerCase()})',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: seedColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Knap til at kollapse "Senere" sektionen
/// Design: Diskret, mindre fremtrædende end expand-knappen
class _CollapseLaterButton extends ConsumerWidget {
  final bool isDesktop;
  final VoidCallback onTap;

  const _CollapseLaterButton({
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final seedColor = themeState.seedColor;
    final strings = AppStrings.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 12 : 8,
        bottom: isDesktop ? 8 : 6,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 12 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Mere diskret farve
            color: seedColor.withValues(alpha: 0.05),
            border: Border.all(
              color: seedColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Collapse ikon
              Icon(
                Icons.expand_less,
                color: seedColor.withValues(alpha: 0.7),
                size: isDesktop ? 22 : 20,
              ),
              SizedBox(width: isDesktop ? 8 : 6),
              // Tekst
              Text(
                strings.showLess,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.w500,
                  color: seedColor.withValues(alpha: 0.7),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collapsible section for recently completed tasks
/// Design: Success-farve accent, celebration ikon, kollapsibel
class _CompletedTasksSection extends StatelessWidget {
  final CompletedTasksState completedState;
  final bool isDesktop;
  final VoidCallback onToggleExpand;
  final VoidCallback onLoadMore;

  // Status farve fra Design Guidelines
  static const Color _successColor = Color(0xFF22C55E);

  const _CompletedTasksSection({
    required this.completedState,
    required this.isDesktop,
    required this.onToggleExpand,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Column(
      children: [
        // Header (altid synlig)
        _buildHeader(context, isDark, strings),
        // Expanded content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedContent(context, strings),
          crossFadeState: completedState.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppStrings strings) {
    final taskCount = completedState.completedTasks.length;
    final colorScheme = Theme.of(context).colorScheme;
    // Use primary color (user's theme color) for neutral header
    final accentColor = colorScheme.primary;

    return GestureDetector(
      onTap: onToggleExpand,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 14 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? const Color(0xFF222226) // Neutral mørk
              : const Color(0xFFFFFFFF), // Neutral lys
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // History/timeline ikon
            Container(
              width: isDesktop ? 36 : 32,
              height: isDesktop ? 36 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.history,
                size: isDesktop ? 18 : 16,
                color: accentColor,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),
            // Titel og count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.recentActivity,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (taskCount > 0)
                    Text(
                      strings.tasksCompletedCount(taskCount),
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // Expand/collapse indikator
            AnimatedRotation(
              turns: completedState.isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: accentColor,
                size: isDesktop ? 28 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, AppStrings strings) {
    if (completedState.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (completedState.completedTasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 16),
        child: Center(
          child: Text(
            strings.noCompletionsYet,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: isDesktop ? 12 : 8),
        // Lista af completed tasks
        ...completedState.completedTasks.map(
          (task) => Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 6 : 4),
            child: CompletedTaskCard(
              taskInstance: task,
              isDesktop: isDesktop,
            ),
          ),
        ),
        // Load more button
        if (completedState.hasMore && !completedState.isLoadingMore)
          Padding(
            padding: EdgeInsets.only(top: isDesktop ? 8 : 6),
            child: TextButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text(strings.showMore),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        // Loading more indicator
        if (completedState.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}
