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
  String get noTaskListsYet => 'Ingen opgavelister endnu';

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

  @override
  String get invitationsWillAppearHere => 'Invitationer vil vises her'; // TODO: Verify Danish translation

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

  @override
  String get complete => 'Fuldfør';

  @override
  String get more => 'Mere';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get remove => 'Fjern';

  @override
  String get invite => 'Inviter';

  @override
  String get pending => 'Afventer';

  // Confirmation messages
  @override
  String get confirmDeleteMessage => 'Denne handling kan ikke fortrydes.';

  @override
  String confirmDeleteTask(String name) =>
      'Er du sikker på, at du vil slette "$name"? Denne handling kan ikke fortrydes.';

  @override
  String confirmDeleteTaskList(String name) =>
      'Er du sikker på, at du vil slette "$name"? Denne handling kan ikke fortrydes.';

  @override
  String confirmRemoveMember(String name) =>
      'Er du sikker på, at du vil fjerne "$name" fra denne opgaveliste?';

  @override
  String confirmCancelInvitation(String email) =>
      'Er du sikker på, at du vil annullere invitationen til "$email"?';

  // Success messages
  @override
  String get taskDeletedSuccess => 'Opgave slettet';

  @override
  String get taskListDeletedSuccess => 'Opgaveliste slettet';

  @override
  String get memberRemovedSuccess => 'Medlem fjernet';

  @override
  String get invitationCancelledSuccess => 'Invitation annulleret';

  @override
  String get permissionUpdatedSuccess => 'Tilladelse opdateret';

  @override
  String invitationSentTo(String email) => 'Invitation sendt til $email';

  // Error messages
  @override
  String get failedToDeleteTask => 'Kunne ikke slette opgave';

  @override
  String get failedToDeleteTaskList => 'Kunne ikke slette opgaveliste';

  @override
  String get failedToUpdateTask => 'Kunne ikke opdatere opgave';

  @override
  String get failedToCreateTask => 'Kunne ikke oprette opgave';

  @override
  String get failedToRemoveMember => 'Kunne ikke fjerne medlem';

  @override
  String get failedToCancelInvitation => 'Kunne ikke annullere invitation';

  @override
  String get failedToUpdatePermission => 'Kunne ikke opdatere tilladelse';

  @override
  String get failedToSendInvitation => 'Kunne ikke sende invitation';

  @override
  String get pleaseEnterTaskName => 'Indtast venligst et opgavenavn';

  @override
  String get pleaseEnterNumber => 'Indtast venligst et tal';

  @override
  String get pleaseEnterValidNumber => 'Indtast venligst et gyldigt tal (1 eller mere)';

  @override
  String get pleaseEnterEmailAddress => 'Indtast venligst en e-mailadresse';

  @override
  String errorLoadingMembers(String error) => 'Fejl ved indlæsning af medlemmer: $error';

  @override
  String errorLoadingInvitations(String error) =>
      'Fejl ved indlæsning af invitationer: $error';

  // Task list members
  @override
  String membersIn(String taskListName) => 'Medlemmer i $taskListName';

  @override
  String get cancelInvitation => 'Annuller invitation';

  @override
  String get cancelInvite => 'Annuller invitation';

  @override
  String get changePermissionLevel => 'Skift tilladelsesniveau';

  @override
  String changePermissionFor(String userName) =>
      'Skift tilladelsesniveau for $userName:';

  @override
  String get canEdit => 'Kan redigere';

  @override
  String get canEditDescription => 'Kan ændre opgaver og indstillinger';

  @override
  String get canView => 'Kan se';

  @override
  String get canViewDescription => 'Kan kun se og fuldføre opgaver';

  @override
  String get noMembers => 'Ingen medlemmer endnu';

  @override
  String invitedBy(String userName) => 'Inviteret af $userName';

  // Task details
  @override
  String tasksIn(String taskListName) => 'Opgaver i $taskListName';

  @override
  String get alarmTimeOptional => 'Alarmtidspunkt (valgfri)';

  @override
  String get noAlarmSet => 'Ingen alarm indstillet';

  @override
  String get completionWindowOptional => 'Fuldførelsesvindue (timer, valgfri)';

  @override
  String get completionWindowHelper => 'Hvor mange timer efter alarm til fuldførelse';

  @override
  String get inactiveTasksHidden => 'Inaktive opgaver vises ikke til fuldførelse';

  @override
  String dayStreak(int count) => '$count dages stribe';

  // Send invitation
  @override
  String inviteSomeoneTo(String taskListName) => 'Inviter nogen til "$taskListName"';

  @override
  String get emailAddress => 'E-mailadresse';

  @override
  String get enterEmailToInvite => 'Indtast e-mailen på personen, du vil invitere';

  @override
  String get sendInvite => 'Send invitation';

  // Task fields
  @override
  String get taskListName => 'Opgavelistenavn';

  @override
  String get alarmTime => 'Alarmtidspunkt';

  @override
  String get completionWindow => 'Fuldførelsesvindue';

  // Notifications
  @override
  String get notifications => 'Notifikationer';

  @override
  String get noNotifications => 'Ingen notifikationer';

  @override
  String get allCaughtUp => 'Du er opdateret!';

  @override
  String get notificationDismissed => 'Notifikation afvist';

  @override
  String get newInvitation => 'Ny invitation';

  @override
  String get invitationWasAccepted => 'Invitation accepteret';

  @override
  String get invitationWasDeclined => 'Invitation afvist';

  @override
  String get taskDue => 'Opgave klar';

  @override
  String get inList => 'i';

  @override
  String get refresh => 'Genindlæs';

  @override
  String get failedToAcceptInvitation => 'Kunne ikke acceptere invitation';

  @override
  String get failedToDeclineInvitation => 'Kunne ikke afvise invitation';

  // Time formatting
  @override
  String get justNow => 'Lige nu';

  @override
  String minutesAgo(int minutes) => '${minutes}m siden';

  @override
  String hoursAgo(int hours) => '${hours}t siden';

  @override
  String daysAgo(int days) => '${days}d siden';

  // Upcoming Tasks
  @override
  String get upcomingTasks => 'Kommende';

  @override
  String get noUpcomingTasks => 'Ingen kommende opgaver';

  @override
  String get allCaughtUpWithTasks => 'Du er opdateret! Ingen opgaver de næste 2 uger.';

  @override
  String get dueToday => 'Forfalder i dag';

  @override
  String get dueTomorrow => 'Forfalder i morgen';

  @override
  String dueInDays(int days) => 'Forfalder om $days dage';

  @override
  String get overdue => 'Forsinket';

  @override
  String dueDaysAgo(int days) => 'Forfaldt for $days dage siden';

  @override
  String get taskCompletedSuccess => 'Opgave fuldført';

  @override
  String get streakContinued => 'Serie fortsat!';

  @override
  String streakExtended(int count) => 'Serie udvidet til $count dage!';

  @override
  String get failedToCompleteTask => 'Kunne ikke fuldføre opgave';

  @override
  String get completeEarlierTasksFirst => 'Fuldfør tidligere opgaver først'; // TODO: Verify Danish translation

  // Task History
  @override
  String get taskHistory => 'Opgavehistorik';

  @override
  String taskHistoryFor(String taskName) => 'Historik for "$taskName"';

  @override
  String get noCompletionsYet => 'Ingen fuldførelser endnu';

  @override
  String get noCompletionsYetDescription =>
      'Denne opgave er ikke blevet fuldført endnu. Fuldfør den for at begynde at spore din fremgang!';

  @override
  String get completedBy => 'Fuldført af';

  @override
  String completedOn(String date) => 'Fuldført den $date';

  @override
  String completedAt(String time) => 'kl. $time';

  @override
  String get onTime => 'Til tiden';

  @override
  String get late => 'Forsinket';

  @override
  String get contributedToStreak => 'Bidrog til serie';

  @override
  String get didNotContributeToStreak => 'Bidrog ikke til serie';

  @override
  String get withComment => 'Med kommentar';

  @override
  String totalCompletions(int count) =>
      '$count ${count == 1 ? 'fuldførelse' : 'fuldførelser'}';

  @override
  String get loadingHistory => 'Indlæser historik...';

  @override
  String get errorLoadingHistory => 'Fejl ved indlæsning af historik';

  @override
  String errorLoadingHistoryDetails(String error) =>
      'Kunne ikke indlæse opgavehistorik: $error';
}
