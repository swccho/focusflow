import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/gradient_background.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/controllers/task_controller.dart';
import '../../features/tasks/presentation/widgets/task_list_item.dart';
import '../../features/stats/presentation/widgets/today_summary_card.dart';
import '../../features/timer/domain/entities/pomodoro_settings.dart';
import '../../features/timer/presentation/providers/timer_settings_provider.dart';
import '../../features/timer/presentation/widgets/pomodoro_card.dart';
import '../../features/timer/presentation/widgets/pomodoro_settings_dialog.dart';

/// Breakpoints for responsive dashboard layout.
const double _breakpointLarge = 1100;
const double _breakpointMedium = 700;

/// Dashboard: full-width desktop layout. 2-column on large/medium, stacked on small.
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= _breakpointLarge;
    final isMedium = width >= _breakpointMedium && width < _breakpointLarge;
    final isSmall = width < _breakpointMedium;
    final columnGap = isLarge ? AppSpacing.lg : (isMedium ? AppSpacing.md : AppSpacing.sm);
    final rowGap = isLarge ? AppSpacing.lg : (isMedium ? AppSpacing.md : AppSpacing.sm);

    return Scaffold(
      body: GradientBackground(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings (top-right)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () {
                    final settings = ref
                            .read(pomodoroSettingsProvider)
                            .valueOrNull ??
                        const PomodoroSettings();
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => PomodoroSettingsDialog(
                        initialSettings: settings,
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: isSmall ? _buildStackedLayout(rowGap) : _buildTwoColumnLayout(columnGap, rowGap),
            ),
          ],
        ),
      ),
    );
  }

  /// Large / medium: left column (Pomodoro + tasks), right column (summary + placeholder).
  Widget _buildTwoColumnLayout(double columnGap, double rowGap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: const PomodoroCard(),
              ),
              SizedBox(height: rowGap),
              _QuickAddTaskBar(
                controller: _taskController,
                focusNode: _focusNode,
                isAdding: _isAdding,
                onSubmitted: _submitQuickAdd,
              ),
              SizedBox(height: AppSpacing.sm),
              Expanded(
                child: const _TaskPreviewList(),
              ),
            ],
          ),
        ),
        SizedBox(width: columnGap),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TodaySummaryCard(),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }

  /// Small: vertical stack.
  Widget _buildStackedLayout(double gap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: const PomodoroCard(),
        ),
        SizedBox(height: gap),
        _QuickAddTaskBar(
          controller: _taskController,
          focusNode: _focusNode,
          isAdding: _isAdding,
          onSubmitted: _submitQuickAdd,
        ),
        SizedBox(height: AppSpacing.sm),
        Expanded(
          child: const _TaskPreviewList(),
        ),
        SizedBox(height: gap),
        const TodaySummaryCard(),
      ],
    );
  }
}

class _QuickAddTaskBar extends StatefulWidget {
  const _QuickAddTaskBar({
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
  State<_QuickAddTaskBar> createState() => _QuickAddTaskBarState();
}

class _QuickAddTaskBarState extends State<_QuickAddTaskBar> {
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
                    hintText: 'Add a task...',
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
          return Center(
            child: Text(
              'No tasks yet. Add one above.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView(
          children: [
            Text(
              'Up Next',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...preview.asMap().entries.expand((e) {
              final isLast = e.key == preview.length - 1;
              return [
                _TaskPreviewItem(
                  task: e.value,
                  onToggle: () => ref
                      .read(taskControllerProvider.notifier)
                      .toggleTask(e.value.id),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.5),
                  ),
              ];
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                err.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => ref.invalidate(taskControllerProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskPreviewItem extends StatefulWidget {
  const _TaskPreviewItem({
    required this.task,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onToggle;

  @override
  State<_TaskPreviewItem> createState() => _TaskPreviewItemState();
}

class _TaskPreviewItemState extends State<_TaskPreviewItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hover
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.task.isDone,
                onChanged: (_) => widget.onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: widget.task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: widget.task.isDone
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                      child: Text(widget.task.title),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTaskTime(widget.task.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
