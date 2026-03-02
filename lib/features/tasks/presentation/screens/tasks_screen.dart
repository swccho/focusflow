import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_list_item.dart';

/// Tasks screen: add, list, toggle, delete. Premium desktop layout.
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _retry() {
    ref.invalidate(taskControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncTasks = ref.watch(taskControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tasks'),
      ),
      body: GradientBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AddTaskRow(
              controller: _controller,
              focusNode: _focusNode,
              isAdding: _isAdding,
              onSubmitted: _submitAdd,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: asyncTasks.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks yet. Add one above.',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final sorted = List.from(tasks)
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return ListView.builder(
                    itemCount: sorted.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            'Up Next',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        );
                      }
                      final task = sorted[index - 1];
                      final isLast = index == sorted.length;
                      return TaskListItem(
                        task: task,
                        showTimestamp: true,
                        showDividerBelow: !isLast,
                        onToggle: () => ref
                            .read(taskControllerProvider.notifier)
                            .toggleTask(task.id),
                        onDelete: () {
                          final messenger = ScaffoldMessenger.of(context);
                          ref
                              .read(taskControllerProvider.notifier)
                              .deleteTask(task.id)
                              .then((_) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Text('Task removed'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          });
                        },
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
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh_rounded),
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
    );
  }
}

class _AddTaskRow extends StatefulWidget {
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
  State<_AddTaskRow> createState() => _AddTaskRowState();
}

class _AddTaskRowState extends State<_AddTaskRow> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final enabled =
            widget.controller.text.trim().isNotEmpty && !widget.isAdding;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.5
                      : 0.7,
                ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                  : Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
              width: focused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  decoration: InputDecoration(
                    hintText: 'New task...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onSubmitted(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  'Enter ↵',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FilledButton(
                onPressed: enabled ? widget.onSubmitted : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}
