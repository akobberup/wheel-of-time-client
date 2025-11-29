import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/task_instance_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../widgets/complete_task_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/task_completion_animation.dart';
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
  ConsumerState<UpcomingTasksScreen> createState() => _UpcomingTasksScreenState();
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(upcomingTasksProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingTasksProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(upcomingTasksProvider.notifier).refresh(),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UpcomingTasksState state) {
    final strings = AppStrings.of(context);

    if (state.isLoading && state.occurrences.isEmpty) {
      return const SkeletonListLoader();
    }

    if (state.error != null && state.occurrences.isEmpty) {
      return _buildErrorState(strings, state.error!);
    }

    if (state.occurrences.isEmpty) {
      return EmptyState(
        title: strings.noUpcomingTasks,
        subtitle: strings.allCaughtUpWithTasks,
      );
    }

    return _buildTaskList(state);
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

  Widget _buildTaskList(UpcomingTasksState state) {
    final strings = AppStrings.of(context);
    final grouped = _groupByDate(state.occurrences, strings);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = _getColumnCount(width);
        final isDesktop = width >= 900;

        // Beregn responsiv padding baseret på skærmbredde
        final horizontalPadding = _getResponsivePadding(width);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              sliver: SliverMainAxisGroup(
                slivers: _buildResponsiveSlivers(grouped, strings, columnCount, isDesktop),
              ),
            ),
            if (state.hasMore)
              SliverToBoxAdapter(
                child: _buildLoadingIndicator(state.isLoadingMore),
              ),
          ],
        );
      },
    );
  }

  /// Beregner responsiv horisontal padding baseret på skærmbredde
  double _getResponsivePadding(double width) {
    if (width >= 1800) return 80.0;
    if (width >= 1400) return 48.0;
    if (width >= 1200) return 32.0;
    if (width >= 900) return 24.0;
    return 16.0;
  }

  /// Returnerer antal kolonner baseret på skærmbredde
  /// Optimeret til at udnytte desktop-plads bedre
  int _getColumnCount(double width) {
    if (width >= 1800) return 4;  // Meget bred skærm
    if (width >= 1400) return 3;  // Bred desktop
    if (width >= 1000) return 3;  // Standard desktop
    if (width >= 700) return 2;   // Tablet/smal desktop
    return 1;                      // Mobil
  }

  /// Bygger responsive slivers med sektioner og grid layouts
  List<Widget> _buildResponsiveSlivers(
    Map<String, List<UpcomingTaskOccurrenceResponse>> grouped,
    AppStrings strings,
    int columnCount,
    bool isDesktop,
  ) {
    final List<Widget> slivers = [];
    final sectionOrder = [
      strings.overdue,
      strings.dueToday,
      strings.dueTomorrow,
      strings.thisWeek,
      strings.later,
    ];

    for (final section in sectionOrder) {
      final tasks = grouped[section];
      if (tasks != null && tasks.isNotEmpty) {
        final color = _getSectionColor(section, strings);

        // Sektionsoverskrift (altid fuld bredde)
        slivers.add(
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: section,
              accentColor: color,
              taskCount: tasks.length,
              isDesktop: isDesktop,
            ),
          ),
        );

        // Opgaver i grid eller liste baseret på kolonneantal
        if (columnCount == 1) {
          // Mobil: enkelt kolonne liste
          slivers.add(
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TaskOccurrenceCard(
                  occurrence: tasks[index],
                  onQuickComplete: _handleQuickComplete,
                  onTap: _handleTaskCompletion,
                  isDesktop: false,
                ),
                childCount: tasks.length,
              ),
            ),
          );
        } else {
          // Desktop/tablet: grid layout med forbedret spacing
          final crossAxisSpacing = isDesktop ? 16.0 : 12.0;
          final mainAxisSpacing = isDesktop ? 12.0 : 8.0;

          slivers.add(
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                // Dynamisk aspect ratio baseret på opgavetype og skærm
                childAspectRatio: _getAspectRatio(section, strings, columnCount, isDesktop),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => TaskOccurrenceCard(
                  occurrence: tasks[index],
                  onQuickComplete: _handleQuickComplete,
                  onTap: _handleTaskCompletion,
                  isDesktop: isDesktop,
                ),
                childCount: tasks.length,
              ),
            ),
          );
        }
      }
    }

    return slivers;
  }

  /// Returnerer aspect ratio baseret på sektionstype, kolonneantal og skærmstørrelse
  /// Optimeret til at give kortene en passende størrelse på alle skærme
  double _getAspectRatio(String section, AppStrings strings, int columnCount, bool isDesktop) {
    final isHero = section == strings.overdue || section == strings.dueToday;
    final isMedium = section == strings.dueTomorrow || section == strings.thisWeek;

    // Hero-kort (overdue/today) - større og mere fremtrædende
    if (isHero) {
      if (columnCount >= 4) return 1.3;   // 4 kolonner: lidt bredere
      if (columnCount >= 3) return 1.15;  // 3 kolonner: næsten kvadratisk
      return 1.0;                          // 2 kolonner: kvadratisk
    }

    // Medium-kort (tomorrow/this week)
    if (isMedium) {
      if (columnCount >= 4) return 2.2;   // 4 kolonner: kompakt
      if (columnCount >= 3) return 1.8;   // 3 kolonner: medium bredde
      return 2.0;                          // 2 kolonner: standard
    }

    // Kompakte kort (later) - smallere på desktop for at vise flere
    if (columnCount >= 4) return 2.8;
    if (columnCount >= 3) return 2.4;
    return 2.6;
  }

  /// Returnerer farve for en sektion baseret på urgency
  Color _getSectionColor(String section, AppStrings strings) {
    final colorScheme = Theme.of(context).colorScheme;
    if (section == strings.overdue) return colorScheme.error;
    if (section == strings.dueToday) return colorScheme.tertiary;
    if (section == strings.dueTomorrow) return colorScheme.primary;
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
  Future<void> _handleQuickComplete(UpcomingTaskOccurrenceResponse occurrence) async {
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
    final isUrgent = accentColor == theme.colorScheme.error ||
        accentColor == theme.colorScheme.tertiary;

    // Større tekst og spacing på desktop
    final titleStyle = isDesktop
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isUrgent ? accentColor : theme.colorScheme.onSurface,
          )
        : theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isUrgent ? accentColor : theme.colorScheme.onSurface,
          );

    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 24 : 16,
        bottom: isDesktop ? 12 : 8,
      ),
      child: Row(
        children: [
          // Farvet accent-linje
          Container(
            width: isDesktop ? 5 : 4,
            height: isDesktop ? 28 : 24,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          // Sektions-titel
          Text(
            title,
            style: titleStyle,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          // Opgave-antal badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 10 : 8,
              vertical: isDesktop ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$taskCount',
              style: (isDesktop ? theme.textTheme.labelMedium : theme.textTheme.labelSmall)?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Pulserende indikator for hastende sektioner
          if (isUrgent) ...[
            SizedBox(width: isDesktop ? 12 : 8),
            _PulsingDot(color: accentColor),
          ],
        ],
      ),
    );
  }
}

/// Prik til at indikere hastende opgaver
class _PulsingDot extends StatelessWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
