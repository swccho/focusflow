import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro_settings.dart';
import '../providers/timer_settings_provider.dart';

const int _focusMin = 10;
const int _focusMax = 90;
const int _breakMin = 1;
const int _breakMax = 30;

/// Modal dialog to edit focus/break minutes. Preloads current settings; Save persists via provider.
class PomodoroSettingsDialog extends ConsumerStatefulWidget {
  const PomodoroSettingsDialog({
    super.key,
    required this.initialSettings,
  });

  final PomodoroSettings initialSettings;

  @override
  ConsumerState<PomodoroSettingsDialog> createState() =>
      _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends ConsumerState<PomodoroSettingsDialog> {
  late final TextEditingController _focusController;
  late final TextEditingController _breakController;
  String? _focusError;
  String? _breakError;

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController(
      text: widget.initialSettings.focusMinutes.toString(),
    );
    _breakController = TextEditingController(
      text: widget.initialSettings.breakMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  bool _validate() {
    final focusText = _focusController.text.trim();
    final breakText = _breakController.text.trim();
    int? focus;
    int? break_;
    String? focusError;
    String? breakError;

    if (focusText.isEmpty) {
      focusError = 'Required';
    } else {
      focus = int.tryParse(focusText);
      if (focus == null || focus < _focusMin || focus > _focusMax) {
        focusError = '$_focusMin–$_focusMax';
      }
    }

    if (breakText.isEmpty) {
      breakError = 'Required';
    } else {
      break_ = int.tryParse(breakText);
      if (break_ == null || break_ < _breakMin || break_ > _breakMax) {
        breakError = '$_breakMin–$_breakMax';
      }
    }

    setState(() {
      _focusError = focusError;
      _breakError = breakError;
    });
    return focusError == null && breakError == null && focus != null && break_ != null;
  }

  PomodoroSettings? _currentSettingsIfValid() {
    final focus = int.tryParse(_focusController.text.trim());
    final break_ = int.tryParse(_breakController.text.trim());
    if (focus == null || break_ == null) return null;
    if (focus < _focusMin || focus > _focusMax) return null;
    if (break_ < _breakMin || break_ > _breakMax) return null;
    return PomodoroSettings(focusMinutes: focus, breakMinutes: break_);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    final settings = _currentSettingsIfValid();
    if (settings == null) return;
    await ref.read(pomodoroSettingsProvider.notifier).saveSettings(settings);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _currentSettingsIfValid() != null;

    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.escape): _CloseIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CloseIntent: CallbackAction<_CloseIntent>(onInvoke: (_) {
            Navigator.of(context).pop();
            return null;
          }),
          _SaveIntent: CallbackAction<_SaveIntent>(onInvoke: (_) {
            _save();
            return null;
          }),
        },
        child: AlertDialog(
          title: const Text('Timer Settings'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _focusController,
                  decoration: InputDecoration(
                    labelText: 'Focus (minutes)',
                    errorText: _focusError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {
                    _focusError = null;
                    _breakError = null;
                  }),
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breakController,
                  decoration: InputDecoration(
                    labelText: 'Break (minutes)',
                    errorText: _breakError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {
                    _focusError = null;
                    _breakError = null;
                  }),
                  onFieldSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: valid ? _save : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseIntent extends Intent {}
class _SaveIntent extends Intent {}
