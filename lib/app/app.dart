import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

/// Root widget for FocusFlow. Uses Material 3 with light and dark themes.
class FocusFlowApp extends ConsumerWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
