import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro_mode.dart';
import '../providers/timer_providers.dart';

/// Desktop-friendly Pomodoro timer card. Max width 560, Material 3.
class PomodoroCard extends ConsumerWidget {
  const PomodoroCard({super.key});

  static String _modeLabel(PomodoroMode mode) {
    return mode == PomodoroMode.focus ? 'Focus' : 'Break';
  }

  static String _remainingDisplay(int remainingSeconds) {
    final s = remainingSeconds.clamp(0, 999 * 60);
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroControllerProvider);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimerDisplay(
                modeLabel: _modeLabel(state.mode),
                remainingDisplay: _remainingDisplay(state.remainingSeconds),
              ),
              const SizedBox(height: 24),
              _ControlButtons(
                isRunning: state.isRunning,
                onStart: () => ref.read(pomodoroControllerProvider.notifier).start(),
                onPause: () => ref.read(pomodoroControllerProvider.notifier).pause(),
                onReset: () => ref.read(pomodoroControllerProvider.notifier).reset(),
              ),
              const SizedBox(height: 16),
              Text(
                'Sessions today: ${state.sessionsCompletedToday}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({
    required this.modeLabel,
    required this.remainingDisplay,
  });

  final String modeLabel;
  final String remainingDisplay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          modeLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          remainingDisplay,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}

class _ControlButtons extends StatelessWidget {
  const _ControlButtons({
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: isRunning ? onPause : onStart,
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(isRunning ? 'Pause' : 'Start'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
