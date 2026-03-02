import 'package:focusflow/features/timer/domain/entities/pomodoro_mode.dart';
import 'package:focusflow/features/timer/domain/entities/pomodoro_settings.dart';
import 'package:focusflow/features/timer/presentation/providers/timer_providers.dart';
import 'package:focusflow/features/timer/presentation/providers/timer_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake settings notifier (extends real type so overrideWith accepts it).
class _FakePomodoroSettingsNotifier extends PomodoroSettingsNotifier {
  @override
  Future<PomodoroSettings> build() async =>
      const PomodoroSettings(focusMinutes: 25, breakMinutes: 5);
}

void main() {
  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        pomodoroSettingsProvider.overrideWith(_FakePomodoroSettingsNotifier.new),
      ],
    );
  }

  test('initial state has isRunning false and full focus duration', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await container.read(pomodoroSettingsProvider.future);

    final state = container.read(pomodoroControllerProvider);
    expect(state.isRunning, false);
    expect(state.mode, PomodoroMode.focus);
    expect(state.remainingSeconds, 25 * 60);
    expect(state.sessionsCompletedToday, 0);
  });

  test('start() sets isRunning true', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await container.read(pomodoroSettingsProvider.future);

    container.read(pomodoroControllerProvider.notifier).start();
    final state = container.read(pomodoroControllerProvider);
    expect(state.isRunning, true);
  });

  test('pause() stops decrement (isRunning false)', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await container.read(pomodoroSettingsProvider.future);

    container.read(pomodoroControllerProvider.notifier).start();
    container.read(pomodoroControllerProvider.notifier).pause();
    final state = container.read(pomodoroControllerProvider);
    expect(state.isRunning, false);
  });

  test('reset() restores remainingSeconds to full duration', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await container.read(pomodoroSettingsProvider.future);

    final notifier = container.read(pomodoroControllerProvider.notifier);
    notifier.start();
    notifier.reset();

    final state = container.read(pomodoroControllerProvider);
    expect(state.isRunning, false);
    expect(state.remainingSeconds, 25 * 60);
  });
}
