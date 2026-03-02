import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro_settings.dart';

/// In-memory Pomodoro settings. Not persisted yet.
final pomodoroSettingsProvider =
    StateProvider<PomodoroSettings>((ref) => const PomodoroSettings());
