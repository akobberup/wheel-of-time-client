import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_da.dart';
import '../services/api_service.dart';

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
  String get taskListDescription;
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
  String get taskDescription;
  String get editTask;
  String get deleteTask;
  String get noTasks;
  String get addFirstTask;
  String get taskCreated;
  String get taskUpdated;
  String get taskDeleted;
  String get completeTask;
  String get taskCompleted;
  String timesCompleted(int count);

  // Task Details
  String get taskName;
  String get description;
  String get descriptionOptional;
  String get repeat;
  String get everyNumber;
  String get firstRunDate;
  String get completionTime;
  String get showOptionalDetails;
  String get hideOptionalDetails;

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
  String declineInvitationConfirmation(String taskListName);
  String get accepted;
  String get declined;
  String get cancelled;
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
  String get settings;
  String get lists;
  String get complete;
  String get more;
  String get active;
  String get inactive;
  String get remove;
  String get invite;
  String get pending;
  String get completed;
  String get skipped;

  // Confirmation messages
  String get confirmDeleteMessage;
  String confirmDeleteTask(String name);
  String confirmDeleteTaskList(String name);
  String get confirmDeleteTaskListEmpty;
  String confirmDeleteTaskWithStreak(String name, int streakCount, int completions);
  String confirmDeleteTaskNoStreak(String name, int completions);
  String confirmRemoveMember(String name);
  String confirmCancelInvitation(String email);

  // Success messages
  String get taskDeletedSuccess;
  String get taskListDeletedSuccess;

  // Deletion context messages
  String get taskSafeToDelete;
  String taskDeletionWithStreak(int streakCount, int completionCount);
  String taskDeletionWithCompletions(int completionCount);
  String get taskWillBeDeleted;
  String get taskListSafeToDelete;
  String taskListDeletionSummary(int taskCount, int completionCount, int streakCount);
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
  String streakCount(int count);

  // Send invitation
  String inviteSomeoneTo(String taskListName);
  String get emailAddress;
  String get enterEmailToInvite;
  String get sendInvite;

  // Contact picker
  String get selectFromContacts;
  String get errorLoadingContacts;
  String get contactPermissionRequired;
  String get contactPermissionDescription;
  String get openSettings;
  String get contactHasNoEmail;
  String get selectEmailAddress;

  // Task fields
  String get taskListName;
  String get alarmTime;
  String get completionWindow;

  // Notifications
  String get notifications;
  String get noNotifications;
  String get allCaughtUp;
  String get dismissNotification;
  String get dismiss;
  String get notificationDismissed;
  String get confirmDismissNotification;
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
  String keepStreakGoing(int count);
  String get failedToCompleteTask;
  String get completeEarlierTasksFirst;
  String get keepItGoing;
  String streakAtRisk(int count);
  String get whenDidYouCompleteThis;
  String get howDidItGo;
  String get addNoteHint;
  String get addNote;
  String get completing;
  String get done;
  String get completeTaskButton;

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
  String get later;
  String get thisMonth;
  String get last3Months;

  // Form fields and dialogs
  String get enterTaskName;
  String get addTaskDetails;
  String get noAlarm;
  String get clearAlarm;
  String get completionWindowHours;
  String get completionWindowHint;
  String get hoursAfterAlarm;
  String get inactiveTasksWontShow;
  String get enterTaskListName;
  String get failedToCreateTaskList;

  // AI Suggestions
  String get aiSuggestions;
  String get suggestions;
  String get poweredByAi;
  String get failedToFetchSuggestions;
  String get loadingSuggestions;
  String get searchWithAI;
  String get noSuggestions;
  String get back;
  String get clear;
  String get close;
  String get generatingSuggestions;
  String get pleaseTryAgain;
  String get noSuggestionsAvailable;
  String get tryEnteringText;
  String get tryTypingForSuggestions;
  String get closeSuggestions;
  String get unexpectedError;
  String repeatsEvery(String unit);
  String repeatsEveryN(int delta, String units);

  // Weekdays (full names)
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // Weekdays (short names - 2 letters)
  String get mondayShort;
  String get tuesdayShort;
  String get wednesdayShort;
  String get thursdayShort;
  String get fridayShort;
  String get saturdayShort;
  String get sundayShort;

  // Schedule strings
  String get recurrence;
  String get every;
  String get selectDays;
  String get onDays;
  String get weekdays;
  String get weekends;
  String get repeatMode;
  String get simpleInterval;
  String get specificDays;
  String get simpleIntervalDescription;
  String get specificDaysDescription;
  String get orCustomize;
  String weekUnit(int count);

  // Timeline / Completed Tasks
  String get recentlyCompleted;
  String tasksCompletedCount(int count);
  String get now;
  String get showMore;
  String get showLess;
  String completedAgo(String timeAgo);
  String get expired;
  String expiredAgo(String timeAgo);
  String get system;
  String percentComplete(int percent);
  String get taskExpired;
  String get recentActivity;

  // Seasonal Scheduling
  String get activeMonths;
  String get yearRound;
  String monthsSelected(int count);
  String monthRange(String start, String end);
  String get summer;
  String get winter;
  String get growingSeason;
  String get allYear;
  String get orSelectManually;
  String get presets;

  // Month names (full)
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // Month names (short - 3 letters)
  String get januaryShort;
  String get februaryShort;
  String get marchShort;
  String get aprilShort;
  String get mayShort;
  String get juneShort;
  String get julyShort;
  String get augustShort;
  String get septemberShort;
  String get octoberShort;
  String get novemberShort;
  String get decemberShort;

  // Login Screen Features
  String get tagline;
  String get featureRepeating;
  String get featureShared;
  String get featureStreaks;
  String get whatIsAarshjulet;
  String get tapToReadMore;
  String get appShortDescription;
  String get featureRepeatingDescription;
  String get featureSharedDescription;
  String get featureStreaksDescription;
  String get getStarted;
  String get chooseTemplateDescription;
  String get chooseTaskTemplateDescription;
  String get createManually;
  String get editBeforeCreating;
  String get continueWithEmail;

  // Task repeat pattern descriptions
  String get repeatsDaily;
  String get repeatsWeekly;
  String get repeatsMonthly;
  String get repeatsYearly;
  String get orContinueWith;
  String get noAccount;
  String get haveAccount;
  String get featureRepeatingTitle;
  String get featureSharedTitle;
  String get featureStreaksTitle;
  String get featureAutomatic;
  String get featureTogether;
  String get featureMotivating;
  String get featureAutomaticTitle;
  String get featureAutomaticDescription;
  String get featureTogetherTitle;
  String get featureTogetherDescription;
  String get featureStreakTrackingTitle;
  String get featureStreakTrackingDescription;

  // Settings Screen
  String get appearance;
  String get themeColor;
  String get darkMode;
  String get chooseThemeColor;
  String get darkModeDescription;
  String get about;
  String get version;
  String get development;
  String get build;
  String get logoutConfirmMessage;
  String get logoutConfirmTitle;
  String get account;
  String get language;
  String get danish;
  String get english;
  String get chooseLanguage;
  String get editProfileInfo;
  String get logoutDescription;
  String get notificationSettings;
  String get enableNotifications;
  String get soundEnabled;
  String get vibrationEnabled;
  String get privacyPolicy;
  String get termsOfService;
  String get helpAndSupport;
  String get contactUs;
  String get rateApp;
  String get shareApp;
  String get deleteAccount;
  String get deleteAccountConfirmMessage;
  String get deleteAccountConfirmTitle;
  String get accountDeleted;
  String get failedToDeleteAccount;
  String get dangerZone;
  String get deleteAccountTitle;
  String get deleteAccountWarning;
  String get deleteAccountConfirm;
  String deleteAccountEmailSent(String email);
  String get deleteAccountError;
  String get failedToRequestAccountDeletion;

  // Push Notifications
  String get pushNotifications;
  String get pushInvitations;
  String get pushInvitationsDescription;
  String get pushInvitationResponses;
  String get pushInvitationResponsesDescription;
  String get pushTaskReminders;
  String get pushTaskRemindersDescription;

  // Profile Screen
  String get profile;
  String get noUserData;
  String get imageUploadComingSoon;
  String get personalInformation;
  String get cannotBeChanged;
  String get actions;
  String get editProfileComingSoon;
  String get editProfile;
  String get editProfileDescription;
  String get updateProfile;
  String get profileUpdated;
  String get failedToUpdateProfile;
  String get changePassword;
  String get changePasswordDescription;
  String get currentPassword;
  String get pleaseEnterCurrentPassword;
  String get passwordChanged;
  String get failedToChangePassword;
  String get memberSince;
  String get tasksCompleted;
  String get currentStreak;
  String get longestStreak;
  String get sharedLists;

  // Widget Strings
  String get widgetTitle;
  String get widgetDescription;
  String get widgetNoTasks;
  String get widgetLoading;
  String get widgetError;
  String get widgetTapToRefresh;
  String get widgetConfigureInApp;
  String get widgetUpcoming;
  String get widgetOverdue;
  String get widgetDueToday;

  // API Errors
  String get failedToLoadTaskLists;
  String get failedToLoadTasks;
  String get failedToLoadNotifications;
  String get failedToLoadProfile;
  String get failedToLoadInvitations;
  String get sessionExpired;
  String get pleaseLoginAgain;
  String get serverError;
  String get connectionError;
  String get timeoutError;
  String get unknownError;
  String get noInternetConnection;
  String get tryAgainLater;

  // Notification Strings
  String get notificationTaskReminder;
  String get notificationTaskOverdue;
  String get notificationNewInvitation;
  String get notificationInvitationAccepted;
  String get notificationInvitationDeclined;
  String get notificationStreakAtRisk;
  String get notificationStreakLost;
  String get notificationTaskCompleted;
  String notificationTaskDueIn(String time);
  String notificationStreakDays(int days);

  // Push notification body text (bruges af NotificationService)
  String notificationInvitationReceived(String fromUser, String taskListName);
  String notificationInvitationAcceptedBody(String email, String taskListName);
  String notificationInvitationDeclinedBody(String email, String taskListName);
  String notificationTaskDue(String taskName, String taskListName);

  // Additional Common Strings
  String get yes;
  String get no;
  String get ok;
  String get confirm;
  String get next;
  String get previous;
  String get skip;
  String get finish;
  String get submit;
  String get update;
  String get add;
  String get search;
  String get noResults;
  String get searchHint;
  String get selectAll;
  String get deselectAll;
  String get sortBy;
  String get filterBy;
  String get ascending;
  String get descending;
  String get newest;
  String get oldest;

  // Theme and Visual Settings
  String get theme;
  String get selectTheme;
  String get visualTheme;
  String get failedToLoadThemes;
  String get failedToUpdateTaskList;

  // Delete Dialog Strings
  String get checkingDeletionDetails;
  String get unableToLoadDeletionDetails;
  String get actionCannotBeUndone;
  String get proceedWithCaution;

  // Accessibility
  String get decrease;
  String get increase;

  // Repeat unit names (singular/plural for recurrence fields)
  String get daySingular;
  String get dayPlural;
  String get weekSingular;
  String get weekPlural;
  String get monthSingular;
  String get monthPlural;
  String get yearSingular;
  String get yearPlural;
  String get daysUnit;
  String get weeksUnit;
  String get monthsUnit;
  String get yearsUnit;

  // Delete dialog
  String deleteItemQuestion(String itemName);

  // Task Swipe Actions
  String get taskCompletedSwipe;
  String get taskDismissedSwipe;
  String get skipThisTime;
  String get taskDismissed;
  String get undo;

  // Additional API Error Strings (for ApiErrorKey translation)
  String get failedToLoadOwnedTaskLists;
  String get failedToLoadSharedTaskLists;
  String get failedToLoadTaskList;
  String get failedToLoadTask;
  String get failedToLoadUpcomingTasks;
  String get failedToLoadUpcomingOccurrences;
  String get failedToLoadTaskInstances;
  String get failedToLoadTaskInstance;
  String get failedToCreateTaskInstance;
  String get failedToLoadRecentlyCompleted;
  String get failedToLoadCurrentStreak;
  String get failedToLoadLongestStreak;
  String get failedToLoadStreaks;
  String get failedToLoadPendingInvitations;
  String get failedToLoadTaskListInvitations;
  String get failedToLoadInvitation;
  String get failedToCreateInvitation;
  String get failedToLoadTaskListUsers;
  String get failedToUpdateUserAdminLevel;
  String get failedToUploadImage;
  String get failedToDeleteImage;
  String get failedToLoadCompletionMessage;
  String get failedToLoadUserSettings;
  String get failedToUpdateUserSettings;
  String get failedToLoadVisualThemes;
  String get failedToLoadVisualTheme;
  String get failedToRefreshToken;

  // Content Moderation
  String get contentModerationViolation;

  // Battery Optimization Dialog (Android)
  String get batteryOptimizationTitle;
  String get batteryOptimizationMessage;

  // Gender and Birth Year
  String get gender;
  String get birthYear;
  String get genderMale;
  String get genderFemale;
  String get genderOther;
  String get notSpecified;
  String get selectBirthYear;
  String get thisHelpsPersonalize;
  String get personalizeYourExperience;
  String get continueButton;

  // Schedule from Completion
  String get scheduleFromCompletionLabel;
  String get scheduleFromCompletionDescription;

  // Retroaktiv completion
  String get retroactiveCompleteTitle;
  String get whoCompletedTask;
  String get taskMarkedAsCompleted;
  String get failedToCompleteRetroactive;

  // Cheers
  String get cheerTaskInstance;
  String get cheerSent;
  String get writeMessage;
  String get pushCheers;
  String get pushCheersDescription;
  String get cannotCheerOwnTask;
  String get cheerUpdated;
  String get cheerDeleted;
  String get failedToCheerTask;
  String get failedToDeleteCheer;

  // Udløb (expiry countdown)
  String expiresIn(String timeLeft);

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

  /// Oversætter en ApiErrorKey til en lokaliseret fejlmeddelelse.
  /// Bruges til at vise lokaliserede fejlmeddelelser fra API-kald.
  String translateApiError(ApiErrorKey? errorKey, [String? fallbackMessage]) {
    if (errorKey == null) {
      return fallbackMessage ?? unknownError;
    }

    switch (errorKey) {
      // Auth
      case ApiErrorKey.registrationFailed:
        return registrationFailed;
      case ApiErrorKey.loginFailed:
        return loginFailed;
      case ApiErrorKey.failedToSendResetEmail:
        return failedToSendResetEmail;
      case ApiErrorKey.failedToResetPassword:
        return failedToResetPassword;
      case ApiErrorKey.failedToRefreshToken:
        return failedToRefreshToken;
      case ApiErrorKey.sessionExpired:
        return sessionExpired;

      // Task Lists
      case ApiErrorKey.failedToLoadTaskLists:
        return failedToLoadTaskLists;
      case ApiErrorKey.failedToLoadOwnedTaskLists:
        return failedToLoadOwnedTaskLists;
      case ApiErrorKey.failedToLoadSharedTaskLists:
        return failedToLoadSharedTaskLists;
      case ApiErrorKey.failedToLoadTaskList:
        return failedToLoadTaskList;
      case ApiErrorKey.failedToCreateTaskList:
        return failedToCreateTaskList;
      case ApiErrorKey.failedToUpdateTaskList:
        return failedToUpdateTaskList;
      case ApiErrorKey.failedToDeleteTaskList:
        return failedToDeleteTaskList;

      // Tasks
      case ApiErrorKey.failedToLoadTasks:
        return failedToLoadTasks;
      case ApiErrorKey.failedToLoadTask:
        return failedToLoadTask;
      case ApiErrorKey.failedToCreateTask:
        return failedToCreateTask;
      case ApiErrorKey.failedToUpdateTask:
        return failedToUpdateTask;
      case ApiErrorKey.failedToDeleteTask:
        return failedToDeleteTask;
      case ApiErrorKey.failedToLoadUpcomingTasks:
        return failedToLoadUpcomingTasks;
      case ApiErrorKey.failedToLoadUpcomingOccurrences:
        return failedToLoadUpcomingOccurrences;
      case ApiErrorKey.failedToCompleteTask:
        return failedToCompleteTask;

      // Task Instances
      case ApiErrorKey.failedToLoadTaskInstances:
        return failedToLoadTaskInstances;
      case ApiErrorKey.failedToLoadTaskInstance:
        return failedToLoadTaskInstance;
      case ApiErrorKey.failedToCreateTaskInstance:
        return failedToCreateTaskInstance;
      case ApiErrorKey.failedToLoadRecentlyCompleted:
        return failedToLoadRecentlyCompleted;
      case ApiErrorKey.failedToCompleteRetroactive:
        return failedToCompleteRetroactive;

      // Streaks
      case ApiErrorKey.failedToLoadCurrentStreak:
        return failedToLoadCurrentStreak;
      case ApiErrorKey.failedToLoadLongestStreak:
        return failedToLoadLongestStreak;
      case ApiErrorKey.failedToLoadStreaks:
        return failedToLoadStreaks;

      // Invitations
      case ApiErrorKey.failedToLoadPendingInvitations:
        return failedToLoadPendingInvitations;
      case ApiErrorKey.failedToLoadInvitations:
        return failedToLoadInvitations;
      case ApiErrorKey.failedToLoadTaskListInvitations:
        return failedToLoadTaskListInvitations;
      case ApiErrorKey.failedToLoadInvitation:
        return failedToLoadInvitation;
      case ApiErrorKey.failedToCreateInvitation:
        return failedToCreateInvitation;
      case ApiErrorKey.failedToAcceptInvitation:
        return failedToAcceptInvitation;
      case ApiErrorKey.failedToDeclineInvitation:
        return failedToDeclineInvitation;
      case ApiErrorKey.failedToCancelInvitation:
        return failedToCancelInvitation;

      // Task List Users
      case ApiErrorKey.failedToLoadTaskListUsers:
        return failedToLoadTaskListUsers;
      case ApiErrorKey.failedToUpdateUserAdminLevel:
        return failedToUpdateUserAdminLevel;
      case ApiErrorKey.failedToRemoveUser:
        return failedToRemoveMember;

      // Images
      case ApiErrorKey.failedToUploadImage:
        return failedToUploadImage;
      case ApiErrorKey.failedToDeleteImage:
        return failedToDeleteImage;

      // Completion Message
      case ApiErrorKey.failedToLoadCompletionMessage:
        return failedToLoadCompletionMessage;

      // User Settings
      case ApiErrorKey.failedToLoadUserSettings:
        return failedToLoadUserSettings;
      case ApiErrorKey.failedToUpdateUserSettings:
        return failedToUpdateUserSettings;

      // Visual Themes
      case ApiErrorKey.failedToLoadVisualThemes:
        return failedToLoadVisualThemes;
      case ApiErrorKey.failedToLoadVisualTheme:
        return failedToLoadVisualTheme;

      // Account
      case ApiErrorKey.failedToRequestAccountDeletion:
        return failedToRequestAccountDeletion;

      // Content Moderation
      case ApiErrorKey.contentModerationViolation:
        return contentModerationViolation;

      // Cheers
      case ApiErrorKey.failedToCheerTask:
        return failedToCheerTask;
      case ApiErrorKey.failedToDeleteCheer:
        return failedToDeleteCheer;

      // Push Notifications
      case ApiErrorKey.failedToRegisterFcmToken:
      case ApiErrorKey.failedToUnregisterFcmToken:
        return unknownError; // Fejl ved FCM token håndtering vises ikke til brugeren

      // Generic
      case ApiErrorKey.networkError:
        return connectionError;
      case ApiErrorKey.unknownError:
        return unknownError;
    }
  }

  /// Oversætter en ApiException til en lokaliseret fejlmeddelelse.
  /// Bruges til at vise lokaliserede fejlmeddelelser fra API-kald.
  String translateApiException(ApiException exception) {
    return translateApiError(exception.errorKey, exception.message);
  }
}
