import 'package:focusflow/features/tasks/domain/entities/task.dart';
import 'package:focusflow/features/tasks/domain/utils/task_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime today;
  late DateTime yesterday;

  setUp(() {
    today = DateTime(2025, 3, 2, 12, 0);
    yesterday = DateTime(2025, 3, 1, 12, 0);
  });

  test('completedTasksTodayCount counts only tasks done today (doneAt same day)', () {
    final tasks = [
      Task(
        id: '1',
        title: 'A',
        isDone: true,
        createdAt: yesterday,
        doneAt: today,
      ),
      Task(
        id: '2',
        title: 'B',
        isDone: true,
        createdAt: today,
        doneAt: today,
      ),
    ];
    expect(completedTasksTodayCount(tasks, today), 2);
  });

  test('ignores tasks done on previous days', () {
    final tasks = [
      Task(
        id: '1',
        title: 'A',
        isDone: true,
        createdAt: yesterday,
        doneAt: yesterday,
      ),
      Task(
        id: '2',
        title: 'B',
        isDone: true,
        createdAt: today,
        doneAt: today,
      ),
    ];
    expect(completedTasksTodayCount(tasks, today), 1);
  });

  test('ignores tasks where doneAt is null', () {
    final tasks = [
      Task(
        id: '1',
        title: 'A',
        isDone: true,
        createdAt: today,
        doneAt: null,
      ),
      Task(
        id: '2',
        title: 'B',
        isDone: true,
        createdAt: today,
        doneAt: today,
      ),
    ];
    expect(completedTasksTodayCount(tasks, today), 1);
  });

  test('ignores tasks where isDone is false', () {
    final tasks = [
      Task(
        id: '1',
        title: 'A',
        isDone: false,
        createdAt: today,
        doneAt: today,
      ),
    ];
    expect(completedTasksTodayCount(tasks, today), 0);
  });
}
