import 'package:equatable/equatable.dart';

/// Immutable Pomodoro durations (minutes). Pure Dart.
final class PomodoroSettings extends Equatable {
  const PomodoroSettings({
    this.focusMinutes = 25,
    this.breakMinutes = 5,
  });

  final int focusMinutes;
  final int breakMinutes;

  @override
  List<Object?> get props => [focusMinutes, breakMinutes];

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? breakMinutes,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
    );
  }
}
