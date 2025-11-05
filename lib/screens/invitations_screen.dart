import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';

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
              return EmptyState(
                icon: Icons.mail_outline,
                title: strings.noPendingInvitations,
                subtitle: strings.invitationsWillAppearHere,
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

  String _getStateLabel(dynamic state, AppStrings strings) {
    final stateName = state.name.toString();
    switch (stateName) {
      case 'SENT':
        return strings.pending;
      case 'ACCEPTED':
        return strings.accepted;
      case 'DECLINED':
        return strings.declined;
      default:
        return stateName;
    }
  }

  IconData _getStateIcon(dynamic state) {
    final stateName = state.name.toString();
    switch (stateName) {
      case 'SENT':
        return Icons.schedule;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'DECLINED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStateIcon(invitation.currentState),
                  size: 12,
                  color: invitation.currentState.name == 'SENT'
                      ? Colors.orange
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _getStateLabel(invitation.currentState, strings),
                  style: TextStyle(
                    color: invitation.currentState.name == 'SENT'
                        ? Colors.orange
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
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
                      : Semantics(
                          label: '${strings.acceptInvitation} ${invitation.taskListName}',
                          button: true,
                          child: IconButton(
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
                        ),
                  // Decline button with loading state
                  isLoadingDecline.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Semantics(
                          label: '${strings.declineInvitation} ${invitation.taskListName}',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: (isLoadingAccept.value || isLoadingDecline.value)
                                ? null
                                : () async {
                                    // Show confirmation dialog before declining
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(strings.declineInvitation),
                                        content: Text(
                                          'Are you sure you want to decline the invitation to "${invitation.taskListName}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text(strings.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(strings.declineInvitation),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed != true) return;

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
                        ),
                ],
              )
            : null,
      ),
    );
  }
}
