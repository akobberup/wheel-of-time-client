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
