import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../models/enums.dart';
import '../models/task.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service til håndtering af baggrundstasks på mobile platforme.
///
/// Denne service anvender WorkManager til at planlægge periodiske checks for
/// nye notifikationer, selv når appen ikke kører i forgrunden. Background tasks
/// køres kun på Android og iOS - web og desktop platforme understøttes ikke.
///
/// Baggrundstasks checker for tre typer notifikationer:
/// - Modtagne invitationer fra andre brugere
/// - Accepterede/afviste invitationer man selv har sendt
/// - Opgaver der forfalder i dag eller er overskredet
class BackgroundTaskService {
  // WorkManager task identifiers
  static const String _taskName = 'notificationCheckTask';
  static const String _uniqueName = 'wheelOfTimeNotificationCheck';

  // Configuration constants
  static const int _notificationCheckIntervalMinutes = 30;
  static const int _maxSeenNotifications = 100;

  /// Initialiserer WorkManager og registrerer periodisk background task.
  ///
  /// Denne metode skal kaldes ved app-start for at aktivere automatisk
  /// notifikation-check i baggrunden. På web og desktop platforme gør
  /// metoden intet, da WorkManager kun understøttes på mobile.
  ///
  /// Background tasken kører hver 30. minut og kræver netværksforbindelse
  /// samt at batteriniveauet ikke er kritisk lavt.
  static Future<void> initialize() async {
    // WorkManager understøttes kun på mobile platforme
    if (kIsWeb) {
      developer.log('Skipping WorkManager initialization on web', name: 'BackgroundTaskService');
      return;
    }

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // Registrer periodisk notifikations-check
      // Android kræver minimum 15 minutters interval, vi bruger 30 minutter
      await Workmanager().registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: const Duration(minutes: _notificationCheckIntervalMinutes),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      developer.log('WorkManager initialized successfully', name: 'BackgroundTaskService');
    } catch (e) {
      developer.log('Error initializing WorkManager: $e', name: 'BackgroundTaskService');
    }
  }

  /// Annullerer alle registrerede baggrundstasks.
  ///
  /// Kaldes typisk ved logout for at stoppe automatiske notifikations-checks.
  static Future<void> cancel() async {
    if (kIsWeb) return;

    try {
      await Workmanager().cancelAll();
      developer.log('All background tasks cancelled', name: 'BackgroundTaskService');
    } catch (e) {
      developer.log('Error cancelling background tasks: $e', name: 'BackgroundTaskService');
    }
  }
}

/// Callback dispatcher der eksekveres i baggrunden af WorkManager.
///
/// Dette er entry point for baggrundstasks og kører i en separat isolate.
/// Metoden henter brugerens auth-data, initialiserer nødvendige services,
/// og checker for nye notifikationer der skal vises til brugeren.
///
/// Returnerer true hvis tasken lykkedes, false ved fejl.
/// Ved manglende auth-data returneres true for at undgå gentagne fejl.
///
/// @pragma('vm:entry-point') er påkrævet for at Dart ikke tree-shaker
/// metoden væk ved compilation, da den kaldes af native platform kode.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    developer.log('Background task started: $task', name: 'BackgroundTaskService');

    try {
      // Hent autentificeringsdata - hvis ikke tilgængelig, skip tasken
      final token = await _retrieveAuthTokenFromStorage();
      if (token == null) {
        developer.log('No auth token found, skipping notification check', name: 'BackgroundTaskService');
        return Future.value(true);
      }

      final userId = await _retrieveUserIdFromPreferences();
      if (userId == null) {
        developer.log('No user ID found, skipping notification check', name: 'BackgroundTaskService');
        return Future.value(true);
      }

      // Initialiser services med authentication
      final apiService = ApiService();
      apiService.setToken(token);

      final notificationService = NotificationService();
      await notificationService.initialize();

      // Check for nye notifikationer og vis dem
      await _fetchAndDisplayNewNotifications(apiService, notificationService, userId);

      developer.log('Background task completed successfully', name: 'BackgroundTaskService');
      return Future.value(true);
    } catch (e) {
      developer.log('Error in background task: $e', name: 'BackgroundTaskService');
      return Future.value(false);
    }
  });
}

