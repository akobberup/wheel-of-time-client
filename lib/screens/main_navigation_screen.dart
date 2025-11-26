import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_lists_screen.dart';
import 'invitations_screen.dart';
import 'upcoming_tasks_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import '../providers/invitation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../l10n/app_strings.dart';

/// Provider der holder styr på hvilket tab der er valgt i bottom navigation
final selectedIndexProvider = StateProvider<int>((ref) => 1);

/// Hovedskærm med bottom navigation mellem Lists, Upcoming Tasks og Invitations
class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref, strings),
      body: _buildBody(selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(ref, strings, selectedIndex),
    );
  }

  /// Bygger app bar med titel og action buttons
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isUpcomingTasksTab = selectedIndex == 1;

    return AppBar(
      title: Text(strings.appTitle),
      actions: [
        // Refresh knap for upcoming tasks (synlig på desktop)
        if (isUpcomingTasksTab)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refresh,
            onPressed: () => ref.read(upcomingTasksProvider.notifier).refresh(),
          ),
        _NotificationButton(strings: strings),
        _SettingsButton(strings: strings),
        _LogoutButton(strings: strings),
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

  /// Bygger bottom navigation bar med badges for invitations
  Widget _buildBottomNavigationBar(
    WidgetRef ref,
    AppStrings strings,
    int selectedIndex,
  ) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _handleNavigationChange(ref, index),
      destinations: _buildNavigationDestinations(ref, strings),
    );
  }

  /// Bygger navigation destinations med badges
  List<NavigationDestination> _buildNavigationDestinations(
    WidgetRef ref,
    AppStrings strings,
  ) {
    final pendingInvitationsCount = _getPendingInvitationsCount(ref);

    return [
      NavigationDestination(
        icon: const Icon(Icons.list),
        label: strings.lists,
      ),
      NavigationDestination(
        icon: const Icon(Icons.upcoming),
        label: strings.upcomingTasks,
      ),
      NavigationDestination(
        icon: _buildInvitationsBadge(pendingInvitationsCount),
        label: strings.invitations,
      ),
    ];
  }

  /// Bygger badge til invitations tab
  Widget _buildInvitationsBadge(int count) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: const Icon(Icons.mail),
    );
  }

  /// Henter antal pending invitations
  int _getPendingInvitationsCount(WidgetRef ref) {
    final pendingInvitationsAsync = ref.watch(invitationProvider);
    int count = 0;

    pendingInvitationsAsync.whenData((invitations) {
      count = invitations.length;
    });

    return count;
  }

  /// Håndterer ændring af valgt tab og refresher data ved behov
  void _handleNavigationChange(WidgetRef ref, int index) {
    final previousIndex = ref.read(selectedIndexProvider);
    ref.read(selectedIndexProvider.notifier).state = index;

    // Refresh upcoming tasks når vi navigerer til det tab
    if (index == 1 && previousIndex != 1) {
      ref.read(upcomingTasksProvider.notifier).refresh();
    }
  }
}

/// Notification button med badge der viser antal ulæste notifikationer
class _NotificationButton extends ConsumerWidget {
  final AppStrings strings;

  const _NotificationButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationCountProvider);

    return Semantics(
      label: strings.notifications,
      button: true,
      child: IconButton(
        icon: _buildBadge(notificationCount),
        tooltip: strings.notifications,
        onPressed: () => _handleNotificationPressed(context),
      ),
    );
  }

  /// Bygger notification badge
  Widget _buildBadge(int count) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: const Icon(Icons.notifications),
    );
  }

  /// Håndterer tryk på notification button
  void _handleNotificationPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }
}

/// Settings button der navigerer til indstillinger
class _SettingsButton extends ConsumerWidget {
  final AppStrings strings;

  const _SettingsButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Indstillinger',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Indstillinger',
        onPressed: () => _handleSettingsPressed(context),
      ),
    );
  }

  /// Håndterer tryk på settings button
  void _handleSettingsPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

/// Logout button der logger brugeren ud
class _LogoutButton extends ConsumerWidget {
  final AppStrings strings;

  const _LogoutButton({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: strings.logout,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.logout),
        tooltip: strings.logout,
        onPressed: () => _handleLogout(context, ref),
      ),
    );
  }

  /// Håndterer logout og navigerer til login skærm
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}
