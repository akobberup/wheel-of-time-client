// =============================================================================
// Notifications Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/invitation_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/theme_provider.dart';
import '../models/notification.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/skeleton_loader.dart';
import 'main_navigation_screen.dart';

/// Notifikations skærm med varm, organisk æstetik.
///
/// Design: v1.0.0 - Bruger den valgte tema-farve, bløde kort,
/// og konsistent typografi.
class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final themeState = ref.watch(themeProvider);
    final seedColor = themeState.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      body: RefreshIndicator(
        color: seedColor,
        onRefresh: () => _handleRefresh(ref),
        child: CustomScrollView(
          slivers: [
            _NotificationsAppBar(
              seedColor: seedColor,
              isDark: isDark,
              onRefresh: () => _handleRefresh(ref),
            ),
            notificationsAsync.when(
              data: (notifications) => _buildNotificationsList(
                context, ref, notifications, strings, seedColor, isDark,
              ),
              loading: () => const SliverFillRemaining(
                child: SkeletonListLoader(),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _buildErrorState(context, ref, error, strings, seedColor, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
    AppStrings strings,
    Color seedColor,
    bool isDark,
  ) {
    if (notifications.isEmpty) {
      return SliverFillRemaining(
        child: _EmptyNotificationsState(
          strings: strings,
          seedColor: seedColor,
          isDark: isDark,
        ),
      );
    }

    return _NotificationGroupedList(
      notifications: notifications,
      seedColor: seedColor,
      isDark: isDark,
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
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
              strings.error,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _handleRefresh(ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: seedColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: seedColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  strings.retry,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh(WidgetRef ref) async {
    await ref.read(notificationProvider.notifier).loadNotifications();
  }
}

/// Custom app bar til notifikationer
class _NotificationsAppBar extends StatelessWidget {
  final Color seedColor;
  final bool isDark;
  final VoidCallback onRefresh;

  const _NotificationsAppBar({
    required this.seedColor,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: seedColor),
          onPressed: onRefresh,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
        title: Text(
          strings.notifications,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Tom tilstand for ingen notifikationer
class _EmptyNotificationsState extends StatelessWidget {
  final AppStrings strings;
  final Color seedColor;
  final bool isDark;

  const _EmptyNotificationsState({
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
                Icons.notifications_none_rounded,
                size: 48,
                color: seedColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.noNotifications,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.allCaughtUp,
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

/// Widget der grupperer notifikationer i sektioner: I dag, I går, Ældre
class _NotificationGroupedList extends HookConsumerWidget {
  final List<AppNotification> notifications;
  final Color seedColor;
  final bool isDark;

  const _NotificationGroupedList({
    required this.notifications,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final groupedNotifications = _groupNotificationsByDate(notifications);

    final List<Widget> children = [];

    if (groupedNotifications.today.isNotEmpty) {
      children.add(_SectionHeader(title: strings.today, seedColor: seedColor));
      children.addAll(groupedNotifications.today.map((n) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _NotificationCard(
          notification: n,
          seedColor: seedColor,
          isDark: isDark,
        ),
      )));
      children.add(const SizedBox(height: 16));
    }

    if (groupedNotifications.yesterday.isNotEmpty) {
      children.add(_SectionHeader(title: strings.yesterday, seedColor: seedColor));
      children.addAll(groupedNotifications.yesterday.map((n) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _NotificationCard(
          notification: n,
          seedColor: seedColor,
          isDark: isDark,
        ),
      )));
      children.add(const SizedBox(height: 16));
    }

    if (groupedNotifications.older.isNotEmpty) {
      children.add(_SectionHeader(title: strings.older, seedColor: seedColor));
      children.addAll(groupedNotifications.older.map((n) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _NotificationCard(
          notification: n,
          seedColor: seedColor,
          isDark: isDark,
        ),
      )));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate(children),
      ),
    );
  }

  /// Grupperer notifikationer efter dato
  _GroupedNotifications _groupNotificationsByDate(List<AppNotification> notifications) {
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final older = <AppNotification>[];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    for (final notification in notifications) {
      final notifDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );
      final diff = todayDate.difference(notifDate).inDays;

      if (diff == 0) {
        today.add(notification);
      } else if (diff == 1) {
        yesterday.add(notification);
      } else {
        older.add(notification);
      }
    }

    return _GroupedNotifications(
      today: today,
      yesterday: yesterday,
      older: older,
    );
  }
}

/// Sektion header
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color seedColor;

  const _SectionHeader({required this.title, required this.seedColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: seedColor,
        ),
      ),
    );
  }
}

/// Data class for grupperede notifikationer
class _GroupedNotifications {
  final List<AppNotification> today;
  final List<AppNotification> yesterday;
  final List<AppNotification> older;

  const _GroupedNotifications({
    required this.today,
    required this.yesterday,
    required this.older,
  });
}

/// Kort der viser en enkelt notifikation med swipe-to-dismiss funktionalitet
class _NotificationCard extends HookConsumerWidget {
  final AppNotification notification;
  final Color seedColor;
  final bool isDark;

  const _NotificationCard({
    required this.notification,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDismissConfirmationDialog(context, strings),
      onDismissed: (direction) => _handleDismiss(context, ref, strings),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(context, ref),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: notification.isRead
                ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white)
                : (isDark ? seedColor.withOpacity(0.15) : seedColor.withOpacity(0.08)),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06))
                  : seedColor.withOpacity(0.2),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getNotificationTitle(strings),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: seedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getNotificationSubtitle(strings),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(strings),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ),
                    if (notification.type == NotificationType.INVITATION_RECEIVED) ...[
                      const SizedBox(height: 12),
                      _NotificationInvitationActions(
                        notification: notification,
                        seedColor: seedColor,
                        isDark: isDark,
                        isLoadingAccept: isLoadingAccept,
                        isLoadingDecline: isLoadingDecline,
                      ),
                    ],
                  ],
                ),
              ),
              if (notification.type == NotificationType.TASK_DUE)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    final (Color color, IconData icon) = switch (notification.type) {
      NotificationType.INVITATION_RECEIVED => (Colors.blue, Icons.mail_rounded),
      NotificationType.INVITATION_ACCEPTED => (Colors.green, Icons.check_circle_rounded),
      NotificationType.INVITATION_DECLINED => (Colors.orange, Icons.cancel_rounded),
      NotificationType.TASK_DUE => (seedColor, Icons.task_alt_rounded),
      NotificationType.CHEER_RECEIVED => (Colors.amber, Icons.celebration_rounded),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Future<bool?> _showDismissConfirmationDialog(BuildContext context, AppStrings strings) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.dismissNotification),
        content: Text(strings.confirmDismissNotification),
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
              strings.dismiss,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDismiss(BuildContext context, WidgetRef ref, AppStrings strings) {
    ref.read(notificationProvider.notifier).dismissNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.notificationDismissed),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref) {
    ref.read(notificationProvider.notifier).markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.TASK_DUE:
        ref.read(selectedIndexProvider.notifier).state = 1;
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  String _getNotificationTitle(AppStrings strings) {
    return switch (notification.type) {
      NotificationType.INVITATION_RECEIVED => strings.newInvitation,
      NotificationType.INVITATION_ACCEPTED => strings.invitationWasAccepted,
      NotificationType.INVITATION_DECLINED => strings.invitationWasDeclined,
      NotificationType.TASK_DUE => strings.taskDue,
      NotificationType.CHEER_RECEIVED => strings.pushCheers,
    };
  }

  String _getNotificationSubtitle(AppStrings strings) {
    return switch (notification.type) {
      NotificationType.INVITATION_RECEIVED => () {
        final taskListName = notification.invitation?.taskListName ?? '';
        final fromUser = notification.invitation?.initiatedByUserName ?? '';
        return '${strings.invitationFrom}: $fromUser - "$taskListName"';
      }(),
      NotificationType.INVITATION_ACCEPTED => () {
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return '$email - "$taskListName"';
      }(),
      NotificationType.INVITATION_DECLINED => () {
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return '$email - "$taskListName"';
      }(),
      NotificationType.TASK_DUE => () {
        final taskName = notification.task?.name ?? '';
        final taskListName = notification.task?.taskListName ?? '';
        return '"$taskName" ${strings.inList} "$taskListName"';
      }(),
      NotificationType.CHEER_RECEIVED => '',
    };
  }

  String _formatTimestamp(AppStrings strings) {
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);

    if (difference.inMinutes < 1) {
      return strings.justNow;
    } else if (difference.inHours < 1) {
      return strings.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return strings.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return strings.daysAgo(difference.inDays);
    } else {
      return '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}';
    }
  }
}

