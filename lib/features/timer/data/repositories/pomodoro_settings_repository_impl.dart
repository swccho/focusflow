import '../../domain/entities/pomodoro_settings.dart';
import '../../domain/repositories/pomodoro_settings_repository.dart';
import '../datasources/pomodoro_settings_local_datasource.dart';

/// Thrown when a repository operation fails.
final class PomodoroSettingsRepositoryException implements Exception {
  const PomodoroSettingsRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'PomodoroSettingsRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}

class PomodoroSettingsRepositoryImpl implements PomodoroSettingsRepository {
  PomodoroSettingsRepositoryImpl(this._dataSource);

  final PomodoroSettingsLocalDataSource _dataSource;

  @override
  Future<PomodoroSettings> load() async {
    try {
      return _dataSource.load();
    } on PomodoroSettingsLocalException catch (e) {
      throw PomodoroSettingsRepositoryException(e.message, e.cause);
    }
  }

  @override
  Future<void> save(PomodoroSettings settings) async {
    try {
      await _dataSource.save(settings);
    } on PomodoroSettingsLocalException catch (e) {
      throw PomodoroSettingsRepositoryException(e.message, e.cause);
    }
  }
}
