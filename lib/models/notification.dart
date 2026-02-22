import 'invitation.dart';
import 'task.dart';

/// Enum representing the different types of notifications
enum NotificationType {
  /// When someone invites you to a task list
  INVITATION_RECEIVED,
  /// When someone accepts your invitation
  INVITATION_ACCEPTED,
  /// When someone declines your invitation
  INVITATION_DECLINED,
  /// When a task is due to be completed
  TASK_DUE,
  /// Når nogen hepper på din fuldførte opgave
  CHEER_RECEIVED,
}

/// Unified notification model that wraps different notification sources
class AppNotification {
  final String id;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  // Optional data depending on notification type
  final InvitationResponse? invitation;
  final TaskResponse? task;

  AppNotification({
    required this.id,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.invitation,
    this.task,
  });

  /// Creates a notification from an invitation received
  factory AppNotification.fromInvitationReceived(InvitationResponse invitation) {
    return AppNotification(
      id: 'inv_received_${invitation.id}',
      type: NotificationType.INVITATION_RECEIVED,
      timestamp: invitation.currentStateDate,
      invitation: invitation,
    );
  }

  /// Creates a notification from an accepted invitation
  factory AppNotification.fromInvitationAccepted(InvitationResponse invitation) {
    return AppNotification(
      id: 'inv_accepted_${invitation.id}',
      type: NotificationType.INVITATION_ACCEPTED,
      timestamp: invitation.currentStateDate,
      invitation: invitation,
    );
  }

  /// Creates a notification from a declined invitation
  factory AppNotification.fromInvitationDeclined(InvitationResponse invitation) {
    return AppNotification(
      id: 'inv_declined_${invitation.id}',
      type: NotificationType.INVITATION_DECLINED,
      timestamp: invitation.currentStateDate,
      invitation: invitation,
    );
  }

  /// Creates a notification from a due task
  factory AppNotification.fromTaskDue(TaskResponse task) {
    return AppNotification(
      id: 'task_due_${task.id}',
      type: NotificationType.TASK_DUE,
      timestamp: task.nextDueDate ?? DateTime.now(),
      task: task,
    );
  }

  /// Copy with method to update notification
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    InvitationResponse? invitation,
    TaskResponse? task,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      invitation: invitation ?? this.invitation,
      task: task ?? this.task,
    );
  }
}
