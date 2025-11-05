import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/invitation_provider.dart';
import '../providers/task_list_provider.dart';
import '../models/notification.dart';
import '../l10n/app_strings.dart';
import 'main_navigation_screen.dart';

/// Screen displaying all notifications in one centralized location
class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, ref, notification),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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

String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
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
                _formatTimestamp(notification.timestamp),
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
