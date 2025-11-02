import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_list_user_provider.dart';
import '../providers/invitation_provider.dart';
import '../models/task_list_user.dart';
import '../models/enums.dart';
import '../widgets/send_invitation_dialog.dart';

/// Screen for managing members of a task list.
/// Shows current members, pending invitations, and allows adding/removing members.
class TaskListMembersScreen extends ConsumerWidget {
  final int taskListId;
  final String taskListName;

  const TaskListMembersScreen({
    super.key,
    required this.taskListId,
    required this.taskListName,
  });

  /// Shows a confirmation dialog for removing a member.
  Future<bool> _showRemoveMemberConfirmation(BuildContext context, String userName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Member'),
            content: Text(
              'Are you sure you want to remove "$userName" from this task list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a confirmation dialog for canceling an invitation.
  Future<bool> _showCancelInvitationConfirmation(BuildContext context, String email) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Invitation'),
            content: Text(
              'Are you sure you want to cancel the invitation to "$email"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Invite'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a dialog to change a user's admin level.
  Future<void> _showChangeAdminLevelDialog(
    BuildContext context,
    WidgetRef ref,
    TaskListUserResponse user,
  ) async {
    final newLevel = await showDialog<AdminLevel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Permission Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change permission level for ${user.userName}:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Can Edit'),
              subtitle: const Text('Can modify tasks and settings'),
              leading: Radio<AdminLevel>(
                value: AdminLevel.CAN_EDIT,
                groupValue: user.userAdminLevel,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              onTap: () => Navigator.of(context).pop(AdminLevel.CAN_EDIT),
            ),
            ListTile(
              title: const Text('Can View'),
              subtitle: const Text('Can only view and complete tasks'),
              leading: Radio<AdminLevel>(
                value: AdminLevel.CAN_VIEW,
                groupValue: user.userAdminLevel,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              onTap: () => Navigator.of(context).pop(AdminLevel.CAN_VIEW),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newLevel != null && newLevel != user.userAdminLevel && context.mounted) {
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .updateUserAdminLevel(user.userId, newLevel);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Permission level updated successfully'
                  : 'Failed to update permission level',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(taskListUserNotifierProvider(taskListId));
    final invitationsAsync = ref.watch(taskListInvitationsProvider(taskListId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(taskListUserNotifierProvider(taskListId).notifier).loadUsers(),
            ref.refresh(taskListInvitationsProvider(taskListId).future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Members Section
            Text(
              'Members',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No members yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return Column(
                  children: members.map((member) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.userName.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(member.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.userEmail,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: member.userAdminLevel == AdminLevel.CAN_EDIT
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                member.userAdminLevel == AdminLevel.CAN_EDIT
                                    ? 'Can Edit'
                                    : 'Can View',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: member.userAdminLevel == AdminLevel.CAN_EDIT
                                      ? Colors.blue.shade900
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Change Permission',
                              onPressed: () => _showChangeAdminLevelDialog(
                                context,
                                ref,
                                member,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove),
                              tooltip: 'Remove Member',
                              color: Colors.red,
                              onPressed: () async {
                                final confirmed = await _showRemoveMemberConfirmation(
                                  context,
                                  member.userName,
                                );
                                if (confirmed) {
                                  final success = await ref
                                      .read(taskListUserNotifierProvider(taskListId).notifier)
                                      .removeUser(member.userId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Member removed successfully'
                                              : 'Failed to remove member',
                                        ),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading members: $error'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Pending Invitations Section
            Text(
              'Pending Invitations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            invitationsAsync.when(
              data: (invitations) {
                final pending = invitations
                    .where((inv) => inv.currentState == InvitationState.SENT)
                    .toList();

                if (pending.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No pending invitations',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return Column(
                  children: pending.map((invitation) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.mail_outline),
                        ),
                        title: Text(invitation.emailAddress),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invited by ${invitation.initiatedByUserName}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel),
                          tooltip: 'Cancel Invitation',
                          color: Colors.orange,
                          onPressed: () async {
                            final confirmed = await _showCancelInvitationConfirmation(
                              context,
                              invitation.emailAddress,
                            );
                            if (confirmed) {
                              final success = await ref
                                  .read(invitationProvider.notifier)
                                  .cancelInvitation(invitation.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Invitation cancelled successfully'
                                          : 'Failed to cancel invitation',
                                    ),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                                // Refresh the invitations list
                                if (success) {
                                  ref.refresh(taskListInvitationsProvider(taskListId));
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading invitations: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => SendInvitationDialog(
              taskListId: taskListId,
              taskListName: taskListName,
            ),
          );
          if (result == true) {
            ref.refresh(taskListInvitationsProvider(taskListId));
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
      ),
    );
  }
}
