import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/task_controller.dart';
import '../widgets/task_list_item.dart';

/// Tasks screen: add, list, toggle, delete. Desktop-friendly layout.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAdding = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitAdd() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);
    await ref.read(taskControllerProvider.notifier).addTask(title);
    if (mounted) {
      _controller.clear();
      setState(() => _isAdding = false);
    }
  }

  void _retry() {
    ref.invalidate(taskControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncTasks = ref.watch(taskControllerProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                _AddTaskRow(
                  controller: _controller,
                  focusNode: _focusNode,
                  isAdding: _isAdding,
                  onSubmitted: _submitAdd,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: asyncTasks.when(
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            'No tasks yet. Add one above.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskListItem(
                            task: task,
                            onToggle: () => ref
                                .read(taskControllerProvider.notifier)
                                .toggleTask(task.id),
                            onDelete: () => ref
                                .read(taskControllerProvider.notifier)
                                .deleteTask(task.id),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            err.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTaskRow extends StatelessWidget {
  const _AddTaskRow({
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
                  hintText: 'New task...',
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
