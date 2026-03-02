import '../entities/task.dart';

/// Contract for task persistence. Pure domain; no Flutter/data imports.
abstract interface class TaskRepository {
  Future<List<Task>> getAll();

  Future<void> add(String title);

  Future<void> toggleDone(String id);

  Future<void> delete(String id);
}
