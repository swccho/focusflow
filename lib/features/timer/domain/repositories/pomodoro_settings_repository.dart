import '../entities/pomodoro_settings.dart';

/// Contract for persisting Pomodoro settings. Pure Dart.
abstract interface class PomodoroSettingsRepository {
  Future<PomodoroSettings> load();

  Future<void> save(PomodoroSettings settings);
}
