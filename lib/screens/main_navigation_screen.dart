import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_lists_screen.dart';
import 'invitations_screen.dart';
import 'upcoming_tasks_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import '../providers/invitation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_strings.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 1); // Default to Upcoming tasks tab

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final pendingInvitationsAsync = ref.watch(invitationProvider);
    final notificationCount = ref.watch(notificationCountProvider);

    int pendingCount = 0;
    pendingInvitationsAsync.whenData((invitations) {
      pendingCount = invitations.length;
    });

    final screens = [
      const TaskListsScreen(),
      const UpcomingTasksScreen(),
      const InvitationsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          Semantics(
            label: strings.notifications,
            button: true,
            child: IconButton(
              icon: Badge(
                isLabelVisible: notificationCount > 0,
                label: Text('$notificationCount'),
                child: const Icon(Icons.notifications),
              ),
              tooltip: strings.notifications,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
          ),
          Semantics(
            label: strings.logout,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout),
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
          ),
        ],
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: strings.lists,
          ),
          NavigationDestination(
            icon: const Icon(Icons.upcoming),
            label: strings.upcomingTasks,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.mail),
            ),
            label: strings.invitations,
          ),
        ],
      ),
    );
  }
}
