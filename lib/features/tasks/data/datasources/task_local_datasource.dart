import 'package:hive/hive.dart';

import '../models/task_model.dart';

/// Thrown when a local task operation fails.
final class TaskLocalException implements Exception {
  const TaskLocalException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'TaskLocalException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Local persistence for tasks using a Hive box. Receives the box via constructor.
class TaskLocalDataSource {
  TaskLocalDataSource(this._box);

  final Box<dynamic> _box;

  /// Returns all stored tasks as [TaskModel]. Order is box iteration order.
  Future<List<TaskModel>> getAll() async {
    try {
      final list = <TaskModel>[];
      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is TaskModel) {
          list.add(value);
        }
      }
      return list;
    } catch (e, _) {
      throw TaskLocalException('Failed to get all tasks', e);
    }
  }

  /// Inserts or updates a task by id.
  Future<void> upsert(TaskModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e, _) {
      throw TaskLocalException('Failed to upsert task ${model.id}', e);
    }
  }

  /// Removes the task with the given id. No-op if not present.
  Future<void> deleteById(String id) async {
    try {
      await _box.delete(id);
    } catch (e, _) {
      throw TaskLocalException('Failed to delete task $id', e);
    }
  }
}
