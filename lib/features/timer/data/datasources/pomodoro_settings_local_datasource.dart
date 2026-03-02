import 'package:hive/hive.dart';

import '../../domain/entities/pomodoro_settings.dart';

/// Thrown when settings load/save fails.
final class PomodoroSettingsLocalException implements Exception {
  const PomodoroSettingsLocalException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'PomodoroSettingsLocalException: $message${cause != null ? ' ($cause)' : ''}';
}

const String _key = 'pomodoro_settings';

/// Persists [PomodoroSettings] in a Hive box. Box injected via constructor.
class PomodoroSettingsLocalDataSource {
  PomodoroSettingsLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const _default = PomodoroSettings();

  /// Loads saved settings. Returns defaults (25/5) if missing or corrupted.
  Future<PomodoroSettings> load() async {
    try {
      final raw = _box.get(_key);
      if (raw is! Map) return _default;
      final focus = raw['focusMinutes'];
      final break_ = raw['breakMinutes'];
      if (focus is! int || break_ is! int) return _default;
      if (focus < 1 || focus > 120 || break_ < 1 || break_ > 60) return _default;
      return PomodoroSettings(focusMinutes: focus, breakMinutes: break_);
    } catch (_) {
      return _default;
    }
  }

  /// Saves settings.
  Future<void> save(PomodoroSettings settings) async {
    try {
      await _box.put(_key, {
        'focusMinutes': settings.focusMinutes,
        'breakMinutes': settings.breakMinutes,
      });
    } catch (e, _) {
      throw PomodoroSettingsLocalException('Failed to save settings', e);
    }
  }
}
