import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/tasks/data/models/task_model.dart';

/// Initializes Hive and opens required boxes. Safe to call before runApp.
/// Does not throw; logs errors and returns false on failure.
Future<bool> initializeHive() async {
  try {
    await Hive.initFlutter();
    registerTaskModelAdapter();
    await Hive.openBox('tasks');
    await Hive.openBox('settings');
    return true;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Hive initialization failed: $e');
      debugPrint(stackTrace.toString());
    }
    return false;
  }
}
