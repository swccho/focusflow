import '../entities/task.dart';

/// Pure helpers for task statistics. No Flutter imports.

/// True when [date] is the same local calendar day as [now].
bool _isSameLocalDay(DateTime date, DateTime now) {
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Count of tasks completed today (isDone, doneAt not null, doneAt on same local day as [now]).
int completedTasksTodayCount(List<Task> tasks, DateTime now) {
  return tasks.where((t) {
    if (!t.isDone || t.doneAt == null) return false;
    return _isSameLocalDay(t.doneAt!, now);
  }).length;
}
