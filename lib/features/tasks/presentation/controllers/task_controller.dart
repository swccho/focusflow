import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Controller for task list state. Loads on first access; errors are stored in state.
class TaskController extends AutoDisposeAsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final repo = ref.read(taskRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    try {
      await ref.read(taskRepositoryProvider).add(title.trim());
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTask(String id) async {
    try {
      await ref.read(taskRepositoryProvider).toggleDone(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await ref.read(taskRepositoryProvider).delete(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Exposes task list (loading / data / error) and controller for mutations.
final taskControllerProvider =
    AsyncNotifierProvider.autoDispose<TaskController, List<Task>>(
  TaskController.new,
);
