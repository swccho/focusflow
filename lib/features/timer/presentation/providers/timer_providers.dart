import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/pomodoro_controller.dart';
import '../state/pomodoro_state.dart';
import 'timer_settings_provider.dart';

/// Re-exports timer-related providers for the feature.
/// Use [pomodoroControllerProvider] for state, [pomodoroSettingsProvider] for settings.
final pomodoroControllerProvider =
    NotifierProvider.autoDispose<PomodoroController, PomodoroState>(
  PomodoroController.new,
);
