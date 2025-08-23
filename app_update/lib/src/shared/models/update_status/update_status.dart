import '../update_rule/update_rule_config.dart';

enum UpdateStatusType {
  /// Обновление доступно.
  available,

  /// Не получилось получить обновления ни с конфига, ни с фетчеров.
  failedToFetch,

  /// Обновление с версией выше текущей не найдено.
  notFound,

  /// Обновление с версиями выше текущей найдено, но не для установленного источника.
  notFoundForTargetSource,

  /// Найдено и показывалось, но пользователь пропустил это конкретное обновление.
  skipped,

  /// Найдено и показывалось, но пользователь отложил это конкретное обновление.
  postponed,

  /// Найдено, но ещё не отображается из-за установленного [UpdateRuleConfig.delay].
  delayed,

  /// Найдено, но еще не отображается этому конкретному пользователю
  /// из-за установленного [UpdateRuleConfig.rollout].
  notYetRollout,
}

sealed class UpdateStatus {
  final UpdateStatusType type;

  const UpdateStatus({
    required this.type,
  });
}

class UpdateAvailableStatus extends UpdateStatus {
  const UpdateAvailableStatus() : super(type: UpdateStatusType.available);
}

abstract class UpdateException extends UpdateStatus implements Exception {
  const UpdateException({required super.type});
}

class UpdateNotFoundException extends UpdateException {
  const UpdateNotFoundException() : super(type: UpdateStatusType.notFound);

  @override
  String toString() => 'UpdateNotFoundException';
}

class UpdateSkippedException extends UpdateException {
  const UpdateSkippedException() : super(type: UpdateStatusType.skipped);

  @override
  String toString() => 'UpdateSkippedException';
}

class UpdatePostponedException extends UpdateException {
  const UpdatePostponedException() : super(type: UpdateStatusType.postponed);

  @override
  String toString() => 'UpdateNotFoundException';
}
