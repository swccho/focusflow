import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/controllers/task_controller.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/stats/presentation/widgets/today_summary_card.dart';
import '../../features/timer/presentation/widgets/pomodoro_card.dart';

/// Dashboard: Pomodoro card, quick add task, task preview, link to full Tasks.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _taskController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAdding = false;

  @override
  void dispose() {
    _taskController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitQuickAdd() async {
    final title = _taskController.text.trim();
    if (title.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);
    await ref.read(taskControllerProvider.notifier).addTask(title);
    if (mounted) {
      _taskController.clear();
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PomodoroCard(),
                const SizedBox(height: 24),
                const TodaySummaryCard(),
                const SizedBox(height: 32),
                _QuickAddTaskRow(
                  controller: _taskController,
                  focusNode: _focusNode,
                  isAdding: _isAdding,
                  onSubmitted: _submitQuickAdd,
                ),
                const SizedBox(height: 24),
                const _TaskPreviewList(),
                const SizedBox(height: 24),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TasksScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All Tasks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddTaskRow extends StatelessWidget {
  const _QuickAddTaskRow({
    required this.controller,
    required this.focusNode,
    required this.isAdding,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isAdding;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final enabled = controller.text.trim().isNotEmpty && !isAdding;
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Quick add task...',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmitted(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: enabled ? onSubmitted : null,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _TaskPreviewList extends ConsumerWidget {
  const _TaskPreviewList();

  static const int _maxPreview = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskControllerProvider);

    return asyncTasks.when(
      data: (tasks) {
        final sorted = List<Task>.from(tasks)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final preview = sorted.take(_maxPreview).toList();

        if (preview.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No tasks yet. Add one above or open View All Tasks.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent tasks',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...preview.map(
              (task) => _TaskPreviewItem(
                task: task,
                onToggle: () => ref
                    .read(taskControllerProvider.notifier)
                    .toggleTask(task.id),
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Could not load tasks.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

class _TaskPreviewItem extends StatelessWidget {
  const _TaskPreviewItem({
    required this.task,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
