import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/task_instance_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_instance.dart';
import '../widgets/complete_task_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/task_completion_animation.dart';
import '../widgets/common/animated_card.dart';
import '../widgets/common/gradient_background.dart';
import '../config/api_config.dart';

/// Urgency niveauer til visuel differentiering
enum TaskUrgency { overdue, today, tomorrow, thisWeek, future }

/// Bestemmer urgency niveau ud fra forfaldsdato
TaskUrgency _getUrgency(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = taskDate.difference(today).inDays;

  if (difference < 0) return TaskUrgency.overdue;
  if (difference == 0) return TaskUrgency.today;
  if (difference == 1) return TaskUrgency.tomorrow;
  if (difference <= 7) return TaskUrgency.thisWeek;
  return TaskUrgency.future;
}

/// Grupperer opgaver efter dato-sektion
Map<String, List<UpcomingTaskOccurrenceResponse>> _groupByDate(
  List<UpcomingTaskOccurrenceResponse> occurrences,
  AppStrings strings,
) {
  final Map<String, List<UpcomingTaskOccurrenceResponse>> grouped = {};

  for (final occurrence in occurrences) {
    final urgency = _getUrgency(occurrence.dueDate);
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
                (context, index) => _TaskOccurrenceCard(
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
                (context, index) => _TaskOccurrenceCard(
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

/// Kort der viser en enkelt opgaveforekomst med swipe-til-fuldførelse
/// Bruger 3-niveau visuelt hierarki baseret på urgency
class _TaskOccurrenceCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final Future<void> Function(UpcomingTaskOccurrenceResponse) onQuickComplete;
  final Future<void> Function(BuildContext, UpcomingTaskOccurrenceResponse) onTap;
  final bool isDesktop;

  const _TaskOccurrenceCard({
    required this.occurrence,
    required this.onQuickComplete,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = occurrence.isNextOccurrence;
    final urgency = _getUrgency(occurrence.dueDate);

    return Dismissible(
      key: Key(occurrence.occurrenceId),
      direction: isClickable ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (!isClickable) return false;
        await onQuickComplete(occurrence);
        return false;
      },
      background: _buildDismissBackground(urgency),
      child: _buildCardContent(context, isClickable, urgency),
    );
  }

  Widget _buildDismissBackground(TaskUrgency urgency) {
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: EdgeInsets.only(bottom: isUrgent ? 8 : 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Fuldfort!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isClickable, TaskUrgency urgency) {
    // Vælg kort-type baseret på urgency niveau
    final Widget card = switch (urgency) {
      TaskUrgency.overdue || TaskUrgency.today => _HeroTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          urgency: urgency,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
      TaskUrgency.tomorrow || TaskUrgency.thisWeek => _MediumTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          urgency: urgency,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
      TaskUrgency.future => _CompactTaskCard(
          occurrence: occurrence,
          isClickable: isClickable,
          onTap: () => onTap(context, occurrence),
          isDesktop: isDesktop,
        ),
    };

    return Stack(
      children: [
        card,
        if (!isClickable) _FrostedLockedOverlay(urgency: urgency),
      ],
    );
  }
}

/// Hero-kort til overdue og today opgaver - stort, iojnefaldende design med billede
class _HeroTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final TaskUrgency urgency;
  final VoidCallback? onTap;
  final bool isDesktop;

  const _HeroTaskCard({
    required this.occurrence,
    required this.isClickable,
    required this.urgency,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = urgency == TaskUrgency.overdue;
    final accentColor = isOverdue ? colorScheme.error : colorScheme.tertiary;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 6 : 4,
      pressedElevation: isDesktop ? 12 : 8,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 8),
      borderSide: BorderSide(
        color: accentColor.withValues(alpha: 0.5),
        width: 2,
      ),
      borderRadius: isDesktop ? 16 : 20,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Baggrund: billede eller gradient
          _buildBackground(context, accentColor),
          // Gradient overlay for laesbarhed
          _buildGradientOverlay(accentColor),
          // Indhold positioneret i bunden
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildContent(context, accentColor),
          ),
          // Streak badge oeverst til venstre
          if (occurrence.currentStreak != null && occurrence.currentStreak!.isActive)
            Positioned(
              top: isDesktop ? 12 : 16,
              left: isDesktop ? 12 : 16,
              child: _AnimatedStreakBadge(
                streakCount: occurrence.currentStreak!.streakCount,
                isAtRisk: _shouldShowStreakWarning(),
              ),
            ),
          // Urgency indikator
          if (isOverdue) _buildUrgencyBanner(context),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context, Color accentColor) {
    final imagePath = occurrence.taskImagePath;

    if (imagePath != null && imagePath.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ApiConfig.getImageUrl(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => GradientBackground(
          seed: occurrence.taskName,
          height: double.infinity,
        ),
        errorWidget: (context, url, error) => GradientBackground(
          seed: occurrence.taskName,
          height: double.infinity,
        ),
      );
    }

    return GradientBackground(
      seed: occurrence.taskName,
      height: double.infinity,
    );
  }

  Widget _buildGradientOverlay(Color accentColor) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    
    // Responsive padding og font-stoerrelser
    final contentPadding = isDesktop ? 16.0 : 20.0;
    final titleStyle = isDesktop 
        ? theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          )
        : theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.all(contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opgave-liste label
          _buildTaskListLabel(context),
          SizedBox(height: isDesktop ? 6 : 8),
          // Titel
          Text(
            occurrence.taskName,
            style: titleStyle,
            maxLines: isDesktop ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isDesktop ? 8 : 12),
          // Metadata raekke
          Row(
            children: [
              _DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
              SizedBox(width: isDesktop ? 8 : 12),
              if (occurrence.totalCompletions > 0)
                Flexible(
                  child: _MetadataChip(
                    icon: Icons.check_circle_outline,
                    label: strings.timesCompleted(occurrence.totalCompletions),
                    small: isDesktop,
                  ),
                ),
            ],
          ),
          // Streak advarsel hvis relevant
          if (_shouldShowStreakWarning())
            Padding(
              padding: EdgeInsets.only(top: isDesktop ? 8 : 12),
              child: _StreakWarningBanner(
                streakCount: occurrence.currentStreak!.streakCount,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskListLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            occurrence.taskListName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner(BuildContext context) {
    final strings = AppStrings.of(context);

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              strings.overdue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowStreakWarning() {
    if (occurrence.currentStreak == null || !occurrence.currentStreak!.isActive) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilDue = occurrence.dueDate.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 6;
  }
}

/// Medium-kort til tomorrow og this week - moderat storrelse med accent farve
class _MediumTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final TaskUrgency urgency;
  final VoidCallback? onTap;
  final bool isDesktop;

  const _MediumTaskCard({
    required this.occurrence,
    required this.isClickable,
    required this.urgency,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTomorrow = urgency == TaskUrgency.tomorrow;
    final accentColor = isTomorrow ? colorScheme.primary : colorScheme.secondary;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 3 : 2,
      pressedElevation: isDesktop ? 8 : 6,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 4),
      borderSide: BorderSide(
        color: accentColor.withValues(alpha: 0.3),
        width: 1,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent-linje paa venstre side
            Container(
              width: isDesktop ? 3 : 4,
              color: accentColor,
            ),
            // Lille billede eller ikon
            _buildImageSection(context, accentColor),
            // Indhold
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 10 : 12, 
                  vertical: isDesktop ? 6 : 8,
                ),
                child: _buildContent(context, accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, Color accentColor) {
    final imagePath = occurrence.taskImagePath;
    final imageWidth = isDesktop ? 56.0 : 70.0;

    if (imagePath != null && imagePath.isNotEmpty) {
      return SizedBox(
        width: imageWidth,
        child: CachedNetworkImage(
          imageUrl: ApiConfig.getImageUrl(imagePath),
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(accentColor),
          errorWidget: (context, url, error) => _buildPlaceholder(accentColor),
        ),
      );
    }

    return _buildPlaceholder(accentColor);
  }

  Widget _buildPlaceholder(Color accentColor) {
    final imageWidth = isDesktop ? 56.0 : 70.0;
    final iconSize = isDesktop ? 22.0 : 28.0;
    
    return Container(
      width: imageWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.task_alt,
        color: accentColor.withValues(alpha: 0.5),
        size: iconSize,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final titleStyle = isDesktop 
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
    final subtitleFontSize = isDesktop ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header med titel og badge
        Row(
          children: [
            Expanded(
              child: Text(
                occurrence.taskName,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isDesktop ? 6 : 8),
            _DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
          ],
        ),
        SizedBox(height: isDesktop ? 1 : 2),
        // Task list
        Row(
          children: [
            Icon(
              Icons.list,
              size: isDesktop ? 10 : 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: isDesktop ? 3 : 4),
            Expanded(
              child: Text(
                occurrence.taskListName,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Streak badge hvis aktiv
        if (occurrence.currentStreak != null &&
            occurrence.currentStreak!.isActive) ...[
          SizedBox(height: isDesktop ? 3 : 4),
          _AnimatedStreakBadge(
            streakCount: occurrence.currentStreak!.streakCount,
            isAtRisk: false,
            small: true,
          ),
        ],
      ],
    );
  }
}

/// Kompakt kort til future opgaver - minimalistisk design
class _CompactTaskCard extends StatelessWidget {
  final UpcomingTaskOccurrenceResponse occurrence;
  final bool isClickable;
  final VoidCallback? onTap;
  final bool isDesktop;

  const _CompactTaskCard({
    required this.occurrence,
    required this.isClickable,
    this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Responsive dimensioner
    final iconContainerSize = isDesktop ? 30.0 : 36.0;
    final iconSize = isDesktop ? 15.0 : 18.0;
    final horizontalPadding = isDesktop ? 10.0 : 12.0;
    final verticalPadding = isDesktop ? 6.0 : 8.0;

    return AnimatedCard(
      onTap: isClickable ? onTap : null,
      baseElevation: isDesktop ? 2 : 1,
      pressedElevation: isDesktop ? 4 : 3,
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 4),
      color: colorScheme.surfaceContainerLow,
      borderRadius: isDesktop ? 10 : 12,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, 
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            // Lille ikon
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(isDesktop ? 6 : 8),
              ),
              child: Icon(
                Icons.event_note,
                color: colorScheme.primary,
                size: iconSize,
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 12),
            // Titel og liste
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    occurrence.taskName,
                    style: (isDesktop ? theme.textTheme.labelMedium : theme.textTheme.bodySmall)?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    occurrence.taskListName,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: isDesktop ? 10 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Dato badge
            _DueDateBadge(dueDate: occurrence.dueDate, compact: isDesktop),
          ],
        ),
      ),
    );
  }
}

/// Semi-transparent overlay for låste opgaver
class _FrostedLockedOverlay extends StatelessWidget {
  final TaskUrgency urgency;

  const _FrostedLockedOverlay({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isUrgent = urgency == TaskUrgency.overdue || urgency == TaskUrgency.today;
    final bottomMargin = isUrgent ? 8.0 : 4.0;
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(isUrgent ? 20 : 16),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.completeEarlierTasksFirst,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Streak badge med ild-ikon
class _AnimatedStreakBadge extends StatelessWidget {
  final int streakCount;
  final bool isAtRisk;
  final bool small;

  const _AnimatedStreakBadge({
    required this.streakCount,
    this.isAtRisk = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 14.0 : 18.0;
    final fontSize = small ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAtRisk
              ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
              : [const Color(0xFFFF9500), const Color(0xFFFFCC00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAtRisk ? Colors.red : Colors.orange)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: size,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakCount',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadata chip til visning af små info-stykker
class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool small;

  const _MetadataChip({
    required this.icon,
    required this.label,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 12 : 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: small ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak advarsel banner
class _StreakWarningBanner extends StatelessWidget {
  final int streakCount;

  const _StreakWarningBanner({required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              strings.streakAtRisk(streakCount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge der viser forfaldsdato med farve baseret pa hastvaerk
class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool compact;

  const _DueDateBadge({
    required this.dueDate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dueDateColor = _getDueDateColor(context);
    final dueDateText = _formatDueDate(strings);
    
    // Responsive padding og font-storrelse
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = compact ? 4.0 : 6.0;
    final fontSize = compact ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: dueDateColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: dueDateColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        dueDateText,
        style: TextStyle(
          color: dueDateColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Formaterer forfaldsdato til menneskeligt læsbar streng
  String _formatDueDate(AppStrings strings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      final daysAgo = difference.abs();
      return daysAgo == 1 ? strings.dueDaysAgo(1) : strings.dueDaysAgo(daysAgo);
    } else if (difference == 0) {
      return strings.dueToday;
    } else if (difference == 1) {
      return strings.dueTomorrow;
    } else {
      return strings.dueInDays(difference);
    }
  }

  /// Returnerer farve for forfaldsdato-badge baseret på hastværk
  Color _getDueDateColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    if (difference < 0) {
      return colorScheme.error;
    } else if (difference == 0) {
      return colorScheme.tertiary;
    } else if (difference == 1) {
      return colorScheme.primary;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }
}
