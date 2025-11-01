import 'app_strings.dart';

class StringsEn extends AppStrings {
  @override
  String get appTitle => 'Wheel of Time';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create your account';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAccount => "Don't have an account? Sign up";

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get welcome => 'Welcome!';

  @override
  String get userId => 'User ID';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      "Enter your email address and we'll send you a link to reset your password";

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String emailResetSent(String email) =>
      "If an account exists with this email, we've sent a password reset link to $email";

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get enterNewPassword => 'Enter your new password below';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter your new password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordResetSuccessful => 'Password Reset Successful';

  @override
  String get passwordResetSuccessMessage =>
      'Your password has been reset successfully. You can now log in with your new password.';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get loginFailed => 'Login failed';

  @override
  String networkError(String details) => 'Network error: $details';

  @override
  String get failedToSendResetEmail => 'Failed to send password reset email';

  @override
  String get failedToResetPassword => 'Failed to reset password';
}
