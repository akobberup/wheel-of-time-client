// =============================================================================
// Invitations Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/enums.dart';
import '../models/invitation.dart';
import '../providers/invitation_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';

/// Invitations skærm med varm, organisk æstetik.
///
/// Design: v1.0.0 - Bruger den valgte tema-farve, bløde kort,
/// og konsistent typografi.
class InvitationsScreen extends HookConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final seedColor = themeState.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final invitationsAsync = ref.watch(invitationProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      body: RefreshIndicator(
        color: seedColor,
        onRefresh: () => ref.read(invitationProvider.notifier).loadPendingInvitations(),
        child: CustomScrollView(
          slivers: [
            invitationsAsync.when(
              data: (invitations) => _buildInvitationsList(
                context, invitations, strings, seedColor, isDark,
              ),
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: seedColor),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _buildErrorState(context, error, strings, seedColor, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsList(
    BuildContext context,
    List<InvitationResponse> invitations,
    AppStrings strings,
    Color seedColor,
    bool isDark,
  ) {
    if (invitations.isEmpty) {
      return SliverFillRemaining(
        child: _EmptyInvitationsState(
          strings: strings,
          seedColor: seedColor,
          isDark: isDark,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InvitationCard(
              invitation: invitations[index],
              seedColor: seedColor,
              isDark: isDark,
            ),
          ),
          childCount: invitations.length,
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    AppStrings strings,
    Color seedColor,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.errorLoadingInvitations(error.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tom tilstand for ingen invitationer
class _EmptyInvitationsState extends StatelessWidget {
  final AppStrings strings;
  final Color seedColor;
  final bool isDark;

  const _EmptyInvitationsState({
    required this.strings,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: seedColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                size: 48,
                color: seedColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.noPendingInvitations,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.invitationsWillAppearHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kort der viser en enkelt invitation med accept/afvis handlinger
class _InvitationCard extends HookConsumerWidget {
  final InvitationResponse invitation;
  final Color seedColor;
  final bool isDark;

  const _InvitationCard({
    required this.invitation,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: seedColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: seedColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.taskListName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.invitationFrom}: ${invitation.initiatedByUserName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(strings),
            ],
          ),
          if (invitation.currentState == InvitationState.SENT) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: strings.declineInvitation,
                    icon: Icons.close_rounded,
                    isLoading: isLoadingDecline.value,
                    isOutlined: true,
                    color: Colors.red,
                    isDark: isDark,
                    onPressed: isLoadingAccept.value || isLoadingDecline.value
                        ? null
                        : () => _handleDecline(context, ref, strings, isLoadingDecline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: strings.acceptInvitation,
                    icon: Icons.check_rounded,
                    isLoading: isLoadingAccept.value,
                    isOutlined: false,
                    color: seedColor,
                    isDark: isDark,
                    onPressed: isLoadingAccept.value || isLoadingDecline.value
                        ? null
                        : () => _handleAccept(context, ref, strings, isLoadingAccept),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppStrings strings) {
    final state = invitation.currentState;
    final Color color;
    final IconData icon;
    final String label;

    switch (state) {
      case InvitationState.SENT:
      case InvitationState.PENDING:
        color = Colors.orange;
        icon = Icons.schedule_rounded;
        label = strings.pending;
      case InvitationState.ACCEPTED:
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        label = strings.accepted;
      case InvitationState.DECLINED:
        color = Colors.red;
        icon = Icons.cancel_rounded;
        label = strings.declined;
      case InvitationState.CANCELLED:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        label = strings.cancelled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    isLoading.value = true;
    try {
      await ref.read(invitationProvider.notifier).acceptInvitation(invitation.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.invitationAccepted),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleDecline(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.declineInvitation),
        content: Text(
          strings.declineInvitationConfirmation(invitation.taskListName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              strings.cancel,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              strings.declineInvitation,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await ref.read(invitationProvider.notifier).declineInvitation(invitation.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.invitationDeclined),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

/// Action button til accept/afvis
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isOutlined;
  final Color color;
  final bool isDark;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isOutlined,
    required this.color,
    required this.isDark,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isOutlined ? Colors.transparent : color,
          border: isOutlined
              ? Border.all(color: color.withOpacity(0.5), width: 1.5)
              : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isOutlined ? color : Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isOutlined ? color : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOutlined ? color : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
