import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/task_list_user_provider.dart';
import '../providers/invitation_provider.dart';
import '../models/task_list_user.dart';
import '../models/enums.dart';
import '../widgets/send_invitation_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/status_badge.dart';
import 'dart:math';

/// Skærm til administration af medlemmer i en opgaveliste.
/// Viser aktuelle medlemmer, afventende invitationer og tillader tilføjelse/fjernelse af medlemmer.
class TaskListMembersScreen extends ConsumerWidget {
  final int taskListId;
  final String taskListName;

  const TaskListMembersScreen({
    super.key,
    required this.taskListId,
    required this.taskListName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final membersAsync = ref.watch(taskListUserNotifierProvider(taskListId));
    final invitationsAsync = ref.watch(taskListInvitationsProvider(taskListId));

    return Scaffold(
      appBar: _buildAppBar(strings),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(ref),
        child: _buildBody(context, ref, membersAsync, invitationsAsync, strings),
      ),
      floatingActionButton: _buildFAB(context, ref, strings),
    );
  }

  AppBar _buildAppBar(AppStrings strings) {
    return AppBar(
      title: Text(strings.membersIn(taskListName)),
    );
  }

  Future<void> _handleRefresh(WidgetRef ref) async {
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
        _MembersSection(
          taskListId: taskListId,
          membersAsync: membersAsync,
        ),
        const SizedBox(height: 24),
        _InvitationsSection(
          taskListId: taskListId,
          invitationsAsync: invitationsAsync,
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref, AppStrings strings) {
    return FloatingActionButton.extended(
      onPressed: () => _handleInviteMember(context, ref),
      icon: const Icon(Icons.person_add),
      label: Text(strings.invite),
    );
  }

  Future<void> _handleInviteMember(BuildContext context, WidgetRef ref) async {
    final result = await showDialog(
      context: context,
      builder: (context) => SendInvitationDialog(
        taskListId: taskListId,
        taskListName: taskListName,
      ),
    );

    if (result == true && context.mounted) {
      ref.invalidate(taskListInvitationsProvider(taskListId));
    }
  }
}

/// Sektion der viser alle medlemmer af opgavelisten
class _MembersSection extends ConsumerWidget {
  final int taskListId;
  final AsyncValue membersAsync;

