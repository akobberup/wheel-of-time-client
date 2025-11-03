import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification.dart';
import 'dart:developer' as developer;

/// Service for showing platform-standard notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._internal();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    try {
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = initialized ?? false;

      if (_initialized) {
        developer.log('Notification service initialized successfully', name: 'NotificationService');

        // Request permissions on iOS
        await _requestPermissions();
      } else {
        developer.log('Failed to initialize notification service', name: 'NotificationService');
      }
    } catch (e) {
      developer.log('Error initializing notifications: $e', name: 'NotificationService');
      _initialized = false;
    }
  }

  /// Request notification permissions (primarily for iOS)
  Future<void> _requestPermissions() async {
    if (_notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>() != null) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    if (_notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() != null) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}', name: 'NotificationService');
    // Navigation will be handled by the notification provider/screen
  }

  /// Show a notification for an app notification
  Future<void> showNotification(AppNotification notification) async {
    if (!_initialized) {
      developer.log('Cannot show notification - service not initialized', name: 'NotificationService');
      return;
    }

    final (title, body) = _getNotificationContent(notification);
    final id = notification.id.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'wheel_of_time_notifications',
      'Wheel of Time Notifications',
      channelDescription: 'Notifications for task lists, invitations, and tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    try {
      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: notification.id,
      );

      developer.log('Showed notification: $title - $body', name: 'NotificationService');
    } catch (e) {
      developer.log('Error showing notification: $e', name: 'NotificationService');
    }
  }

  /// Get notification title and body based on notification type
  (String, String) _getNotificationContent(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        final taskListName = notification.invitation?.taskListName ?? 'a task list';
        final fromUser = notification.invitation?.initiatedByUserName ?? 'Someone';
        return (
          'New Invitation',
          '$fromUser invited you to "$taskListName"',
        );

      case NotificationType.INVITATION_ACCEPTED:
        final taskListName = notification.invitation?.taskListName ?? 'your task list';
        final email = notification.invitation?.emailAddress ?? 'Someone';
        return (
          'Invitation Accepted',
          '$email accepted your invitation to "$taskListName"',
        );

      case NotificationType.INVITATION_DECLINED:
        final taskListName = notification.invitation?.taskListName ?? 'your task list';
        final email = notification.invitation?.emailAddress ?? 'Someone';
        return (
          'Invitation Declined',
          '$email declined your invitation to "$taskListName"',
        );

      case NotificationType.TASK_DUE:
        final taskName = notification.task?.name ?? 'A task';
        final taskListName = notification.task?.taskListName ?? 'your list';
        return (
          'Task Due',
          '"$taskName" in "$taskListName" is due',
        );
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(String notificationId) async {
    if (!_initialized) return;

    final id = notificationId.hashCode;
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;

    await _notifications.cancelAll();
  }
}
