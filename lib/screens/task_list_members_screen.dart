import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_list_user_provider.dart';
import '../providers/invitation_provider.dart';
import '../models/task_list_user.dart';
import '../models/enums.dart';
import '../widgets/send_invitation_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/status_badge.dart';
import 'dart:math';

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

  /// Gets initials from a full name.
  /// Returns first letter of first and last name if available, otherwise up to 2 chars.
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return fullName.substring(0, min(2, fullName.length)).toUpperCase();
  }

  /// Shows a confirmation dialog for removing a member.
  Future<bool> _showRemoveMemberConfirmation(BuildContext context, String userName) async {
    final strings = AppStrings.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.removeMember),
            content: Text(strings.confirmRemoveMember(userName)),
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
                child: Text(strings.remove),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a confirmation dialog for canceling an invitation.
  Future<bool> _showCancelInvitationConfirmation(BuildContext context, String email) async {
    final strings = AppStrings.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.cancelInvitation),
            content: Text(strings.confirmCancelInvitation(email)),
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
                child: Text(strings.cancelInvite),
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
    final strings = AppStrings.of(context);
    final newLevel = await showDialog<AdminLevel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.changePermissionLevel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.changePermissionFor(user.userName)),
            const SizedBox(height: 16),
            ListTile(
              title: Text(strings.canEdit),
              subtitle: Text(strings.canEditDescription),
              leading: Radio<AdminLevel>(
                value: AdminLevel.CAN_EDIT,
                groupValue: user.userAdminLevel,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              onTap: () => Navigator.of(context).pop(AdminLevel.CAN_EDIT),
            ),
            ListTile(
              title: Text(strings.canView),
              subtitle: Text(strings.canViewDescription),
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
            child: Text(strings.cancel),
          ),
        ],
      ),
    );

    if (newLevel != null && newLevel != user.userAdminLevel && context.mounted) {
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .updateUserAdminLevel(user.userId, newLevel);

      if (context.mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? strings.permissionUpdatedSuccess
                  : strings.failedToUpdatePermission,
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final membersAsync = ref.watch(taskListUserNotifierProvider(taskListId));
    final invitationsAsync = ref.watch(taskListInvitationsProvider(taskListId));

    return Scaffold(
      appBar: _buildAppBar(strings),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref),
        child: _buildBody(context, ref, membersAsync, invitationsAsync, strings),
      ),
      floatingActionButton: _buildFAB(context, strings),
    );
  }

  AppBar _buildAppBar(AppStrings strings) {
    return AppBar(
      title: Text(strings.membersIn(taskListName)),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    await Future.wait([
      ref.read(taskListUserNotifierProvider(taskListId).notifier).loadUsers(),
      ref.refresh(taskListInvitationsProvider(taskListId).future),
    ]);
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue membersAsync,
    AsyncValue invitationsAsync,
    AppStrings strings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMembersSection(context, ref, membersAsync, strings),
        const SizedBox(height: 24),
        _buildInvitationsSection(context, ref, invitationsAsync, strings),
      ],
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue membersAsync,
    AppStrings strings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.members,
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
                        strings.noMembers,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
                          child: Text(_getInitials(member.userName)),
                        ),
                        title: Text(
                          member.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              member.userEmail,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
                                    ? strings.canEdit
                                    : strings.canView,
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
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'change_permission',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 20),
                                  const SizedBox(width: 12),
                                  Text(strings.changePermission),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  const Icon(Icons.person_remove, size: 20, color: Colors.red),
                                  const SizedBox(width: 12),
                                  Text(strings.removeMember, style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'change_permission') {
                              _showChangeAdminLevelDialog(context, ref, member);
                            } else if (value == 'remove') {
                              final confirmed = await _showRemoveMemberConfirmation(
                                context,
                                member.userName,
                              );
                              if (confirmed) {
                                HapticFeedback.heavyImpact();
                                final success = await ref
                                    .read(taskListUserNotifierProvider(taskListId).notifier)
                                    .removeUser(member.userId);
                                if (context.mounted) {
                                  final strings = AppStrings.of(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? strings.memberRemovedSuccess
                                            : strings.failedToRemoveMember,
                                      ),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
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
              loading: () => const SkeletonListLoader(itemCount: 3),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(strings.errorLoadingMembers(error.toString())),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildInvitationsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue invitationsAsync,
    AppStrings strings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.pendingInvitations,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        invitationsAsync.when<Widget>(
              data: (invitations) {
                final pending = invitations
                    .where((inv) => inv.currentState == InvitationState.SENT)
                    .toList();

                if (pending.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        strings.noPendingInvitations,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: pending.map<Widget>((invitation) {
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
                              strings.invitedBy(invitation.initiatedByUserName),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusBadge(
                              label: strings.pending,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        trailing: Semantics(
                          label: '${strings.cancelInvitation} ${invitation.emailAddress}',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.cancel),
                            tooltip: strings.cancelInvitation,
                            color: Colors.red,
                            onPressed: () async {
                              final confirmed = await _showCancelInvitationConfirmation(
                                context,
                                invitation.emailAddress,
                              );
                              if (confirmed) {
                                HapticFeedback.heavyImpact();
                                final success = await ref
                                    .read(invitationProvider.notifier)
                                    .cancelInvitation(invitation.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? strings.invitationCancelledSuccess
                                            : strings.failedToCancelInvitation,
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
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SkeletonListLoader(itemCount: 3),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(strings.errorLoadingInvitations(error.toString())),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, AppStrings strings) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (context) => SendInvitationDialog(
            taskListId: taskListId,
            taskListName: taskListName,
          ),
        );
        if (result == true && context.mounted) {
          final ref = ProviderScope.containerOf(context);
          ref.refresh(taskListInvitationsProvider(taskListId));
        }
      },
      icon: const Icon(Icons.person_add),
      label: Text(strings.invite),
    );
  }
}
