// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'task_lists_screen.dart';
import 'invitations_screen.dart';
import 'upcoming_tasks_screen.dart';
import '../models/invitation.dart';
import '../providers/invitation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';

/// Provider der holder styr på hvilket tab der er valgt i bottom navigation
final selectedIndexProvider = StateProvider<int>((ref) => 1);

/// Hovedskærm med bottom navigation mellem Lists, Upcoming Tasks og Invitations
/// Design Version 1.0.0 - Implementerer varm, organisk æstetik med bløde former
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  bool _hasCheckedInitialTab = false;

  /// Tjekker om brugeren har opgavelister og dirigerer til korrekt tab
  /// Hvis brugeren har ventende invitationer → Invitations tab (index 2)
  /// Hvis ingen opgavelister og ingen invitationer → Lists tab (index 0) for onboarding
  void _checkInitialTabForNewUser(
    AsyncValue<List<dynamic>> taskListsAsync,
    AsyncValue<List<InvitationResponse>> invitationsAsync,
  ) {
    if (_hasCheckedInitialTab) return;

    taskListsAsync.whenData((taskLists) {
      if (_hasCheckedInitialTab) return;

      if (taskLists.isEmpty) {
        // Vent på at invitationer også er loaded før vi beslutter
        invitationsAsync.whenData((invitations) {
          if (_hasCheckedInitialTab) return;
          _hasCheckedInitialTab = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (invitations.isNotEmpty) {
                // Ny bruger med ventende invitationer - vis Invitations tab
                ref.read(selectedIndexProvider.notifier).state = 2;
              } else {
                // Ny bruger uden invitationer - vis Lists tab for onboarding
                ref.read(selectedIndexProvider.notifier).state = 0;
              }
            }
          });
        });
      } else {
        _hasCheckedInitialTab = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final themeState = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeState.isDarkMode;
    // Brug neutrale baggrundsfarver for konsistens på tværs af skærme
    final backgroundColor =
        isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8);

    // Tjek om ny bruger skal dirigeres til Invitations eller Lists tab
    final taskListsAsync = ref.watch(taskListProvider);
    final invitationsAsync = ref.watch(invitationProvider);
    _checkInitialTabForNewUser(taskListsAsync, invitationsAsync);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, strings, colorScheme, backgroundColor),
      body: _buildBody(selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(
        strings,
        selectedIndex,
        colorScheme,
        themeState.seedColor,
        backgroundColor,
      ),
    );
  }

  /// Bygger app bar med titel og action buttons i organisk stil
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppStrings strings,
    ColorScheme colorScheme,
    Color backgroundColor,
  ) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isUpcomingTasksTab = selectedIndex == 1;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        strings.appTitle,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        // Refresh knap for upcoming tasks (synlig på desktop)
        if (isUpcomingTasksTab)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: strings.refresh,
            onPressed: () => ref.read(upcomingTasksProvider.notifier).refresh(),
          ),
        _NotificationButton(strings: strings),
        _SettingsButton(strings: strings),
        _LogoutButton(strings: strings),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Bygger body med de forskellige skærme baseret på valgt tab
  Widget _buildBody(int selectedIndex) {
    final screens = [
      const TaskListsScreen(),
      const UpcomingTasksScreen(),
      const InvitationsScreen(),
    ];

    return screens[selectedIndex];
  }

  /// Bygger bottom navigation bar med organisk, varm design
  /// Bruger brugerens valgte tema-farve for aktive elementer
  Widget _buildBottomNavigationBar(
    AppStrings strings,
    int selectedIndex,
    ColorScheme colorScheme,
    Color seedColor,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        // Subtil border øverst for depth
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _handleNavigationChange(index),
        backgroundColor: backgroundColor,
        indicatorColor: seedColor.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _buildNavigationDestinations(strings, colorScheme, seedColor),
      ),
    );
  }

  /// Bygger navigation destinations med bløde ikoner og badges
  /// Følger design guidelines med outlined ikoner
  List<NavigationDestination> _buildNavigationDestinations(
    AppStrings strings,
    ColorScheme colorScheme,
    Color seedColor,
  ) {
    final pendingInvitationsCount = _getPendingInvitationsCount();
    final selectedIndex = ref.watch(selectedIndexProvider);

    return [
      NavigationDestination(
        icon: Icon(
          Icons.list_alt_rounded,
          color: selectedIndex == 0 ? seedColor : colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.list_alt_rounded,
          color: seedColor,
        ),
        label: strings.lists,
      ),
      NavigationDestination(
        icon: Icon(
          Icons.upcoming_outlined,
          color: selectedIndex == 1 ? seedColor : colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.upcoming_rounded,
          color: seedColor,
        ),
        label: strings.upcomingTasks,
      ),
      NavigationDestination(
        icon: _buildInvitationsBadge(
          pendingInvitationsCount,
          selectedIndex == 2,
          colorScheme,
          seedColor,
        ),
        selectedIcon: _buildInvitationsBadge(
          pendingInvitationsCount,
          true,
          colorScheme,
          seedColor,
        ),
        label: strings.invitations,
      ),
    ];
  }

  /// Bygger badge til invitations tab med organisk design
  Widget _buildInvitationsBadge(
    int count,
    bool isSelected,
    ColorScheme colorScheme,
    Color seedColor,
  ) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: const Color(0xFFEF4444), // Status farve: Fejl/Advarsel
      textColor: Colors.white,
      label: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Icon(
        isSelected ? Icons.mail_rounded : Icons.mail_outline_rounded,
        color: isSelected ? seedColor : colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Henter antal pending invitations
  int _getPendingInvitationsCount() {
    final pendingInvitationsAsync = ref.watch(invitationProvider);
    int count = 0;

    pendingInvitationsAsync.whenData((invitations) {
      count = invitations.length;
    });

    return count;
  }

  /// Håndterer ændring af valgt tab og refresher data ved behov
  void _handleNavigationChange(int index) {
    final previousIndex = ref.read(selectedIndexProvider);
    ref.read(selectedIndexProvider.notifier).state = index;

    // Refresh upcoming tasks når vi navigerer til det tab
    if (index == 1 && previousIndex != 1) {
      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }
}

/// Notification button med badge der viser antal ulæste notifikationer
/// Design Version 1.0.0 - Organisk stil med bløde ikoner
class _NotificationButton extends ConsumerWidget {
  final AppStrings strings;

  const _NotificationButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationCountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: strings.notifications,
      button: true,
      child: IconButton(
        icon: _buildBadge(notificationCount, colorScheme),
        tooltip: strings.notifications,
        onPressed: () => _handleNotificationPressed(context),
      ),
    );
  }

  /// Bygger notification badge med organisk design
  Widget _buildBadge(int count, ColorScheme colorScheme) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: const Color(0xFFEF4444), // Status farve: Fejl/Advarsel
      textColor: Colors.white,
      label: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Håndterer tryk på notification button - bruger GoRouter for browser historik
  void _handleNotificationPressed(BuildContext context) {
    context.push('/notifications');
  }
}

/// Settings button der navigerer til indstillinger
/// Design Version 1.0.0 - Outlined ikon stil
class _SettingsButton extends ConsumerWidget {
  final AppStrings strings;

  const _SettingsButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: strings.settings,
      button: true,
      child: IconButton(
        icon: Icon(
          Icons.settings_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        tooltip: strings.settings,
        onPressed: () => _handleSettingsPressed(context),
      ),
    );
  }

  /// Håndterer tryk på settings button - bruger GoRouter for browser historik
  void _handleSettingsPressed(BuildContext context) {
    context.push('/settings');
  }
}

/// Logout button der logger brugeren ud
/// Design Version 1.0.0 - Outlined ikon stil
class _LogoutButton extends ConsumerWidget {
  final AppStrings strings;

  const _LogoutButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: strings.logout,
      button: true,
      child: IconButton(
        icon: Icon(
          Icons.logout_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        tooltip: strings.logout,
        onPressed: () => _handleLogout(context, ref),
      ),
    );
  }

  /// Håndterer logout og navigerer til login skærm
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();

    if (context.mounted) {
      context.go('/login');
    }
  }
}
