import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/presentation/providers/task_providers.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeHive();

  // Provide tasks box for Riverpod (use if already open, else try opening it)
  Box<dynamic>? tasksBox;
  if (Hive.isBoxOpen('tasks')) {
    tasksBox = Hive.box('tasks');
  } else {
    try {
      await Hive.initFlutter();
      registerTaskModelAdapter();
      tasksBox = await Hive.openBox('tasks');
    } catch (_) {
      // Leave null; Tasks screen will show error + Retry
    }
  }

  final overrides = <Override>[
    if (tasksBox != null) tasksBoxProvider.overrideWithValue(tasksBox),
  ];

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const FocusFlowApp(),
    ),
  );
}
