import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/domain/utils/task_stats.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../timer/presentation/providers/timer_providers.dart';

/// Dashboard-style today summary: stat rows with icons and right-aligned numbers.
class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskControllerProvider);
    final timerState = ref.watch(pomodoroControllerProvider);

    final tasksCount = asyncTasks.when(
      data: (tasks) => completedTasksTodayCount(tasks, DateTime.now()).toString(),
      loading: () => '–',
      error: (_, _) => '–',
    );

    final sessionsCount = timerState.sessionsCompletedToday.toString();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.7,
          ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'Tasks completed',
              value: tasksCount,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.schedule_rounded,
              label: 'Focus sessions',
              value: sessionsCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 20, color: muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
