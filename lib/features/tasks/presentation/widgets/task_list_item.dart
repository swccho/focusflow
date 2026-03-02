import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

/// Formats task created-at for display (e.g. "2:30 PM" today or "3/2").
String formatTaskTime(DateTime dateTime) {
  final now = DateTime.now();
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    if (hour < 12) return '${hour == 0 ? 12 : hour}:$minute AM';
    return '${hour == 12 ? 12 : hour - 12}:$minute PM';
  }
  return '${dateTime.month}/${dateTime.day}';
}

/// A single task row: checkbox, title (animated strike-through when done),
/// optional timestamp, delete. Hover and optional divider.
class TaskListItem extends StatefulWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.showTimestamp = true,
    this.showDividerBelow = false,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool showTimestamp;
  final bool showDividerBelow;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _hover
                ? Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4)
                : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Checkbox(
                value: widget.task.isDone,
                onChanged: (_) => widget.onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              title: Column(
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
                  if (widget.showTimestamp) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatTaskTime(widget.task.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: widget.onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        if (widget.showDividerBelow)
          Divider(
            height: 1,
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