/// Henter gemt autentificerings-token fra platform-specifik storage.
///
/// På mobile platforme læses token fra FlutterSecureStorage (krypteret).
/// På web læses fra SharedPreferences (browser local storage).
/// Returnerer null hvis token ikke findes eller ved læsefejl.
Future<String?> _retrieveAuthTokenFromStorage() async {
  try {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      const storage = FlutterSecureStorage();
      return await storage.read(key: 'auth_token');
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  } catch (e) {
    developer.log('Error retrieving stored token: $e', name: 'BackgroundTaskService');
    return null;
  }
}

/// Henter gemt bruger-ID fra SharedPreferences.
///
/// User ID gemmes i SharedPreferences (også på mobile) fordi background tasks
/// ikke kan tilgå FlutterSecureStorage. Dette er en kendt begrænsning i
/// WorkManager's isolate-baserede execution model.
/// Returnerer null hvis ID ikke findes eller ved læsefejl.
Future<int?> _retrieveUserIdFromPreferences() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  } catch (e) {
    developer.log('Error retrieving stored user ID: $e', name: 'BackgroundTaskService');
    return null;
  }
}

/// Henter og viser nye notifikationer til brugeren.
///
/// Checker tre typer notifikationer:
/// 1. Nye invitationer fra andre brugere
/// 2. Svar på egne invitationer (accepteret/afvist)
/// 3. Opgaver der forfalder i dag eller er overskredet
///
/// Filtrerer allerede viste notifikationer ved at sammenligne med tidligere
/// viste notification IDs gemt i SharedPreferences. Begrænser historik til
/// de seneste 100 notifikationer for at undgå at fylde storage over tid.
Future<void> _fetchAndDisplayNewNotifications(
  ApiService apiService,
  NotificationService notificationService,
  int userId,
) async {
  final allNotifications = <AppNotification>[];

  // Hent alle tre typer notifikationer parallelt for bedre performance
  final results = await Future.wait([
    _loadInvitationReceivedNotifications(apiService),
    _loadInvitationResponseNotifications(apiService, userId),
    _loadTaskDueNotifications(apiService),
  ]);

  allNotifications.addAll(results[0]);
  allNotifications.addAll(results[1]);
  allNotifications.addAll(results[2]);

  // Filtrer kun nye notifikationer (ikke tidligere vist)
  final unseenNotifications = await _filterUnseenNotifications(allNotifications);

  developer.log('Found ${unseenNotifications.length} new notifications to show', name: 'BackgroundTaskService');

  // Vis notifikationer til brugeren
  for (final notification in unseenNotifications) {
    await notificationService.showNotification(notification);
  }

  // Gem opdaterede seen IDs for fremtidige checks
  await _updateSeenNotificationIds(unseenNotifications);
}

/// Henter notifikationer for modtagne invitationer i SENT state.
///
/// Returnerer kun invitationer der afventer brugerens respons.
Future<List<AppNotification>> _loadInvitationReceivedNotifications(ApiService apiService) async {
  final notifications = <AppNotification>[];
  final receivedInvitations = await apiService.getMyPendingInvitations();

  for (final invitation in receivedInvitations) {
    // Kun vis invitationer der er sendt og afventer svar
    if (invitation.currentState == InvitationState.SENT) {
      notifications.add(AppNotification.fromInvitationReceived(invitation));
    }
  }

  return notifications;
}

