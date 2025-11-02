/// Recurrence pattern unit for tasks (matches Java ChronoUnit)
enum RepeatUnit {
  DAYS,
  WEEKS,
  MONTHS,
  YEARS;

  String toJson() => name;
  static RepeatUnit fromJson(String value) => RepeatUnit.values.byName(value);
}

/// Permission levels for shared task lists
enum AdminLevel {
  CAN_EDIT,
  CAN_VIEW;

  String toJson() => name;
  static AdminLevel fromJson(String value) => AdminLevel.values.byName(value);
}

/// Invitation status
enum InvitationState {
  PENDING,
  SENT,
  ACCEPTED,
  DECLINED,
  CANCELLED;

  String toJson() => name;
  static InvitationState fromJson(String value) =>
      InvitationState.values.byName(value);
}

/// Image source types
enum ImageSource {
  USER,
  TASK_LIST,
  TASK,
  TASK_INSTANCE;

  String toJson() => name;
  static ImageSource fromJson(String value) =>
      ImageSource.values.byName(value);
}
