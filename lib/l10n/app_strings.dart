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
  String get invitationAccepted;
  String get invitationDeclined;
  String get sendInvitation;

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
  String get lists;

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
