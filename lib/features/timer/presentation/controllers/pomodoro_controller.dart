import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro_mode.dart';
import '../../domain/entities/pomodoro_settings.dart';
import '../state/pomodoro_state.dart';
import '../providers/timer_settings_provider.dart';

/// Single source of truth for Pomodoro timer. One periodic timer; disposed on cancel.
class PomodoroController extends AutoDisposeNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroSettings get _currentSettings {
    final asyncSettings = ref.read(pomodoroSettingsProvider);
    return asyncSettings.valueOrNull ?? const PomodoroSettings();
  }

  @override
  PomodoroState build() {
    ref.onDispose(_cancelTimer);
    ref.listen(pomodoroSettingsProvider, (prev, next) {
      next.whenData((settings) {
        if (!state.isRunning) {
          final duration = state.mode == PomodoroMode.focus
              ? settings.focusMinutes * 60
              : settings.breakMinutes * 60;
          state = state.copyWith(remainingSeconds: duration);
        }
      });
    });
    final settings = _currentSettings;
    return PomodoroState(
      mode: PomodoroMode.focus,
      remainingSeconds: settings.focusMinutes * 60,
      isRunning: false,
      sessionsCompletedToday: 0,
      errorMessage: null,
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  int _durationSecondsFor(PomodoroMode mode) {
    final settings = _currentSettings;
    return mode == PomodoroMode.focus
        ? settings.focusMinutes * 60
        : settings.breakMinutes * 60;
  }

  void _tick() {
    final current = state;
    if (current.remainingSeconds <= 0) {
      final nextMode = current.mode == PomodoroMode.focus
          ? PomodoroMode.break_
          : PomodoroMode.focus;
      final completedToday = current.mode == PomodoroMode.focus
          ? current.sessionsCompletedToday + 1
          : current.sessionsCompletedToday;
      state = current.copyWith(
        mode: nextMode,
        remainingSeconds: _durationSecondsFor(nextMode),
        sessionsCompletedToday: completedToday,
        errorMessage: null,
      );
      return;
    }
    state = current.copyWith(
      remainingSeconds: current.remainingSeconds - 1,
      errorMessage: null,
    );
  }

  void start() {
    if (state.isRunning) return;
    _cancelTimer();
    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      state = state.copyWith(isRunning: true, errorMessage: null);
    } catch (e, _) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void pause() {
    _cancelTimer();
    state = state.copyWith(isRunning: false, errorMessage: null);
  }

  void reset() {
    _cancelTimer();
    final duration = _durationSecondsFor(state.mode);
    state = state.copyWith(
      remainingSeconds: duration,
      isRunning: false,
      errorMessage: null,
    );
  }

  void switchMode(PomodoroMode mode) {
    _cancelTimer();
    final duration = _durationSecondsFor(mode);
    state = state.copyWith(
      mode: mode,
      remainingSeconds: duration,
      isRunning: false,
      errorMessage: null,
    );
  }

  Future<void> updateSettings(PomodoroSettings settings) async {
    await ref.read(pomodoroSettingsProvider.notifier).saveSettings(settings);
    if (!state.isRunning) {
      final duration = state.mode == PomodoroMode.focus
          ? settings.focusMinutes * 60
          : settings.breakMinutes * 60;
      state = state.copyWith(remainingSeconds: duration, errorMessage: null);
    }
  }
}
