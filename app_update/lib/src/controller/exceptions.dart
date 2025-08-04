import '../finalizer/models/app_update.dart';
import '../finalizer/models/update_settings.dart';

// TODO: Мб перейти на UpdateException c enum, как DioException
enum UpdateExceptionType {
  /// Не получилось получить обновления ни с конфига, ни с фетчеров.
  failedToFetch,

  /// Обновление с версией выше текущей не найдено.
  noFound,

  /// Обновление с версиями выше текущей найдено, но не для установленного источника.
  noFoundForTargetSource,

  /// Найдено и показывалось, но пользователь пропустил это конкретное обновление.
  skipped,

  /// Найдено и показывалось, но пользователь отложил это конкретное обновление.
  postponed,

  /// Найдено, но ещё не отображается из-за установленного [UpdateSettings.releaseDelay].
  delayed,

  /// Найдено, но еще не отображается этому конкретному пользователю
  /// из-за установленного [UpdateSettings.progressiveRolloutDuration].
  notYetRollout,
}

abstract class UpdateException implements Exception {}

class UpdateNotFoundException implements UpdateException {
  const UpdateNotFoundException();

  @override
  String toString() => 'UpdateNotFoundException';
}

class UpdateSkippedException implements UpdateException {
  final UpdateResult update;

  const UpdateSkippedException({
    required this.update,
  });

  @override
  String toString() => 'UpdateSkippedException: $update';
}

class UpdatePostponedException implements UpdateException {
  final UpdateResult update;

  const UpdatePostponedException({
    required this.update,
  });

  @override
  String toString() => 'UpdateNotFoundException';
}
