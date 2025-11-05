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

/// Screen displaying all notifications in one centralized location
class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

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

  Widget _buildGroupedNotifications(BuildContext context, WidgetRef ref, List<AppNotification> notifications, AppStrings strings) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionHeader(context, strings.today),
          ...today.map((n) => _NotificationCard(
            notification: n,
            onTap: () => _handleNotificationTap(context, ref, n),
          )),
          const SizedBox(height: 16),
        ],
        if (yesterday.isNotEmpty) ...[
          _buildSectionHeader(context, strings.yesterday),
          ...yesterday.map((n) => _NotificationCard(
            notification: n,
            onTap: () => _handleNotificationTap(context, ref, n),
          )),
          const SizedBox(height: 16),
        ],
        if (older.isNotEmpty) ...[
          _buildSectionHeader(context, strings.older),
          ...older.map((n) => _NotificationCard(
            notification: n,
            onTap: () => _handleNotificationTap(context, ref, n),
          )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refresh,
            onPressed: () {
              ref.read(notificationProvider.notifier).loadNotifications();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationProvider.notifier).loadNotifications();
        },
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context, strings);
            }

            return _buildGroupedNotifications(context, ref, notifications, strings);
          },
          loading: () => const SkeletonListLoader(),
          error: (error, stack) => Center(
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
                  onPressed: () {
                    ref.read(notificationProvider.notifier).loadNotifications();
                  },
                  child: Text(strings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }


  void _handleNotificationTap(BuildContext context, WidgetRef ref, AppNotification notification) {
    // Mark notification as read when tapped
    ref.read(notificationProvider.notifier).markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.TASK_DUE:
        // Navigate to the Upcoming Tasks tab (index 1) where users can complete tasks
        ref.read(selectedIndexProvider.notifier).state = 1;
        Navigator.of(context).pop(); // Return to main navigation screen
        break;
      default:
        // For other notification types, tapping doesn't navigate
        break;
    }
  }
}

// Helper functions for notification display
Widget _getNotificationIcon(AppNotification notification) {
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

String _getNotificationTitle(AppNotification notification, AppStrings strings) {
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

String _getNotificationSubtitle(AppNotification notification, AppStrings strings) {
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

String _formatTimestamp(DateTime timestamp, AppStrings strings) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return strings.justNow;
  } else if (difference.inHours < 1) {
    return strings.minutesAgo(difference.inMinutes);
  } else if (difference.inDays < 1) {
    return strings.hoursAgo(difference.inHours);
  } else if (difference.inDays < 7) {
    return strings.daysAgo(difference.inDays);
  } else {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

/// Separate widget for each notification card to manage its own loading state
class _NotificationCard extends HookConsumerWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoadingAccept = useState(false);
    final isLoadingDecline = useState(false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Add light blue background for unread notifications
      color: notification.isRead ? null : Colors.blue.shade50,
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          // For notification dismissal, we use a simple inline confirmation
          // rather than the full contextual dialog since it's a lightweight action
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(strings.dismissNotification),
              content: Text('Are you sure you want to dismiss this notification?'),
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
        },
        onDismissed: (direction) {
          ref.read(notificationProvider.notifier).dismissNotification(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.notificationDismissed)),
          );
        },
        child: ListTile(
          leading: notification.isRead
              ? _getNotificationIcon(notification)
              : Badge(
                  child: _getNotificationIcon(notification),
                ),
          title: Text(_getNotificationTitle(notification, strings)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(_getNotificationSubtitle(notification, strings)),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp, strings),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: _buildNotificationActions(
            context,
            ref,
            notification,
            strings,
            isLoadingAccept,
            isLoadingDecline,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget? _buildNotificationActions(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
    AppStrings strings,
    ValueNotifier<bool> isLoadingAccept,
    ValueNotifier<bool> isLoadingDecline,
  ) {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        return Row(
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
                    tooltip: strings.acceptInvitation,
                    onPressed: (isLoadingAccept.value || isLoadingDecline.value)
                        ? null
                        : () => _handleAcceptInvitation(
                            context, ref, notification, strings, isLoadingAccept),
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
                    tooltip: strings.declineInvitation,
                    onPressed: (isLoadingAccept.value || isLoadingDecline.value)
                        ? null
                        : () => _handleDeclineInvitation(
                            context, ref, notification, strings, isLoadingDecline),
                  ),
          ],
        );
      case NotificationType.TASK_DUE:
        return const Icon(Icons.chevron_right);
      default:
        return null;
    }
  }

  Future<void> _handleAcceptInvitation(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    if (notification.invitation == null) return;

    HapticFeedback.mediumImpact();
    isLoading.value = true;
    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .acceptInvitation(notification.invitation!.id);

      if (context.mounted) {
        if (success) {
          // Dismiss the notification
          await ref.read(notificationProvider.notifier).dismissNotification(notification.id);

          // Refresh task lists to show the newly joined list
          await ref.read(taskListProvider.notifier).loadAllTaskLists();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.invitationAccepted),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.failedToAcceptInvitation),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleDeclineInvitation(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    if (notification.invitation == null) return;

    HapticFeedback.mediumImpact();
    isLoading.value = true;
    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .declineInvitation(notification.invitation!.id);

      if (context.mounted) {
        if (success) {
          // Dismiss the notification
          await ref.read(notificationProvider.notifier).dismissNotification(notification.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.invitationDeclined),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.failedToDeclineInvitation),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
