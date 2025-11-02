import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_lists_screen.dart';
import 'invitations_screen.dart';
import '../providers/invitation_provider.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final pendingInvitationsAsync = ref.watch(invitationProvider);

    int pendingCount = 0;
    pendingInvitationsAsync.whenData((invitations) {
      pendingCount = invitations.length;
    });

    final screens = [
      const TaskListsScreen(),
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
          const NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.mail),
            ),
            label: 'Invitations',
          ),
        ],
      ),
    );
  }
}
