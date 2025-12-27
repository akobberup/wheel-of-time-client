import 'app_strings.dart';

class StringsEn extends AppStrings {
  @override
  String get appTitle => 'Aarshjulet';

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
  String get passwordMinLength => 'Password must be at least 8 characters';

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

  // Task Lists
  @override
  String get taskLists => 'Task Lists';

  @override
  String get createTaskList => 'Create Task List';

  @override
  String get editTaskList => 'Edit Task List';

  @override
  String get deleteTaskList => 'Delete Task List';

  @override
  String get noTaskLists => 'No task lists yet';

  @override
  String get noTaskListsYet => 'No task lists yet';

  @override
  String get createFirstTaskList => 'Create your first task list to get started';

  @override
  String get taskListCreated => 'Task list created';

  @override
  String get taskListUpdated => 'Task list updated';

  @override
  String get taskListDeleted => 'Task list deleted';

  // Tasks
  @override
  String get tasks => 'Tasks';

  @override
  String get createTask => 'Create Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get addFirstTask => 'Add your first task to this list';

  @override
  String get taskCreated => 'Task created';

  @override
  String get taskUpdated => 'Task updated';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get completeTask => 'Complete Task';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String timesCompleted(int count) => '${count}x completed';

  // Task Details
  @override
  String get taskName => 'Task Name';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get repeat => 'Repeat';

  @override
  String get everyNumber => 'Every (number)';

  @override
  String get firstRunDate => 'First Run Date';

  @override
  String get completionTime => 'Completion Time';

  @override
  String get showOptionalDetails => 'Show optional details';

  @override
  String get hideOptionalDetails => 'Hide optional details';

  // Repeat Units
  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  // Invitations
  @override
  String get invitations => 'Invitations';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String get invitationFrom => 'From';

  @override
  String get acceptInvitation => 'Accept';

  @override
  String get declineInvitation => 'Decline';

  @override
  String declineInvitationConfirmation(String taskListName) =>
      'Are you sure you want to decline the invitation to "$taskListName"?';

  @override
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get invitationAccepted => 'Invitation accepted';

  @override
  String get invitationDeclined => 'Invitation declined';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String get invitationsWillAppearHere => 'Invitations will appear here';

  // Members
  @override
  String get members => 'Members';

  @override
  String get addMember => 'Add Member';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get changePermission => 'Change Permission';

  // Common
  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading';

  @override
  String get comment => 'Comment';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get logout => 'Logout';

  @override
  String get moreOptions => 'More Options';

  @override
  String get lists => 'Lists';

  @override
  String get complete => 'Complete';

  @override
  String get more => 'More';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get remove => 'Remove';

  @override
  String get invite => 'Invite';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  // Confirmation messages
  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String confirmDeleteTask(String name) =>
      'Are you sure you want to delete "$name"? This action cannot be undone.';

  @override
  String confirmDeleteTaskList(String name) =>
      'Are you sure you want to delete "$name"? This action cannot be undone.';

  @override
  String get confirmDeleteTaskListEmpty =>
      'This list is empty and can be safely deleted.';

  @override
  String confirmDeleteTaskWithStreak(String name, int streakCount, int completions) =>
      'Delete "$name"? This will permanently delete your ${streakCount}x streak and $completions completion ${completions == 1 ? 'record' : 'records'}.';

  @override
  String confirmDeleteTaskNoStreak(String name, int completions) =>
      'Delete "$name"? This will permanently delete $completions completion ${completions == 1 ? 'record' : 'records'}.';

  @override
  String confirmRemoveMember(String name) =>
      'Are you sure you want to remove "$name" from this task list?';

  @override
  String confirmCancelInvitation(String email) =>
      'Are you sure you want to cancel the invitation to "$email"?';

  // Success messages
  @override
  String get taskDeletedSuccess => 'Task deleted successfully';

  @override
  String get taskListDeletedSuccess => 'Task list deleted successfully';

  @override
  String get memberRemovedSuccess => 'Member removed successfully';

  @override
  String get invitationCancelledSuccess => 'Invitation cancelled successfully';

  @override
  String get permissionUpdatedSuccess => 'Permission level updated successfully';

  @override
  String invitationSentTo(String email) => 'Invitation sent to $email';

  // Error messages
  @override
  String get failedToDeleteTask => 'Failed to delete task';

  @override
  String get failedToDeleteTaskList => 'Failed to delete task list';

  @override
  String get failedToUpdateTask => 'Failed to update task';

  @override
  String get failedToCreateTask => 'Failed to create task';

  @override
  String get failedToRemoveMember => 'Failed to remove member';

  @override
  String get failedToCancelInvitation => 'Failed to cancel invitation';

  @override
  String get failedToUpdatePermission => 'Failed to update permission level';

  @override
  String get failedToSendInvitation => 'Failed to send invitation';

  @override
  String get pleaseEnterTaskName => 'Please enter a task name';

