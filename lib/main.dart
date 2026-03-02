import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/presentation/providers/task_providers.dart';
import 'features/timer/presentation/providers/timer_settings_provider.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeHive();

  Box<dynamic>? tasksBox;
  if (Hive.isBoxOpen('tasks')) {
    tasksBox = Hive.box('tasks');
  } else {
    try {
      await Hive.initFlutter();
      registerTaskModelAdapter();
      tasksBox = await Hive.openBox('tasks');
    } catch (_) {}
  }

  Box<dynamic>? settingsBox;
  if (Hive.isBoxOpen('settings')) {
    settingsBox = Hive.box('settings');
  }

  final overrides = <Override>[
    if (tasksBox != null) tasksBoxProvider.overrideWithValue(tasksBox),
    if (settingsBox != null) settingsBoxProvider.overrideWithValue(settingsBox),
  ];

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const FocusFlowApp(),
    ),
  );
}
