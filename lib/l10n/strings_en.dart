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
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

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
  String dayStreak(int count) => '$count day streak';

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
  String get notificationDismissed => 'Notification dismissed';

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
  String streakExtended(int count) => 'Streak extended to $count days!';

  @override
  String get failedToCompleteTask => 'Failed to complete task';

  @override
  String get completeEarlierTasksFirst => 'Complete earlier tasks first';

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
}