  @override
  String get pleaseEnterNumber => 'Please enter a number';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number (1 or more)';

  @override
  String get pleaseEnterEmailAddress => 'Please enter an email address';

  @override
  String errorLoadingMembers(String error) => 'Error loading members: $error';

  @override
  String errorLoadingInvitations(String error) =>
      'Error loading invitations: $error';

  // Task list members
  @override
  String membersIn(String taskListName) => 'Members in $taskListName';

  @override
  String get cancelInvitation => 'Cancel Invitation';

  @override
  String get cancelInvite => 'Cancel Invite';

  @override
  String get changePermissionLevel => 'Change Permission Level';

  @override
  String changePermissionFor(String userName) =>
      'Change permission level for $userName:';

  @override
  String get canEdit => 'Can Edit';

  @override
  String get canEditDescription => 'Can modify tasks and settings';

  @override
  String get canView => 'Can View';

  @override
  String get canViewDescription => 'Can only view and complete tasks';

  @override
  String get noMembers => 'No members yet';

  @override
  String invitedBy(String userName) => 'Invited by $userName';

  // Task details
  @override
  String tasksIn(String taskListName) => 'Tasks in $taskListName';

  @override
  String get alarmTimeOptional => 'Alarm Time (optional)';

  @override
  String get noAlarmSet => 'No alarm set';

  @override
  String get completionWindowOptional => 'Completion Window (hours, optional)';

  @override
  String get completionWindowHelper => 'How many hours after alarm to complete';

  @override
  String get inactiveTasksHidden => 'Inactive tasks won\'t show up for completion';

  @override
  String streakCount(int count) => '${count}x streak';

  // Send invitation
  @override
  String inviteSomeoneTo(String taskListName) => 'Invite someone to "$taskListName"';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterEmailToInvite => 'Enter the email of the person to invite';

  @override
  String get sendInvite => 'Send Invite';

  // Task fields
  @override
  String get taskListName => 'Task List Name';

  @override
  String get alarmTime => 'Alarm Time';

  @override
  String get completionWindow => 'Completion Window';

  // Notifications
  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String get dismissNotification => 'Dismiss Notification';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get notificationDismissed => 'Notification dismissed';

  @override
  String get confirmDismissNotification => 'Are you sure you want to dismiss this notification?';

  @override
  String get newInvitation => 'New Invitation';

  @override
  String get invitationWasAccepted => 'Invitation Accepted';

  @override
  String get invitationWasDeclined => 'Invitation Declined';

  @override
  String get taskDue => 'Task Due';

  @override
  String get inList => 'in';

  @override
  String get refresh => 'Refresh';

  @override
  String get failedToAcceptInvitation => 'Failed to accept invitation';

  @override
  String get failedToDeclineInvitation => 'Failed to decline invitation';

