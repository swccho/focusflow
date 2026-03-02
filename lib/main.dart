import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/tasks/presentation/providers/task_providers.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveOk = await initializeHive();
  final overrides = <Override>[
    if (hiveOk) tasksBoxProvider.overrideWithValue(Hive.box('tasks')),
  ];

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const FocusFlowApp(),
    ),
  );
}
