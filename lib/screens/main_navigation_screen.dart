import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_lists_screen.dart';
import 'invitations_screen.dart';
import 'upcoming_tasks_screen.dart';
import '../providers/invitation_provider.dart';
import '../l10n/app_strings.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 1); // Default to Upcoming tasks tab

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final pendingInvitationsAsync = ref.watch(invitationProvider);

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
