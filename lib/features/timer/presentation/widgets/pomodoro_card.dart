import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro_mode.dart';
import '../providers/timer_providers.dart';
import '../providers/timer_settings_provider.dart';

/// Hero Pomodoro timer card: circular progress, large timer, mode chip, pill buttons.
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
    final settings = ref.watch(pomodoroSettingsProvider).valueOrNull;
    final totalSeconds = state.mode == PomodoroMode.focus
        ? (settings?.focusMinutes ?? 25) * 60
        : (settings?.breakMinutes ?? 5) * 60;
    final progress = totalSeconds > 0 ? state.remainingSeconds / totalSeconds : 1.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.85,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeChip(mode: state.mode),
                const SizedBox(height: 24),
                _TimerWithRing(
                  remainingDisplay: _remainingDisplay(state.remainingSeconds),
                  progress: progress,
                  mode: state.mode,
                ),
                const SizedBox(height: 32),
                _ControlButtons(
                  isRunning: state.isRunning,
                  onStart: () => ref.read(pomodoroControllerProvider.notifier).start(),
                  onPause: () => ref.read(pomodoroControllerProvider.notifier).pause(),
                  onReset: () => ref.read(pomodoroControllerProvider.notifier).reset(),
                ),
                const SizedBox(height: 12),
                Text(
                  state.isRunning
                      ? 'Stay focused. You’ve got this.'
                      : 'Tap Start when you’re ready.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sessions today: ${state.sessionsCompletedToday}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode});

  final PomodoroMode mode;

  @override
  Widget build(BuildContext context) {
    final isFocus = mode == PomodoroMode.focus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isFocus
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        PomodoroCard._modeLabel(mode),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isFocus
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TimerWithRing extends StatelessWidget {
  const _TimerWithRing({
    required this.remainingDisplay,
    required this.progress,
    required this.mode,
  });

  final String remainingDisplay;
  final double progress;
  final PomodoroMode mode;

  @override
  Widget build(BuildContext context) {
    const size = 220.0;
    final color = mode == PomodoroMode.focus
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.8)),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              remainingDisplay,
              key: ValueKey(remainingDisplay),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButtons extends StatefulWidget {
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
  State<_ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<_ControlButtons> {
  bool _startHover = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _startHover = true),
          onExit: (_) => setState(() => _startHover = false),
          child: AnimatedScale(
            scale: _startHover ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: FilledButton.icon(
              onPressed: widget.isRunning ? widget.onPause : widget.onStart,
              icon: Icon(widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(widget.isRunning ? 'Pause' : 'Start'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: widget.onReset,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
