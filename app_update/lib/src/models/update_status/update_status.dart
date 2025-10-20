import '../../storage/storage_data.dart';
import '../update_rule/update_rule_config.dart';

enum UpdateStatusType {
  /// Поиск обновления еще не выполнялся.
  initial,

  /// Обновление доступно.
  found,

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

  /// Найдено, но ещё не отображается из-за установленного delay в [UpdateRuleConfig.rollout].
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

class UpdateFoundStatus extends UpdateStatus {
  const UpdateFoundStatus() : super(type: UpdateStatusType.found);
}

class UpdateInitialStatus extends UpdateStatus {
  const UpdateInitialStatus() : super(type: UpdateStatusType.initial);
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
  final PostponedUpdate postponedUpdate;

  const UpdateSkippedException({
    required this.postponedUpdate,
  }) : super(type: UpdateStatusType.skipped);

  @override
  String toString() => 'UpdateSkippedException';
}

class UpdatePostponedException extends UpdateException {
  final PostponedUpdate? postponedUpdate;

  const UpdatePostponedException({
    this.postponedUpdate,
  }) : super(type: UpdateStatusType.postponed);

  @override
  String toString() => 'UpdatePostponedException';
}
