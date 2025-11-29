// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/task_occurrence.dart';
import '../models/task_list.dart';
import '../widgets/task_cards/task_cards.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/skeleton_loader.dart';
import '../l10n/app_strings.dart';
import 'upcoming_tasks_screen.dart';
import 'task_lists_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

/// Hjemmeskærm der viser en oversigt over brugerens opgaver og lister
/// med varm, organisk æstetik og brugervalgt temafarve
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    // Baggrundfarve jf. Design Guidelines 1.0.0
    final backgroundColor =
        isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar med expandedHeight: 100
          _buildSliverAppBar(context, strings, themeState, isDark, ref),

          // Velkommen sektion
          SliverToBoxAdapter(
            child: _WelcomeSection(
              seedColor: themeState.seedColor,
              isDark: isDark,
            ),
          ),

          // Hastende opgaver sektion
          _buildUrgentTasksSection(context, ref, strings, themeState, isDark),

          // Mine lister sektion
          _buildTaskListsSection(context, ref, strings, themeState, isDark),

          // Bund padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Bygger custom SliverAppBar med tema-farve og organisk design
  Widget _buildSliverAppBar(
    BuildContext context,
    AppStrings strings,
    ThemeState themeState,
    bool isDark,
    WidgetRef ref,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor:
          isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          strings.appTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        // Notifikationer
        _NotificationButton(strings: strings),
        // Indstillinger
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: strings.settings,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        // Log ud
        IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: strings.logout,
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Bygger sektion med hastende opgaver
  Widget _buildUrgentTasksSection(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ThemeState themeState,
    bool isDark,
  ) {
    final upcomingTasksState = ref.watch(upcomingTasksProvider);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sektion header
          _SectionHeader(
            title: strings.upcomingTasks,
            seedColor: themeState.seedColor,
            isDark: isDark,
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UpcomingTasksScreen()),
            ),
          ),

          // Opgave indhold
          _buildTasksContent(context, ref, upcomingTasksState, strings, isDark),
        ],
      ),
    );
  }

  /// Bygger indhold for opgaver baseret på state
  Widget _buildTasksContent(
    BuildContext context,
    WidgetRef ref,
    UpcomingTasksState state,
    AppStrings strings,
    bool isDark,
  ) {
    if (state.isLoading && state.occurrences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonListLoader(),
      );
    }

    if (state.occurrences.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: EmptyState(
          title: strings.noUpcomingTasks,
          subtitle: strings.allCaughtUpWithTasks,
        ),
      );
    }

    // Vis kun de første 3 hastende opgaver
    final urgentTasks = state.occurrences.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: urgentTasks.map((occurrence) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskOccurrenceCard(
              occurrence: occurrence,
              onQuickComplete: (occ) => _handleQuickComplete(ref, occ),
              onTap: (context, occ) => _handleTaskTap(context, ref, occ),
              isDesktop: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Bygger sektion med opgavelister
  Widget _buildTaskListsSection(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ThemeState themeState,
    bool isDark,
  ) {
    final taskListsAsync = ref.watch(taskListProvider);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Sektion header
          _SectionHeader(
            title: strings.lists,
            seedColor: themeState.seedColor,
            isDark: isDark,
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskListsScreen()),
            ),
          ),

          // Liste indhold
          taskListsAsync.when(
            data: (lists) =>
                _buildTaskListsContent(lists, strings, themeState, isDark),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SkeletonListLoader(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                '${strings.error}: $error',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFF6B6B6B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bygger indhold for opgavelister
  Widget _buildTaskListsContent(
    List<TaskListResponse> lists,
    AppStrings strings,
    ThemeState themeState,
    bool isDark,
  ) {
    if (lists.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: EmptyState(
          title: strings.noTaskListsYet,
          subtitle: 'Opret din første liste for at komme i gang',
        ),
      );
    }

    // Vis kun de første 4 lister
    final previewLists = lists.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: previewLists.length,
        itemBuilder: (context, index) {
          return _TaskListCard(
            taskList: previewLists[index],
            seedColor: themeState.seedColor,
            isDark: isDark,
          );
        },
      ),
    );
  }

  /// Håndterer hurtig fuldførelse af opgave
  Future<void> _handleQuickComplete(
    WidgetRef ref,
    UpcomingTaskOccurrenceResponse occurrence,
  ) async {
    // Implementeres med komplette dialog som i UpcomingTasksScreen
    ref.read(upcomingTasksProvider.notifier).refresh();
  }

  /// Håndterer tryk på opgave
  Future<void> _handleTaskTap(
    BuildContext context,
    WidgetRef ref,
    UpcomingTaskOccurrenceResponse occurrence,
  ) async {
    // Implementeres med komplette dialog som i UpcomingTasksScreen
  }
}

/// Velkomst-sektion med cirkulær motivisk design
class _WelcomeSection extends StatelessWidget {
  final Color seedColor;
  final bool isDark;

  const _WelcomeSection({
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Varm baggrund med subtle gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            seedColor.withValues(alpha: isDark ? 0.15 : 0.08),
            seedColor.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // Subtle shadow jf. Design Guidelines
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
      child: Row(
        children: [
          // Cirkulær ikon - symboliserer hjulet/cyklussen
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seedColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.autorenew,
              size: 32,
              color: seedColor,
            ),
          ),
          const SizedBox(width: 20),
          // Velkomst tekst
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hold styr på dine gentagelser',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returnerer tidbaseret hilsen
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'God morgen';
    if (hour < 18) return 'God eftermiddag';
    return 'God aften';
  }
}

/// Sektion header med titel, tema-farve og "Se alle" knap
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color seedColor;
  final bool isDark;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.seedColor,
    required this.isDark,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titel med uppercase og letterSpacing jf. Design Guidelines
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: seedColor,
            ),
          ),
          // "Se alle" knap
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: seedColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Se alle'),
          ),
        ],
      ),
    );
  }
}

/// Kort der viser en opgaveliste med bløde kanter og subtle skygger
class _TaskListCard extends StatelessWidget {
  final TaskListResponse taskList;
  final Color seedColor;
  final bool isDark;

  const _TaskListCard({
    required this.taskList,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Overflade-farve jf. Design Guidelines
    final surfaceColor =
        isDark ? const Color(0xFF222226) : const Color(0xFFFFFFFF);
    final textPrimaryColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A);
    final textSecondaryColor =
        isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        // Subtle shadow kun i lys tilstand
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
        child: InkWell(
          onTap: () {
            // Naviger til liste detaljer
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Liste ikon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seedColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    size: 20,
                    color: seedColor,
                  ),
                ),

                // Liste info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskList.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${taskList.activeTaskCount} aktive',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification button med badge der viser antal ulæste notifikationer
class _NotificationButton extends ConsumerWidget {
  final AppStrings strings;

  const _NotificationButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationCountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Badge(
        isLabelVisible: notificationCount > 0,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
        label: Text(
          '$notificationCount',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      tooltip: strings.notifications,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
    );
  }
}