  // Time formatting
  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) => '${minutes}m ago';

  @override
  String hoursAgo(int hours) => '${hours}h ago';

  @override
  String daysAgo(int days) => '${days}d ago';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get older => 'Older';

  // Upcoming Tasks
  @override
  String get upcomingTasks => 'Upcoming';

  @override
  String get noUpcomingTasks => 'No upcoming tasks';

  @override
  String get allCaughtUpWithTasks => 'You\'re all caught up! No tasks due in the next 2 weeks.';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueInDays(int days) => 'Due in $days days';

  @override
  String get overdue => 'Overdue';

  @override
  String dueDaysAgo(int days) => 'Due $days days ago';

  @override
  String get taskCompletedSuccess => 'Task completed successfully';

  @override
  String get streakContinued => 'Streak continued!';

  @override
  String streakExtended(int count) => 'Streak extended to ${count}x!';

  @override
  String keepStreakGoing(int count) => 'Keep your ${count}x streak going!';

  @override
  String get failedToCompleteTask => 'Failed to complete task';

  @override
  String get completeEarlierTasksFirst => 'Complete earlier tasks first';

  @override
  String get keepItGoing => 'Keep it going!';

  @override
  String streakAtRisk(int count) => '⚠️ ${count}x streak at risk!';

  @override
  String get whenDidYouCompleteThis => 'When did you complete this?';

  @override
  String get howDidItGo => 'How did it go?';

  @override
  String get addNoteHint => 'Add a note about this completion...';

  @override
  String get addNote => 'Add a note';

  @override
  String get completing => 'Completing...';

  @override
  String get done => 'Done!';

  @override
  String get completeTaskButton => 'Complete Task!';

  // Task History
  @override
  String get taskHistory => 'Task History';

  @override
  String taskHistoryFor(String taskName) => 'History for "$taskName"';

  @override
  String get noCompletionsYet => 'No completions yet';

  @override
  String get noCompletionsYetDescription =>
      'This task hasn\'t been completed yet. Complete it to start tracking your progress!';

  @override
  String get completedBy => 'Completed by';

  @override
  String completedOn(String date) => 'Completed on $date';

  @override
  String completedAt(String time) => 'at $time';

  @override
  String get onTime => 'On time';

  @override
  String get late => 'Late';

  @override
  String get contributedToStreak => 'Contributed to streak';

  @override
  String get didNotContributeToStreak => 'Did not contribute to streak';

  @override
  String get withComment => 'With comment';

  @override
  String totalCompletions(int count) =>
      '$count ${count == 1 ? 'completion' : 'completions'}';

  @override
  String get loadingHistory => 'Loading history...';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String errorLoadingHistoryDetails(String error) =>
      'Failed to load task history: $error';

  @override
  String get filter => 'Filter';

  @override
  String get allTime => 'All Time';

  @override
  String get thisWeek => 'This Week';

  @override
  String get later => 'Later';

  @override
  String get thisMonth => 'This Month';

  @override
  String get last3Months => 'Last 3 Months';

  // Form fields and dialogs
  @override
  String get enterTaskName => 'Enter task name';

  @override
  String get addTaskDetails => 'Add task details';

  @override
  String get noAlarm => 'No alarm set';

  @override
  String get clearAlarm => 'Clear alarm';

  @override
  String get completionWindowHours => 'Completion Window (hours)';

  @override
  String get completionWindowHint => 'e.g., 24';

  @override
  String get hoursAfterAlarm => 'Hours after alarm to complete';

  @override
  String get inactiveTasksWontShow => 'Inactive tasks won\'t show up for completion';

  @override
  String get enterTaskListName => 'Enter task list name';

  @override
  String get failedToCreateTaskList => 'Failed to create task list';

  // AI Suggestions
  @override
  String get aiSuggestions => 'AI Suggestions';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get poweredByAi => 'Powered by AI';

  @override
  String get failedToFetchSuggestions => 'Failed to fetch suggestions';

  @override
  String get loadingSuggestions => 'Loading suggestions...';

  @override
  String get searchWithAI => 'Search with AI';

  @override
  String get noSuggestions => 'No suggestions available';

  @override
  String get back => 'Back';

  @override
  String get clear => 'Clear';

  // Weekdays (full names)
  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  // Weekdays (short names - 2 letters)
  @override
  String get mondayShort => 'Mo';

  @override
  String get tuesdayShort => 'Tu';

  @override
  String get wednesdayShort => 'We';

  @override
  String get thursdayShort => 'Th';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Sa';

  @override
  String get sundayShort => 'Su';

  // Schedule strings
  @override
  String get recurrence => 'Recurrence';

  @override
  String get every => 'Every';

  @override
  String get selectDays => 'Select days';

  @override
  String get onDays => 'On days';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get repeatMode => 'Repeat mode';

  @override
  String get simpleInterval => 'Interval';

  @override
  String get specificDays => 'Specific days';

  @override
  String get simpleIntervalDescription => 'Every X days/weeks/months';

  @override
  String get specificDaysDescription => 'Choose specific weekdays';

  @override
  String get orCustomize => 'or customize';

  @override
  String weekUnit(int count) => count == 1 ? 'week' : 'weeks';

  // Timeline / Completed Tasks
  @override
  String get recentlyCompleted => 'Recently Completed';

  @override
  String tasksCompletedCount(int count) =>
      count == 1 ? '1 task completed' : '$count tasks completed';

  @override
  String get now => 'Now';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String completedAgo(String timeAgo) => 'Completed $timeAgo';

  @override
  String get expired => 'Expired';

  @override
  String expiredAgo(String timeAgo) => 'Expired $timeAgo';

  @override
  String get taskExpired => 'Task expired';

  @override
  String get recentActivity => 'Recent Activity';

  // Seasonal Scheduling
  @override
  String get activeMonths => 'Active months';

  @override
  String get yearRound => 'Year-round';

  @override
  String monthsSelected(int count) => '$count months selected';

  @override
  String monthRange(String start, String end) => '$start–$end';

  @override
  String get summer => 'Summer';

  @override
  String get winter => 'Winter';

  @override
  String get growingSeason => 'Growing season';

  @override
  String get allYear => 'All year';

  @override
  String get orSelectManually => 'Or select months';

  @override
  String get presets => 'Presets';

  // Month names (full)
  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  // Month names (short - 3 letters)
  @override
  String get januaryShort => 'Jan';

  @override
  String get februaryShort => 'Feb';

  @override
  String get marchShort => 'Mar';

  @override
  String get aprilShort => 'Apr';

  @override
  String get mayShort => 'May';

  @override
  String get juneShort => 'Jun';

  @override
  String get julyShort => 'Jul';

  @override
  String get augustShort => 'Aug';

  @override
  String get septemberShort => 'Sep';

  @override
  String get octoberShort => 'Oct';

  @override
  String get novemberShort => 'Nov';

  @override
  String get decemberShort => 'Dec';
}
