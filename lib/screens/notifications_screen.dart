import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/invitation_provider.dart';
import '../providers/task_list_provider.dart';
import '../models/notification.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/skeleton_loader.dart';
import 'main_navigation_screen.dart';

/// Viser skærm med alle notifikationer samlet ét sted
class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref, strings),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(ref),
        child: notificationsAsync.when(
          data: (notifications) => _buildNotificationsList(context, ref, notifications, strings),
          loading: () => const SkeletonListLoader(),
          error: (error, stack) => _buildErrorState(context, ref, error, strings),
        ),
      ),
    );
  }

  /// Bygger app bar med refresh knap
  AppBar _buildAppBar(BuildContext context, WidgetRef ref, AppStrings strings) {
    return AppBar(
      title: Text(strings.notifications),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: strings.refresh,
          onPressed: () => _handleRefresh(ref),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
    AppStrings strings,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context, strings);
    }

    return _NotificationGroupedList(notifications: notifications);
  }

  Widget _buildEmptyState(BuildContext context, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          const SizedBox(height: 16),
          Text(
            strings.noNotifications,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.allCaughtUp,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppStrings strings,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(strings.error),
          const SizedBox(height: 8),
          Text('$error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _handleRefresh(ref),
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh(WidgetRef ref) async {
    await ref.read(notificationProvider.notifier).loadNotifications();
  }
}

/// Widget der grupperer notifikationer i sektioner: I dag, I går, Ældre
class _NotificationGroupedList extends HookConsumerWidget {
  final List<AppNotification> notifications;

  const _NotificationGroupedList({required this.notifications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final groupedNotifications = _groupNotificationsByDate(notifications);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (groupedNotifications.today.isNotEmpty) ...[
          _buildSectionHeader(context, strings.today),
          ...groupedNotifications.today.map((n) => _NotificationCard(notification: n)),
          const SizedBox(height: 16),
        ],
        if (groupedNotifications.yesterday.isNotEmpty) ...[
          _buildSectionHeader(context, strings.yesterday),
          ...groupedNotifications.yesterday.map((n) => _NotificationCard(notification: n)),
          const SizedBox(height: 16),
        ],
        if (groupedNotifications.older.isNotEmpty) ...[
          _buildSectionHeader(context, strings.older),
          ...groupedNotifications.older.map((n) => _NotificationCard(notification: n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : Colors.blue.shade50,
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        confirmDismiss: (direction) => _showDismissConfirmationDialog(context, strings),
        onDismissed: (direction) => _handleDismiss(context, ref, strings),
        child: ListTile(
          leading: _buildLeadingIcon(),
          title: Text(_getNotificationTitle(strings)),
          subtitle: _buildSubtitle(context, strings),
          trailing: _buildTrailingWidget(
            context,
            ref,
            strings,
            isLoadingAccept,
            isLoadingDecline,
          ),
          onTap: () => _handleNotificationTap(context, ref),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildLeadingIcon() {
    final icon = _getNotificationIcon();
    return notification.isRead ? icon : Badge(child: icon);
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(_getNotificationSubtitle(strings)),
        const SizedBox(height: 4),
        Text(
          _formatTimestamp(strings),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget? _buildTrailingWidget(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoadingAccept,
    ValueNotifier<bool> isLoadingDecline,
  ) {
    if (notification.type == NotificationType.INVITATION_RECEIVED) {
      return _NotificationInvitationActions(
        notification: notification,
        isLoadingAccept: isLoadingAccept,
        isLoadingDecline: isLoadingDecline,
      );
    } else if (notification.type == NotificationType.TASK_DUE) {
      return const Icon(Icons.chevron_right);
    }
    return null;
  }

  Future<bool?> _showDismissConfirmationDialog(BuildContext context, AppStrings strings) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.dismissNotification),
        content: Text(strings.confirmDismissNotification),
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
            child: Text(strings.dismiss),
          ),
        ],
      ),
    );
  }

  void _handleDismiss(BuildContext context, WidgetRef ref, AppStrings strings) {
    ref.read(notificationProvider.notifier).dismissNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.notificationDismissed)),
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

  Widget _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.mail, color: Colors.white),
        );
      case NotificationType.INVITATION_ACCEPTED:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle, color: Colors.white),
        );
      case NotificationType.INVITATION_DECLINED:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.cancel, color: Colors.white),
        );
      case NotificationType.TASK_DUE:
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.task_alt, color: Colors.white),
        );
    }
  }

  String _getNotificationTitle(AppStrings strings) {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        return strings.newInvitation;
      case NotificationType.INVITATION_ACCEPTED:
        return strings.invitationWasAccepted;
      case NotificationType.INVITATION_DECLINED:
        return strings.invitationWasDeclined;
      case NotificationType.TASK_DUE:
        return strings.taskDue;
    }
  }

  String _getNotificationSubtitle(AppStrings strings) {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final fromUser = notification.invitation?.initiatedByUserName ?? '';
        return '${strings.invitationFrom}: $fromUser - "$taskListName"';

      case NotificationType.INVITATION_ACCEPTED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return '$email - "$taskListName"';

      case NotificationType.INVITATION_DECLINED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return '$email - "$taskListName"';

      case NotificationType.TASK_DUE:
        final taskName = notification.task?.name ?? '';
        final taskListName = notification.task?.taskListName ?? '';
        return '"$taskName" ${strings.inList} "$taskListName"';
    }
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
  final ValueNotifier<bool> isLoadingAccept;
  final ValueNotifier<bool> isLoadingDecline;

  const _NotificationInvitationActions({
    required this.notification,
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
          tooltip: strings.acceptInvitation,
          onPressed: isAnyLoading ? null : () => _handleAccept(context, ref, strings),
        ),
        _buildActionButton(
          isLoading: isLoadingDecline.value,
          icon: Icons.cancel,
          color: Colors.red,
          tooltip: strings.declineInvitation,
          onPressed: isAnyLoading ? null : () => _handleDecline(context, ref, strings),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required bool isLoading,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
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
        _showSnackBar(
          context,
          strings.invitationAccepted,
          backgroundColor: Colors.green,
        );
      } else {
        _showSnackBar(
          context,
          strings.failedToAcceptInvitation,
          backgroundColor: Colors.red,
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
        _showSnackBar(
          context,
          strings.invitationDeclined,
          backgroundColor: Colors.orange,
        );
      } else {
        _showSnackBar(
          context,
          strings.failedToDeclineInvitation,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      isLoadingDecline.value = false;
    }
  }

  void _showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
