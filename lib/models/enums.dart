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

/// Days of the week (matches Java DayOfWeek)
/// Used for weekly pattern scheduling
enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY;

  String toJson() => name;
  static DayOfWeek fromJson(String value) => DayOfWeek.values.byName(value);
}

/// Gender values (matches Java Gender enum)
/// Used for user profile personalization
enum Gender {
  MALE,
  FEMALE,
  OTHER;

  String toJson() => name;
  static Gender fromJson(String value) => Gender.values.byName(value);
}

/// Months of the year (matches Java Month)
/// Used for seasonal scheduling
enum Month {
  JANUARY,
  FEBRUARY,
  MARCH,
  APRIL,
  MAY,
  JUNE,
  JULY,
  AUGUST,
  SEPTEMBER,
  OCTOBER,
  NOVEMBER,
  DECEMBER;

  String toJson() => name;
  static Month fromJson(String value) => Month.values.byName(value);

  /// Returns the 1-based month number (January = 1, December = 12)
  int get monthNumber => index + 1;

  /// Creates a Month from a 1-based month number
  static Month fromMonthNumber(int monthNumber) {
    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError('Month number must be between 1 and 12');
    }
    return Month.values[monthNumber - 1];
  }
}
