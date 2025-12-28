import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../l10n/app_strings.dart';
import '../l10n/strings_da.dart';
import '../l10n/strings_en.dart';
import 'dart:developer' as developer;

/// Service for showing platform-standard notifications.
///
/// Denne service håndterer visning af lokale notifikationer på alle platforme.
/// Den understøtter lokalisering ved at hente brugerens sprogpræference fra
/// SharedPreferences, hvilket gør det muligt at vise notifikationer på det
/// korrekte sprog selv fra baggrundstasks uden adgang til BuildContext.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._internal();

  /// Henter AppStrings baseret på gemt sprogpræference.
  ///
  /// Læser sprogkode fra SharedPreferences og returnerer den tilsvarende
  /// strings-implementation. Fallback til dansk hvis ingen præference er gemt.
  Future<AppStrings> _getLocalizedStrings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('locale_language_code') ?? 'da';

      switch (languageCode) {
        case 'en':
          return StringsEn();
        case 'da':
        default:
          return StringsDa();
      }
    } catch (e) {
      developer.log('Error getting locale preference: $e', name: 'NotificationService');
      return StringsDa(); // Fallback til dansk
    }
  }

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

  /// Viser en notifikation for en app-notifikation.
  /// 
  /// Henter lokaliserede strings baseret på brugerens sprogpræference
  /// og viser notifikationen med korrekt titel og brødtekst.
  Future<void> showNotification(AppNotification notification) async {
    if (!_initialized) {
      developer.log('Cannot show notification - service not initialized', name: 'NotificationService');
      return;
    }

    final strings = await _getLocalizedStrings();
    final (title, body) = _getNotificationContent(notification, strings);
    final id = notification.id.hashCode;

    // Kanalnavnet er system-niveau og ændres ikke - det vises sjældent til brugeren
    const androidDetails = AndroidNotificationDetails(
      'aarshjulet_notifications',
      'Årshjulet Notifikationer',
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

  /// Returnerer lokaliseret titel og brødtekst baseret på notifikationstype.
  (String, String) _getNotificationContent(AppNotification notification, AppStrings strings) {
    switch (notification.type) {
      case NotificationType.INVITATION_RECEIVED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final fromUser = notification.invitation?.initiatedByUserName ?? '';
        return (
          strings.newInvitation,
          strings.notificationInvitationReceived(fromUser, taskListName),
        );

      case NotificationType.INVITATION_ACCEPTED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return (
          strings.invitationWasAccepted,
          strings.notificationInvitationAcceptedBody(email, taskListName),
        );

      case NotificationType.INVITATION_DECLINED:
        final taskListName = notification.invitation?.taskListName ?? '';
        final email = notification.invitation?.emailAddress ?? '';
        return (
          strings.invitationWasDeclined,
          strings.notificationInvitationDeclinedBody(email, taskListName),
        );

      case NotificationType.TASK_DUE:
        final taskName = notification.task?.name ?? '';
        final taskListName = notification.task?.taskListName ?? '';
        return (
          strings.taskDue,
          strings.notificationTaskDue(taskName, taskListName),
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
