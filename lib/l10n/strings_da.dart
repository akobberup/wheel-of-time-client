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

  @override
  String timesCompleted(int count) => 'Fuldført ${count}x';

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

  @override
  String get showOptionalDetails => 'Vis valgfrie detaljer';

  @override
  String get hideOptionalDetails => 'Skjul valgfrie detaljer';

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
  String declineInvitationConfirmation(String taskListName) =>
      'Er du sikker på, at du vil afvise invitationen til "$taskListName"?';

  @override
  String get accepted => 'Accepteret';

  @override
  String get declined => 'Afvist';

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
  String get moreOptions => 'Flere muligheder';

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
  String get confirmDeleteTaskListEmpty =>
      'Denne liste er tom og kan slettes sikkert.';

  @override
  String confirmDeleteTaskWithStreak(String name, int streakCount, int completions) =>
      'Slet "$name"? Dette vil permanent slette din ${streakCount}x streak og $completions afslutnings${completions == 1 ? 'post' : 'poster'}.';

  @override
  String confirmDeleteTaskNoStreak(String name, int completions) =>
      'Slet "$name"? Dette vil permanent slette $completions afslutnings${completions == 1 ? 'post' : 'poster'}.';

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
  String streakCount(int count) => '${count}x streak';

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
  String get dismissNotification => 'Afvis notifikation';

  @override
  String get dismiss => 'Afvis';

  @override
  String get notificationDismissed => 'Notifikation afvist';

  @override
  String get confirmDismissNotification => 'Er du sikker på, at du vil afvise denne notifikation?';

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

  @override
  String get today => 'I dag';

  @override
  String get yesterday => 'I går';

  @override
  String get older => 'Ældre';

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
  String streakExtended(int count) => 'Serie udvidet til ${count}x!';

  @override
  String keepStreakGoing(int count) => 'Hold din ${count}x streak i gang!';

  @override
  String get failedToCompleteTask => 'Kunne ikke fuldføre opgave';

  @override
  String get completeEarlierTasksFirst => 'Fuldfør tidligere opgaver først'; // TODO: Verify Danish translation

  @override
  String get keepItGoing => 'Bliv ved!';

  @override
  String streakAtRisk(int count) => '⚠️ ${count}x streak i fare!';

  @override
  String get whenDidYouCompleteThis => 'Hvornår fuldførte du dette?';

  @override
  String get howDidItGo => 'Hvordan gik det?';

  @override
  String get addNoteHint => 'Tilføj en note om denne fuldførelse...';

  @override
  String get addNote => 'Tilføj note';

  @override
  String get completing => 'Fuldfører...';

  @override
  String get done => 'Færdig!';

  @override
  String get completeTaskButton => 'Fuldfør opgave!';

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

  @override
  String get filter => 'Filtrer';

  @override
  String get allTime => 'Alle tidspunkter';

  @override
  String get thisWeek => 'Denne uge';

  @override
  String get later => 'Senere';

  @override
  String get thisMonth => 'Denne måned';

  @override
  String get last3Months => 'Sidste 3 måneder';

  // Form fields and dialogs
  @override
  String get enterTaskName => 'Indtast opgavenavn';

  @override
  String get addTaskDetails => 'Tilføj opgavedetaljer';

  @override
  String get noAlarm => 'Ingen alarm indstillet';

  @override
  String get clearAlarm => 'Ryd alarm';

  @override
  String get completionWindowHours => 'Fuldførelsesvindue (timer)';

  @override
  String get completionWindowHint => 'f.eks. 24';

  @override
  String get hoursAfterAlarm => 'Timer efter alarm til fuldførelse';

  @override
  String get inactiveTasksWontShow => 'Inaktive opgaver vises ikke til fuldførelse';

  @override
  String get enterTaskListName => 'Indtast opgavelistenavn';

  @override
  String get failedToCreateTaskList => 'Kunne ikke oprette opgaveliste';

  // AI Suggestions
  @override
  String get aiSuggestions => 'AI-forslag';

  @override
  String get suggestions => 'Forslag';

  @override
  String get poweredByAi => 'Drevet af AI';

  @override
  String get failedToFetchSuggestions => 'Kunne ikke hente forslag';

  @override
  String get loadingSuggestions => 'Indlæser forslag...';

  @override
  String get searchWithAI => 'Søg med AI';

  @override
  String get noSuggestions => 'Ingen forslag tilgængelige';

  @override
  String get back => 'Tilbage';

  @override
  String get clear => 'Ryd';

  // Weekdays (full names)
  @override
  String get monday => 'Mandag';

  @override
  String get tuesday => 'Tirsdag';

  @override
  String get wednesday => 'Onsdag';

  @override
  String get thursday => 'Torsdag';

  @override
  String get friday => 'Fredag';

  @override
  String get saturday => 'Lørdag';

  @override
  String get sunday => 'Søndag';

  // Weekdays (short names - 2 letters)
  @override
  String get mondayShort => 'Ma';

  @override
  String get tuesdayShort => 'Ti';

  @override
  String get wednesdayShort => 'On';

  @override
  String get thursdayShort => 'To';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Lø';

  @override
  String get sundayShort => 'Sø';

  // Schedule strings
  @override
  String get recurrence => 'Gentagelse';

  @override
  String get every => 'Hver';

  @override
  String get selectDays => 'Vælg dage';

  @override
  String get onDays => 'På dage';

  @override
  String get weekdays => 'Hverdage';

  @override
  String get weekends => 'Weekender';

  @override
  String get repeatMode => 'Gentagelsestype';

  @override
  String get simpleInterval => 'Interval';

  @override
  String get specificDays => 'Bestemte dage';

  @override
  String get simpleIntervalDescription => 'Hver X dage/uger/måneder';

  @override
  String get specificDaysDescription => 'Vælg specifikke ugedage';

  @override
  String get orCustomize => 'eller tilpas';

  // Timeline / Completed Tasks
  @override
  String get recentlyCompleted => 'Nyligt fuldført';

  @override
  String tasksCompletedCount(int count) =>
      count == 1 ? '1 opgave fuldført' : '$count opgaver fuldført';

  @override
  String get now => 'Nu';

  @override
  String get showMore => 'Vis mere';

  @override
  String get showLess => 'Vis mindre';

  @override
  String completedAgo(String timeAgo) => 'Fuldført $timeAgo';

  @override
  String get expired => 'Udløbet';

  @override
  String expiredAgo(String timeAgo) => 'Udløbet $timeAgo';

  @override
  String get taskExpired => 'Opgave udløbet';

  @override
  String get recentActivity => 'Seneste aktivitet';
}
