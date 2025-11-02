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
  String get passwordMinLength => 'Adgangskoden skal være mindst 8 tegn';

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

  // Task Lists
  @override
  String get taskLists => 'Opgavelister';

  @override
  String get createTaskList => 'Opret opgaveliste';

  @override
  String get editTaskList => 'Rediger opgaveliste';

  @override
  String get deleteTaskList => 'Slet opgaveliste';

  @override
  String get noTaskLists => 'Ingen opgavelister endnu';

  @override
  String get createFirstTaskList => 'Opret din første opgaveliste for at komme i gang';

  @override
  String get taskListCreated => 'Opgaveliste oprettet';

  @override
  String get taskListUpdated => 'Opgaveliste opdateret';

  @override
  String get taskListDeleted => 'Opgaveliste slettet';

  // Tasks
  @override
  String get tasks => 'Opgaver';

  @override
  String get createTask => 'Opret opgave';

  @override
  String get editTask => 'Rediger opgave';

  @override
  String get deleteTask => 'Slet opgave';

  @override
  String get noTasks => 'Ingen opgaver endnu';

  @override
  String get addFirstTask => 'Tilføj din første opgave til denne liste';

  @override
  String get taskCreated => 'Opgave oprettet';

  @override
  String get taskUpdated => 'Opgave opdateret';

  @override
  String get taskDeleted => 'Opgave slettet';

  @override
  String get completeTask => 'Fuldfør opgave';

  @override
  String get taskCompleted => 'Opgave fuldført';

  // Task Details
  @override
  String get taskName => 'Opgavenavn';

  @override
  String get description => 'Beskrivelse';

  @override
  String get descriptionOptional => 'Beskrivelse (valgfri)';

  @override
  String get repeat => 'Gentag';

  @override
  String get everyNumber => 'Hver (antal)';

  @override
  String get firstRunDate => 'Første kørselsdato';

  @override
  String get completionTime => 'Fuldførelsestidspunkt';

  // Repeat Units
  @override
  String get daily => 'Dagligt';

  @override
  String get weekly => 'Ugentligt';

  @override
  String get monthly => 'Månedligt';

  @override
  String get yearly => 'Årligt';

  // Invitations
  @override
  String get invitations => 'Invitationer';

  @override
  String get pendingInvitations => 'Afventende invitationer';

  @override
  String get noPendingInvitations => 'Ingen afventende invitationer';

  @override
  String get invitationFrom => 'Fra';

  @override
  String get acceptInvitation => 'Accepter';

  @override
  String get declineInvitation => 'Afvis';

  @override
  String get invitationAccepted => 'Invitation accepteret';

  @override
  String get invitationDeclined => 'Invitation afvist';

  @override
  String get sendInvitation => 'Send invitation';

  // Members
  @override
  String get members => 'Medlemmer';

  @override
  String get addMember => 'Tilføj medlem';

  @override
  String get removeMember => 'Fjern medlem';

  @override
  String get changePermission => 'Skift tilladelse';

  // Common
  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get delete => 'Slet';

  @override
  String get edit => 'Rediger';

  @override
  String get create => 'Opret';

  @override
  String get retry => 'Prøv igen';

  @override
  String get error => 'Fejl';

  @override
  String get loading => 'Indlæser';

  @override
  String get comment => 'Kommentar';

  @override
  String get commentOptional => 'Kommentar (valgfri)';

  @override
  String get logout => 'Log ud';

  @override
  String get lists => 'Lister';
}
