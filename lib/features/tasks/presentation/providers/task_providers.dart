import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

/// Provides the Hive "tasks" box. Must be overridden in main with the opened box.
final tasksBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'Tasks box must be overridden in main (ProviderScope overrides)',
  );
});

/// Provides [TaskLocalDataSource] using the injected tasks box.
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final box = ref.watch(tasksBoxProvider);
  return TaskLocalDataSource(box);
});

/// Provides the task repository implementation.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(dataSource);
});
