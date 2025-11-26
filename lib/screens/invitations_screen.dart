import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/status_badge.dart';
import '../widgets/common/animated_card.dart';

/// Viser skærm med brugerens invitationer til opgavelister
class InvitationsScreen extends HookConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final invitationsAsync = ref.watch(invitationProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(invitationProvider.notifier).loadPendingInvitations(),
        child: invitationsAsync.when(
          data: (invitations) => _buildInvitationsList(invitations, strings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error, strings),
        ),
      ),
    );
  }

  Widget _buildInvitationsList(List<dynamic> invitations, AppStrings strings) {
    if (invitations.isEmpty) {
      return EmptyState(
        title: strings.noPendingInvitations,
        subtitle: strings.invitationsWillAppearHere,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitations.length,
      itemBuilder: (context, index) => _InvitationCard(invitation: invitations[index]),
    );
  }

  Widget _buildErrorState(Object error, AppStrings strings) {
    return Center(
      child: Text(strings.errorLoadingInvitations(error.toString())),
    );
  }
}

/// Kort der viser en enkelt invitation med accept/afvis handlinger
class _InvitationCard extends HookConsumerWidget {
  final dynamic invitation;

  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildLeadingIcon(context),
        title: Text(
          invitation.taskListName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildActions(
          context,
          ref,
          strings,
          isLoadingAccept,
          isLoadingDecline,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.list_alt,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text('${strings.invitationFrom}: ${invitation.initiatedByUserName}'),
        const SizedBox(height: 4),
        StatusBadge(
          icon: _getStateIcon(invitation.currentState),
          label: _getStateLabel(invitation.currentState, strings),
          color: _getStateColor(context, invitation.currentState),
        ),
      ],
    );
  }

  Widget? _buildActions(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoadingAccept,
    ValueNotifier<bool> isLoadingDecline,
  ) {
    if (invitation.currentState.name != 'PENDING') return null;

    return _InvitationActions(
      invitation: invitation,
      isLoadingAccept: isLoadingAccept,
      isLoadingDecline: isLoadingDecline,
    );
  }

  String _getStateLabel(dynamic state, AppStrings strings) {
    switch (state.name.toString()) {
      case 'SENT':
        return strings.pending;
      case 'ACCEPTED':
        return strings.accepted;
      case 'DECLINED':
        return strings.declined;
      default:
        return state.name.toString();
    }
  }

  IconData _getStateIcon(dynamic state) {
    switch (state.name.toString()) {
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

  Color _getStateColor(BuildContext context, dynamic state) {
    return state.name == 'SENT'
        ? Colors.orange
        : Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

/// Action buttons for accepting or declining an invitation
class _InvitationActions extends HookConsumerWidget {
  final dynamic invitation;
  final ValueNotifier<bool> isLoadingAccept;
  final ValueNotifier<bool> isLoadingDecline;

  const _InvitationActions({
    required this.invitation,
    required this.isLoadingAccept,
    required this.isLoadingDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isAnyLoading = isLoadingAccept.value || isLoadingDecline.value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          isLoading: isLoadingAccept.value,
          icon: Icons.check_circle,
          color: Colors.green,
          semanticLabel: '${strings.acceptInvitation} ${invitation.taskListName}',
          onPressed: isAnyLoading ? null : () => _handleAccept(context, ref, strings),
        ),
        _buildActionButton(
          isLoading: isLoadingDecline.value,
          icon: Icons.cancel,
          color: Colors.red,
          semanticLabel: '${strings.declineInvitation} ${invitation.taskListName}',
          onPressed: isAnyLoading ? null : () => _handleDecline(context, ref, strings),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required bool isLoading,
    required IconData icon,
    required Color color,
    required String semanticLabel,
    required VoidCallback? onPressed,
  }) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    isLoadingAccept.value = true;
    try {
      await ref.read(invitationProvider.notifier).acceptInvitation(invitation.id);
      if (context.mounted) {
        _showSnackBar(context, strings.invitationAccepted);
      }
    } finally {
      isLoadingAccept.value = false;
    }
  }

  Future<void> _handleDecline(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final confirmed = await _showDeclineConfirmationDialog(context, strings);
    if (confirmed != true) return;

    isLoadingDecline.value = true;
    try {
      await ref.read(invitationProvider.notifier).declineInvitation(invitation.id);
      if (context.mounted) {
        _showSnackBar(context, strings.invitationDeclined);
      }
    } finally {
      isLoadingDecline.value = false;
    }
  }

  Future<bool?> _showDeclineConfirmationDialog(
    BuildContext context,
    AppStrings strings,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.declineInvitation),
        content: Text(
          strings.declineInvitationConfirmation(invitation.taskListName),
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
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
