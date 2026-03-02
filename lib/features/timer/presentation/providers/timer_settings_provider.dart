import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/pomodoro_settings_local_datasource.dart';
import '../../data/repositories/pomodoro_settings_repository_impl.dart';
import '../../domain/entities/pomodoro_settings.dart';
import '../../domain/repositories/pomodoro_settings_repository.dart';

/// Provides the Hive "settings" box. Must be overridden in main.
final settingsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'Settings box must be overridden in main (ProviderScope overrides)',
  );
});

final pomodoroSettingsLocalDataSourceProvider =
    Provider<PomodoroSettingsLocalDataSource>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return PomodoroSettingsLocalDataSource(box);
});

final pomodoroSettingsRepositoryProvider =
    Provider<PomodoroSettingsRepository>((ref) {
  final dataSource = ref.watch(pomodoroSettingsLocalDataSourceProvider);
  return PomodoroSettingsRepositoryImpl(dataSource);
});

/// Loads settings on first build; exposes current [PomodoroSettings] and [saveSettings].
class PomodoroSettingsNotifier extends AutoDisposeAsyncNotifier<PomodoroSettings> {
  @override
  Future<PomodoroSettings> build() async {
    return ref.read(pomodoroSettingsRepositoryProvider).load();
  }

  Future<void> saveSettings(PomodoroSettings settings) async {
    await ref.read(pomodoroSettingsRepositoryProvider).save(settings);
    state = AsyncValue.data(settings);
  }
}

/// Settings loaded from Hive; use .valueOrNull for current value.
final pomodoroSettingsProvider =
    AsyncNotifierProvider.autoDispose<PomodoroSettingsNotifier, PomodoroSettings>(
  PomodoroSettingsNotifier.new,
);
