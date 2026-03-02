import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

/// Thrown when a repository operation fails (e.g. wrapped from datasource).
final class TaskRepositoryException implements Exception {
  const TaskRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'TaskRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Task repository implementation using [TaskLocalDataSource].
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dataSource);

  final TaskLocalDataSource _dataSource;
  static const _uuid = Uuid();

  @override
  Future<List<Task>> getAll() async {
    try {
      final models = await _dataSource.getAll();
      return models.map((m) => m.toEntity()).toList();
    } on TaskLocalException catch (e) {
      throw TaskRepositoryException(e.message, e.cause);
    }
  }

  @override
  Future<void> add(String title) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      isDone: false,
      createdAt: now,
      doneAt: null,
    );
    try {
      await _dataSource.upsert(TaskModel.fromEntity(task));
    } on TaskLocalException catch (e) {
      throw TaskRepositoryException(e.message, e.cause);
    }
  }

  @override
  Future<void> toggleDone(String id) async {
    final list = await getAll();
    final index = list.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final task = list[index];
    final newDone = !task.isDone;
    final updated = task.copyWith(
      isDone: newDone,
      doneAt: newDone ? DateTime.now() : null,
    );
    try {
      await _dataSource.upsert(TaskModel.fromEntity(updated));
    } on TaskLocalException catch (e) {
      throw TaskRepositoryException(e.message, e.cause);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.deleteById(id);
    } on TaskLocalException catch (e) {
      throw TaskRepositoryException(e.message, e.cause);
    }
  }
}