  const _MembersSection({
    required this.taskListId,
    required this.membersAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, strings),
        const SizedBox(height: 8),
        _buildMembersList(context, ref, strings),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppStrings strings) {
    return Text(
      strings.members,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMembersList(BuildContext context, WidgetRef ref, AppStrings strings) {
    return membersAsync.when(
      data: (members) => _buildMembersData(members, strings),
      loading: () => const SkeletonListLoader(itemCount: 3),
      error: (error, stack) => _buildError(context, strings, error),
    );
  }

  Widget _buildMembersData(List<dynamic> members, AppStrings strings) {
    if (members.isEmpty) {
      return _buildEmptyState(strings);
    }

    return Column(
      children: members
          .map((member) => _MemberCard(
                taskListId: taskListId,
                member: member,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.noMembers,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, AppStrings strings, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(strings.errorLoadingMembers(error.toString())),
      ),
    );
  }
}

/// Kort der viser et enkelt medlem med handlinger
class _MemberCard extends HookConsumerWidget {
  final int taskListId;
  final TaskListUserResponse member;

  const _MemberCard({
    required this.taskListId,
    required this.member,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildAvatar(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildMenu(context, ref, strings),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      child: Text(_getInitials(member.userName)),
    );
  }

  Widget _buildTitle() {
    return Text(
      member.userName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        _buildEmail(context),
        const SizedBox(height: 4),
        _buildPermissionBadge(strings),
      ],
    );
  }

  Widget _buildEmail(BuildContext context) {
    return Text(
      member.userEmail,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPermissionBadge(AppStrings strings) {
    final isEditor = member.userAdminLevel == AdminLevel.CAN_EDIT;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isEditor ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isEditor ? strings.canEdit : strings.canView,
        style: TextStyle(
          fontSize: 11,
          color: isEditor ? Colors.blue.shade900 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref, AppStrings strings) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        _buildChangePermissionMenuItem(strings),
        _buildRemoveMemberMenuItem(strings),
      ],
      onSelected: (value) => _handleMenuAction(context, ref, value),
    );
  }

  PopupMenuItem<String> _buildChangePermissionMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'change_permission',
      child: Row(
        children: [
          const Icon(Icons.edit, size: 20),
          const SizedBox(width: 12),
          Text(strings.changePermission),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildRemoveMemberMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'remove',
      child: Row(
        children: [
          const Icon(Icons.person_remove, size: 20, color: Colors.red),
          const SizedBox(width: 12),
          Text(
            strings.removeMember,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'change_permission') {
      await _handleChangePermission(context, ref);
    } else if (action == 'remove') {
      await _handleRemoveMember(context, ref);
    }
  }

  Future<void> _handleChangePermission(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final newLevel = await _showChangeAdminLevelDialog(context, strings);

    if (newLevel != null && newLevel != member.userAdminLevel && context.mounted) {
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .updateUserAdminLevel(member.userId, newLevel);

      if (context.mounted) {
        _showPermissionUpdateResult(context, success);
      }
    }
  }

  Future<void> _handleRemoveMember(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final confirmed = await _showRemoveMemberConfirmation(context, strings);

    if (confirmed) {
      HapticFeedback.heavyImpact();
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .removeUser(member.userId);

      if (context.mounted) {
        _showRemoveMemberResult(context, success);
      }
    }
  }

  /// Viser dialog til ændring af administratorniveau for en bruger
  Future<AdminLevel?> _showChangeAdminLevelDialog(
    BuildContext context,
    AppStrings strings,
  ) {
    return showDialog<AdminLevel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.changePermissionLevel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.changePermissionFor(member.userName)),
            const SizedBox(height: 16),
            _buildPermissionOption(
              context,
              strings.canEdit,
              strings.canEditDescription,
              AdminLevel.CAN_EDIT,
            ),
            _buildPermissionOption(
              context,
              strings.canView,
              strings.canViewDescription,
              AdminLevel.CAN_VIEW,
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
  }

  Widget _buildPermissionOption(
    BuildContext context,
    String title,
    String description,
    AdminLevel level,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      leading: Radio<AdminLevel>(
        value: level,
        groupValue: member.userAdminLevel,
        onChanged: (value) => Navigator.of(context).pop(value),
      ),
      onTap: () => Navigator.of(context).pop(level),
    );
  }

  Future<bool> _showRemoveMemberConfirmation(
    BuildContext context,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.removeMember),
            content: Text(strings.confirmRemoveMember(member.userName)),
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

  void _showPermissionUpdateResult(BuildContext context, bool success) {
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

  void _showRemoveMemberResult(BuildContext context, bool success) {
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

  /// Henter initialer fra et fuldt navn.
  /// Returnerer første bogstav i for- og efternavn hvis tilgængeligt, ellers op til 2 tegn.
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return fullName.substring(0, min(2, fullName.length)).toUpperCase();
  }
}

/// Sektion der viser afventende invitationer
class _InvitationsSection extends ConsumerWidget {
  final int taskListId;
  final AsyncValue invitationsAsync;

  const _InvitationsSection({
    required this.taskListId,
    required this.invitationsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, strings),
        const SizedBox(height: 8),
        _buildInvitationsList(context, ref, strings),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppStrings strings) {
    return Text(
      strings.pendingInvitations,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInvitationsList(BuildContext context, WidgetRef ref, AppStrings strings) {
    return invitationsAsync.when<Widget>(
      data: (invitations) => _buildInvitationsData(invitations, strings),
      loading: () => const SkeletonListLoader(itemCount: 3),
      error: (error, stack) => _buildError(context, strings, error),
    );
  }

  Widget _buildInvitationsData(List<dynamic> invitations, AppStrings strings) {
    final pending = invitations
        .where((inv) => inv.currentState == InvitationState.SENT)
        .toList();

    if (pending.isEmpty) {
      return _buildEmptyState(strings);
    }

    return Column(
      children: pending
          .map<Widget>((invitation) => _InvitationCard(
                taskListId: taskListId,
                invitation: invitation,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.noPendingInvitations,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, AppStrings strings, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(strings.errorLoadingInvitations(error.toString())),
      ),
    );
  }
}

/// Kort der viser en enkelt invitation med annullerings-handling
class _InvitationCard extends HookConsumerWidget {
  final int taskListId;
  final dynamic invitation;

  const _InvitationCard({
    required this.taskListId,
    required this.invitation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoading = useState(false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.mail_outline),
        ),
        title: Text(invitation.emailAddress),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildCancelButton(context, ref, strings, isLoading),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
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
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) {
    return Semantics(
      label: '${strings.cancelInvitation} ${invitation.emailAddress}',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.cancel),
        tooltip: strings.cancelInvitation,
        color: Colors.red,
        onPressed: isLoading.value
            ? null
            : () => _handleCancelInvitation(context, ref, strings, isLoading),
      ),
    );
  }

  Future<void> _handleCancelInvitation(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    final confirmed = await _showCancelInvitationConfirmation(context, strings);
    if (!confirmed) return;

    isLoading.value = true;
    HapticFeedback.heavyImpact();

    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .cancelInvitation(invitation.id);

      if (context.mounted) {
        _showCancelResult(context, ref, strings, success);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _showCancelInvitationConfirmation(
    BuildContext context,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.cancelInvitation),
            content: Text(strings.confirmCancelInvitation(invitation.emailAddress)),
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

  void _showCancelResult(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    bool success,
  ) {
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

    if (success) {
      ref.invalidate(taskListInvitationsProvider(taskListId));
    }
  }
}
