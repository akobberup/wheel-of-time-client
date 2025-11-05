import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_da.dart';

abstract class AppStrings {
  // App
  String get appTitle;

  // Login/Sign Up Screen
  String get welcomeBack;
  String get createAccount;
  String get name;
  String get email;
  String get password;
  String get pleaseEnterName;
  String get pleaseEnterEmail;
  String get pleaseEnterValidEmail;
  String get pleaseEnterPassword;
  String get passwordMinLength;
  String get signIn;
  String get signUp;
  String get forgotPassword;
  String get dontHaveAccount;
  String get alreadyHaveAccount;

  // Home Screen
  String get welcome;
  String get userId;

  // Forgot Password Screen
  String get forgotPasswordTitle;
  String get resetPassword;
  String get resetPasswordInstructions;
  String get sendResetLink;
  String get checkYourEmail;
  String emailResetSent(String email);
  String get backToLogin;

  // Reset Password Screen
  String get resetYourPassword;
  String get enterNewPassword;
  String get newPassword;
  String get confirmPassword;
  String get pleaseEnterNewPassword;
  String get pleaseConfirmPassword;
  String get passwordsDoNotMatch;
  String get passwordResetSuccessful;
  String get passwordResetSuccessMessage;
  String get goToLogin;

  // Error Messages
  String get registrationFailed;
  String get loginFailed;
  String networkError(String details);
  String get failedToSendResetEmail;
  String get failedToResetPassword;

  // Task Lists
  String get taskLists;
  String get createTaskList;
  String get editTaskList;
  String get deleteTaskList;
  String get noTaskLists;
  String get noTaskListsYet;
  String get createFirstTaskList;
  String get taskListCreated;
  String get taskListUpdated;
  String get taskListDeleted;

  // Tasks
  String get tasks;
  String get createTask;
  String get editTask;
  String get deleteTask;
  String get noTasks;
  String get addFirstTask;
  String get taskCreated;
  String get taskUpdated;
  String get taskDeleted;
  String get completeTask;
  String get taskCompleted;

  // Task Details
  String get taskName;
  String get description;
  String get descriptionOptional;
  String get repeat;
  String get everyNumber;
  String get firstRunDate;
  String get completionTime;

  // Repeat Units
  String get daily;
  String get weekly;
  String get monthly;
  String get yearly;

  // Invitations
  String get invitations;
  String get pendingInvitations;
  String get noPendingInvitations;
  String get invitationFrom;
  String get acceptInvitation;
  String get declineInvitation;
  String get accepted;
  String get declined;
  String get invitationAccepted;
  String get invitationDeclined;
  String get sendInvitation;
  String get invitationsWillAppearHere;

  // Members
  String get members;
  String get addMember;
  String get removeMember;
  String get changePermission;

  // Common
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get create;
  String get retry;
  String get error;
  String get loading;
  String get comment;
  String get commentOptional;
  String get logout;
  String get moreOptions;
  String get lists;
  String get complete;
  String get more;
  String get active;
  String get inactive;
  String get remove;
  String get invite;
  String get pending;

  // Confirmation messages
  String get confirmDeleteMessage;
  String confirmDeleteTask(String name);
  String confirmDeleteTaskList(String name);
  String confirmRemoveMember(String name);
  String confirmCancelInvitation(String email);

  // Success messages
  String get taskDeletedSuccess;
  String get taskListDeletedSuccess;
  String get memberRemovedSuccess;
  String get invitationCancelledSuccess;
  String get permissionUpdatedSuccess;
  String invitationSentTo(String email);

  // Error messages
  String get failedToDeleteTask;
  String get failedToDeleteTaskList;
  String get failedToUpdateTask;
  String get failedToCreateTask;
  String get failedToRemoveMember;
  String get failedToCancelInvitation;
  String get failedToUpdatePermission;
  String get failedToSendInvitation;
  String get pleaseEnterTaskName;
  String get pleaseEnterNumber;
  String get pleaseEnterValidNumber;
  String get pleaseEnterEmailAddress;
  String errorLoadingMembers(String error);
  String errorLoadingInvitations(String error);

  // Task list members
  String membersIn(String taskListName);
  String get cancelInvitation;
  String get cancelInvite;
  String get changePermissionLevel;
  String changePermissionFor(String userName);
  String get canEdit;
  String get canEditDescription;
  String get canView;
  String get canViewDescription;
  String get noMembers;
  String invitedBy(String userName);

  // Task details
  String tasksIn(String taskListName);
  String get alarmTimeOptional;
  String get noAlarmSet;
  String get completionWindowOptional;
  String get completionWindowHelper;
  String get inactiveTasksHidden;
  String dayStreak(int count);

  // Send invitation
  String inviteSomeoneTo(String taskListName);
  String get emailAddress;
  String get enterEmailToInvite;
  String get sendInvite;

  // Task fields
  String get taskListName;
  String get alarmTime;
  String get completionWindow;

  // Notifications
  String get notifications;
  String get noNotifications;
  String get allCaughtUp;
  String get notificationDismissed;
  String get newInvitation;
  String get invitationWasAccepted;
  String get invitationWasDeclined;
  String get taskDue;
  String get inList;
  String get refresh;
  String get failedToAcceptInvitation;
  String get failedToDeclineInvitation;

  // Time formatting
  String get justNow;
  String minutesAgo(int minutes);
  String hoursAgo(int hours);
  String daysAgo(int days);
  String get today;
  String get yesterday;
  String get older;

  // Upcoming Tasks
  String get upcomingTasks;
  String get noUpcomingTasks;
  String get allCaughtUpWithTasks;
  String get dueToday;
  String get dueTomorrow;
  String dueInDays(int days);
  String get overdue;
  String dueDaysAgo(int days);
  String get taskCompletedSuccess;
  String get streakContinued;
  String streakExtended(int count);
  String get failedToCompleteTask;
  String get completeEarlierTasksFirst;
  String get keepItGoing;
  String streakAtRisk(int count);

  // Task History
  String get taskHistory;
  String taskHistoryFor(String taskName);
  String get noCompletionsYet;
  String get noCompletionsYetDescription;
  String get completedBy;
  String completedOn(String date);
  String completedAt(String time);
  String get onTime;
  String get late;
  String get contributedToStreak;
  String get didNotContributeToStreak;
  String get withComment;
  String totalCompletions(int count);
  String get loadingHistory;
  String get errorLoadingHistory;
  String errorLoadingHistoryDetails(String error);
  String get filter;
  String get allTime;
  String get thisWeek;
  String get thisMonth;
  String get last3Months;

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'da':
        return StringsDa();
      case 'en':
      default:
        return StringsEn();
    }
  }
}
