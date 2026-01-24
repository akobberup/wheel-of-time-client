import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../models/enums.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';
import 'dart:developer' as developer;

/// Provider for the notification system
/// Aggregates notifications from multiple sources:
/// - Invitations received (SENT state)
/// - Invitations sent that were accepted/declined
/// - Tasks that are due
final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<AppNotification>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Set token on API service whenever auth state changes
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  final currentUserId = authState.user?.userId;

  return NotificationNotifier(apiService, currentUserId);
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final ApiService _apiService;
  final int? _currentUserId;
  final NotificationService _notificationService = NotificationService();
  bool _isFirstLoad = true;

  NotificationNotifier(
    this._apiService,
    this._currentUserId,
  ) : super(const AsyncValue.loading()) {
    _initializeNotificationService();
    loadNotifications();
  }

  /// Initialize the platform notification service
  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
      developer.log('Platform notification service initialized', name: 'NotificationNotifier');
    } catch (e) {
      developer.log('Error initializing notification service: $e', name: 'NotificationNotifier');
    }
  }

  /// Loads all notifications from various sources
  Future<void> loadNotifications() async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final notifications = <AppNotification>[];

      // 1. Load invitations received by the current user (pending)
      final receivedInvitations = await _apiService.getMyPendingInvitations();
      for (final invitation in receivedInvitations) {
        // Only show SENT invitations (not yet accepted/declined)
        if (invitation.currentState == InvitationState.SENT) {
          notifications.add(AppNotification.fromInvitationReceived(invitation));
        }
      }

      // 2. Load invitations sent by the current user
      if (_currentUserId != null) {
        final allMyInvitations = await _apiService.getMyInvitations();

        for (final invitation in allMyInvitations) {
          // Check if this invitation was initiated by the current user
          if (invitation.initiatedByUserId == _currentUserId) {
            if (invitation.currentState == InvitationState.ACCEPTED) {
              notifications.add(AppNotification.fromInvitationAccepted(invitation));
            } else if (invitation.currentState == InvitationState.DECLINED) {
              notifications.add(AppNotification.fromInvitationDeclined(invitation));
            }
          }
        }
      }

      // 3. Load tasks that are due
      final taskLists = await _apiService.getAllTaskLists();
      for (final taskList in taskLists) {
        final tasks = await _apiService.getTasksByTaskList(taskList.id, activeOnly: true);

        for (final task in tasks) {
          // Check if task is due (nextDueDate is today or in the past)
          if (task.nextDueDate != null && task.isActive) {
            final now = DateTime.now();
            final dueDate = task.nextDueDate!;
            final today = DateTime(now.year, now.month, now.day);
            final taskDueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

            // Task is due if the due date is today or in the past
            if (taskDueDay.isBefore(today) || taskDueDay.isAtSameMomentAs(today)) {
              notifications.add(AppNotification.fromTaskDue(task));
            }
          }
        }
      }

      // Sort notifications by timestamp (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Push notifications håndteres af backend via FCM - vi viser kun in-app liste her
      _isFirstLoad = false;

      // Tjek om notifier stadig er mounted før state opdateres
      if (mounted) {
        state = AsyncValue.data(notifications);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Get count of unread notifications
  int getUnreadCount() {
    return state.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    state.whenData((notifications) {
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = AsyncValue.data(updatedNotifications);
    });
  }

  /// Dismiss a notification (remove it from the list)
  Future<void> dismissNotification(String notificationId) async {
    // Cancel the platform notification (hvis den er vist via FCM)
    await _notificationService.cancelNotification(notificationId);

    state.whenData((notifications) {
      final updatedNotifications = notifications.where((n) => n.id != notificationId).toList();
      state = AsyncValue.data(updatedNotifications);
    });
  }
}

/// Provider for notification count
final notificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationProvider);

  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.length,
    orElse: () => 0,
  );
});