/// Action buttons for accepting or declining an invitation notification
class _NotificationInvitationActions extends HookConsumerWidget {
  final AppNotification notification;
  final Color seedColor;
  final bool isDark;
  final ValueNotifier<bool> isLoadingAccept;
  final ValueNotifier<bool> isLoadingDecline;

  const _NotificationInvitationActions({
    required this.notification,
    required this.seedColor,
    required this.isDark,
    required this.isLoadingAccept,
    required this.isLoadingDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isAnyLoading = isLoadingAccept.value || isLoadingDecline.value;

    return Row(
      children: [
        Expanded(
          child: _MiniActionButton(
            label: strings.declineInvitation,
            icon: Icons.close_rounded,
            isLoading: isLoadingDecline.value,
            isOutlined: true,
            color: Colors.red,
            isDark: isDark,
            onPressed: isAnyLoading ? null : () => _handleDecline(context, ref, strings),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniActionButton(
            label: strings.acceptInvitation,
            icon: Icons.check_rounded,
            isLoading: isLoadingAccept.value,
            isOutlined: false,
            color: seedColor,
            isDark: isDark,
            onPressed: isAnyLoading ? null : () => _handleAccept(context, ref, strings),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    if (notification.invitation == null) return;

    HapticFeedback.mediumImpact();
    isLoadingAccept.value = true;
    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .acceptInvitation(notification.invitation!.id);

      if (!context.mounted) return;

      if (success) {
        await ref.read(notificationProvider.notifier).dismissNotification(notification.id);
        await ref.read(taskListProvider.notifier).loadAllTaskLists();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.invitationAccepted),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToAcceptInvitation),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
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
    if (notification.invitation == null) return;

    HapticFeedback.mediumImpact();
    isLoadingDecline.value = true;
    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .declineInvitation(notification.invitation!.id);

      if (!context.mounted) return;

      if (success) {
        await ref.read(notificationProvider.notifier).dismissNotification(notification.id);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.invitationDeclined),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToDeclineInvitation),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      isLoadingDecline.value = false;
    }
  }
}

/// Mini action button til notifikations-kort
class _MiniActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isOutlined;
  final Color color;
  final bool isDark;
  final VoidCallback? onPressed;

  const _MiniActionButton({
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
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isOutlined ? Colors.transparent : color,
          border: isOutlined
              ? Border.all(color: color.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
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
                      size: 16,
                      color: isOutlined ? color : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
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
