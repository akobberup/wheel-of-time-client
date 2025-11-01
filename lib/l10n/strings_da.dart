import 'app_strings.dart';

class StringsDa extends AppStrings {
  @override
  String get appTitle => 'Årshjulet';

  @override
  String get welcomeBack => 'Velkommen tilbage';

  @override
  String get createAccount => 'Opret din konto';

  @override
  String get name => 'Navn';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Adgangskode';

  @override
  String get pleaseEnterName => 'Indtast venligst dit navn';

  @override
  String get pleaseEnterEmail => 'Indtast venligst din e-mail';

  @override
  String get pleaseEnterValidEmail => 'Indtast venligst en gyldig e-mail';

  @override
  String get pleaseEnterPassword => 'Indtast venligst din adgangskode';

  @override
  String get passwordMinLength => 'Adgangskoden skal være mindst 6 tegn';

  @override
  String get signIn => 'Log ind';

  @override
  String get signUp => 'Tilmeld';

  @override
  String get forgotPassword => 'Glemt adgangskode?';

  @override
  String get dontHaveAccount => 'Har du ikke en konto? Tilmeld dig';

  @override
  String get alreadyHaveAccount => 'Har du allerede en konto? Log ind';

  @override
  String get welcome => 'Velkommen!';

  @override
  String get userId => 'Bruger-ID';

  @override
  String get forgotPasswordTitle => 'Glemt adgangskode';

  @override
  String get resetPassword => 'Nulstil adgangskode';

  @override
  String get resetPasswordInstructions =>
      'Indtast din e-mail adresse, så sender vi dig et link til at nulstille din adgangskode';

  @override
  String get sendResetLink => 'Send nulstillingslink';

  @override
  String get checkYourEmail => 'Tjek din e-mail';

  @override
  String emailResetSent(String email) =>
      'Hvis der findes en konto med denne e-mail, har vi sendt et link til nulstilling af adgangskode til $email';

  @override
  String get backToLogin => 'Tilbage til login';

  @override
  String get resetYourPassword => 'Nulstil din adgangskode';

  @override
  String get enterNewPassword => 'Indtast din nye adgangskode nedenfor';

  @override
  String get newPassword => 'Ny adgangskode';

  @override
  String get confirmPassword => 'Bekræft adgangskode';

  @override
  String get pleaseEnterNewPassword => 'Indtast venligst din nye adgangskode';

  @override
  String get pleaseConfirmPassword => 'Bekræft venligst din adgangskode';

  @override
  String get passwordsDoNotMatch => 'Adgangskoderne matcher ikke';

  @override
  String get passwordResetSuccessful => 'Adgangskode nulstillet';

  @override
  String get passwordResetSuccessMessage =>
      'Din adgangskode er blevet nulstillet. Du kan nu logge ind med din nye adgangskode.';

  @override
  String get goToLogin => 'Gå til login';

  @override
  String get registrationFailed => 'Registrering mislykkedes';

  @override
  String get loginFailed => 'Login mislykkedes';

  @override
  String networkError(String details) => 'Netværksfejl: $details';

  @override
  String get failedToSendResetEmail =>
      'Kunne ikke sende e-mail til nulstilling af adgangskode';

  @override
  String get failedToResetPassword => 'Kunne ikke nulstille adgangskode';
}
