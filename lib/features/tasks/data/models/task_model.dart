import 'package:hive/hive.dart';

import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAtMs,
    this.doneAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isDone;

  @HiveField(3)
  final int createdAtMs;

  @HiveField(4)
  final int? doneAtMs;

  Task toEntity() => Task(
        id: id,
        title: title,
        isDone: isDone,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
        doneAt: doneAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(doneAtMs!)
            : null,
      );

  static TaskModel fromEntity(Task entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        isDone: entity.isDone,
        createdAtMs: entity.createdAt.millisecondsSinceEpoch,
        doneAtMs: entity.doneAt?.millisecondsSinceEpoch,
      );
}

/// Registers [TaskModel] Hive adapter. Call before opening the tasks box.
void registerTaskModelAdapter() {
  Hive.registerAdapter(TaskModelAdapter());
}
