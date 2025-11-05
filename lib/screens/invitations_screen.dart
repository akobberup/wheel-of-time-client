import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../l10n/app_strings.dart';

class InvitationsScreen extends HookConsumerWidget {
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
                return _InvitationCard(invitation: invitation);
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

/// Separate widget for each invitation card to manage its own loading state
class _InvitationCard extends HookConsumerWidget {
  final dynamic invitation;

  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

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
                  // Accept button with loading state
                  isLoadingAccept.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: (isLoadingAccept.value || isLoadingDecline.value)
                              ? null
                              : () async {
                                  isLoadingAccept.value = true;
                                  try {
                                    final success = await ref
                                        .read(invitationProvider.notifier)
                                        .acceptInvitation(invitation.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(strings.invitationAccepted)),
                                      );
                                    }
                                  } finally {
                                    isLoadingAccept.value = false;
                                  }
                                },
                        ),
                  // Decline button with loading state
                  isLoadingDecline.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: (isLoadingAccept.value || isLoadingDecline.value)
                              ? null
                              : () async {
                                  isLoadingDecline.value = true;
                                  try {
                                    final success = await ref
                                        .read(invitationProvider.notifier)
                                        .declineInvitation(invitation.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(strings.invitationDeclined)),
                                      );
                                    }
                                  } finally {
                                    isLoadingDecline.value = false;
                                  }
                                },
                        ),
                ],
              )
            : null,
      ),
    );
  }
}
