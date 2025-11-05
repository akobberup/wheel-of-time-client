import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../l10n/app_strings.dart';

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final invitationsAsync = ref.watch(invitationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.invitations),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(invitationProvider.notifier).loadPendingInvitations();
        },
        child: invitationsAsync.when(
          data: (invitations) {
            if (invitations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      strings.noPendingInvitations,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.invitationsWillAppearHere,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                final invitation = invitations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt, size: 40),
                    title: Text(invitation.taskListName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${strings.invitationFrom}: ${invitation.initiatedByUserName}'),
                        const SizedBox(height: 2),
                        Text(
                          invitation.currentState.name == 'PENDING' ? strings.pending : invitation.currentState.name,
                          style: TextStyle(
                            color: invitation.currentState.name == 'PENDING'
                                ? Colors.orange
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: invitation.currentState.name == 'PENDING'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () async {
                                  final success = await ref
                                      .read(invitationProvider.notifier)
                                      .acceptInvitation(invitation.id);
                                  if (success && context.mounted) {
                                    final strings = AppStrings.of(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(strings.invitationAccepted)),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () async {
                                  final success = await ref
                                      .read(invitationProvider.notifier)
                                      .declineInvitation(invitation.id);
                                  if (success && context.mounted) {
                                    final strings = AppStrings.of(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(strings.invitationDeclined)),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(strings.errorLoadingInvitations(error.toString())),
          ),
        ),
      ),
    );
  }
}
