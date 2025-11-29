/// Urgency niveauer til visuel differentiering af opgaver
enum TaskUrgency { overdue, today, tomorrow, thisWeek, future }

/// Bestemmer urgency niveau ud fra forfaldsdato
TaskUrgency getTaskUrgency(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = taskDate.difference(today).inDays;

  if (difference < 0) return TaskUrgency.overdue;
  if (difference == 0) return TaskUrgency.today;
  if (difference == 1) return TaskUrgency.tomorrow;
  if (difference <= 7) return TaskUrgency.thisWeek;
  return TaskUrgency.future;
}
