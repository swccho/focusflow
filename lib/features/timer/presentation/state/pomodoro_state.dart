import 'package:equatable/equatable.dart';

import '../../domain/entities/pomodoro_mode.dart';

/// Immutable timer UI state.
final class PomodoroState extends Equatable {
  const PomodoroState({
    required this.mode,
    required this.remainingSeconds,
    required this.isRunning,
    this.sessionsCompletedToday = 0,
    this.errorMessage,
  });

  final PomodoroMode mode;
  final int remainingSeconds;
  final bool isRunning;
  final int sessionsCompletedToday;
  final String? errorMessage;

  int get remainingMinutes => remainingSeconds ~/ 60;

  /// Formatted "MM:SS" for display.
  String get remainingDisplay {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props =>
      [mode, remainingSeconds, isRunning, sessionsCompletedToday, errorMessage];

  PomodoroState copyWith({
    PomodoroMode? mode,
    int? remainingSeconds,
    bool? isRunning,
    int? sessionsCompletedToday,
    String? errorMessage,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      sessionsCompletedToday:
          sessionsCompletedToday ?? this.sessionsCompletedToday,
      errorMessage: errorMessage,
    );
  }
}