/// Henter notifikationer for svar på egne sendte invitationer.
///
/// Checker alle brugerens invitationer og returnerer notifikationer
/// for dem der er blevet accepteret eller afvist af modtageren.
Future<List<AppNotification>> _loadInvitationResponseNotifications(
  ApiService apiService,
  int userId,
) async {
  final notifications = <AppNotification>[];
  final allMyInvitations = await apiService.getMyInvitations();

  for (final invitation in allMyInvitations) {
    // Kun check invitationer brugeren selv har sendt
    if (invitation.initiatedByUserId == userId) {
      if (invitation.currentState == InvitationState.ACCEPTED) {
        notifications.add(AppNotification.fromInvitationAccepted(invitation));
      } else if (invitation.currentState == InvitationState.DECLINED) {
        notifications.add(AppNotification.fromInvitationDeclined(invitation));
      }
    }
  }

  return notifications;
}

/// Henter notifikationer for opgaver der forfalder i dag eller er overskredet.
///
/// Gennemgår alle task lists og deres aktive opgaver, og returnerer
/// notifikationer for opgaver hvor forfaldsdato er i dag eller tidligere.
Future<List<AppNotification>> _loadTaskDueNotifications(ApiService apiService) async {
  final notifications = <AppNotification>[];
  final taskLists = await apiService.getAllTaskLists();

  for (final taskList in taskLists) {
    final tasks = await apiService.getTasksByTaskList(taskList.id, activeOnly: true);

    for (final task in tasks) {
      if (_isTaskDueToday(task)) {
        notifications.add(AppNotification.fromTaskDue(task));
      }
    }
  }

  return notifications;
}

/// Tjekker om en opgave forfalder i dag eller er overskredet.
///
/// Sammenligner opgavens forfaldsdato med dagens dato (uden tid).
/// Returnerer true hvis opgaven er aktiv og forfalder i dag eller tidligere.
bool _isTaskDueToday(Task task) {
  if (task.nextDueDate == null || !task.isActive) {
    return false;
  }

  final now = DateTime.now();
  final dueDate = task.nextDueDate!;

  // Sammenlign kun datoer uden tidspunkt for at matche hele dagen
  final today = DateTime(now.year, now.month, now.day);
  final taskDueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

  return taskDueDay.isBefore(today) || taskDueDay.isAtSameMomentAs(today);
}

/// Filtrerer notifikationer og returnerer kun dem der ikke er vist før.
///
/// Sammenligner med liste af tidligere viste notification IDs gemt i
/// SharedPreferences. Returnerer kun notifikationer med nye IDs.
Future<List<AppNotification>> _filterUnseenNotifications(
  List<AppNotification> allNotifications,
) async {
  final prefs = await SharedPreferences.getInstance();
  final previouslyShownIds = prefs.getStringList('seen_notification_ids') ?? [];

  return allNotifications
      .where((notification) => !previouslyShownIds.contains(notification.id))
      .toList();
}

/// Opdaterer listen af viste notification IDs i SharedPreferences.
///
/// Tilføjer nye notification IDs til historikken og begrænser listen til
/// de seneste 100 IDs for at undgå at fylde storage over tid. Ældre
/// notifikationer vil derfor kunne vises igen efter 100 nye notifikationer,
/// men dette anses for acceptabelt givet den typiske notifikationsfrekvens.
Future<void> _updateSeenNotificationIds(List<AppNotification> newNotifications) async {
  final prefs = await SharedPreferences.getInstance();
  final previouslyShownIds = prefs.getStringList('seen_notification_ids') ?? [];

  // Tilføj nye IDs til eksisterende liste
  final allSeenIds = [
    ...previouslyShownIds,
    ...newNotifications.map((n) => n.id),
  ];

  // Behold kun de seneste 100 for at spare storage
  final mostRecentSeenIds = allSeenIds.length > BackgroundTaskService._maxSeenNotifications
      ? allSeenIds.sublist(allSeenIds.length - BackgroundTaskService._maxSeenNotifications)
      : allSeenIds;

  await prefs.setStringList('seen_notification_ids', mostRecentSeenIds);
}
