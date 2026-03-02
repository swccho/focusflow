import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/domain/utils/task_stats.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../timer/presentation/providers/timer_providers.dart';

/// Desktop-friendly card: Today Summary (tasks completed + focus sessions).
class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskControllerProvider);
    final timerState = ref.watch(pomodoroControllerProvider);

    final tasksCount = asyncTasks.when(
      data: (tasks) => completedTasksTodayCount(tasks, DateTime.now()).toString(),
      loading: () => '-',
      error: (_, _) => '-',
    );

    final sessionsCount = timerState.sessionsCompletedToday.toString();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Tasks completed: $tasksCount',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Focus sessions: $sessionsCount',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
