import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeHive();

  runApp(
    const ProviderScope(
      child: FocusFlowApp(),
    ),
  );
}
