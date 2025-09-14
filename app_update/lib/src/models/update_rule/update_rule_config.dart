import '../../entities/app_status.dart';
import '../../entities/update_date.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_version_constraint.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';
import 'update_rule_rollout.dart';
import 'update_rule_when.dart';

/// Правило обновления с новой архитектурой v4.
///
/// Использует семантическую структуру when/rollout/data для
/// четкого разделения логики матчинга, временных параметров и данных результата.
class UpdateRuleConfig<T extends Mergeable<T>> {
  /// Условия применения правила (matching conditions).
  /// Определяет КОГДА правило должно применяться.
  final UpdateRuleWhen? when;

  /// Параметры временного управления (rollout parameters).
  /// Определяет КОГДА и КАК раскатывать правило.
  final UpdateRuleRollout? rollout;

  /// Данные правила для merge в результат.
  final T data;

  const UpdateRuleConfig({
    this.when,
    this.rollout,
    required this.data,
  });

  const UpdateRuleConfig.byRequired({
    required this.when,
    required this.rollout,
    required this.data,
  });

  // Convenience accessors для backward compatibility с existing code
  List<AppStatus>? get appStatusIs => when?.appStatusIs;
  List<UpdateLocale>? get localeIs => when?.localeIs;
  List<UpdateViewTarget>? get viewTargetIs => when?.viewTargetIs;
  List<UpdateVersionConstraint>? get appVersionIs => when?.appVersionIs;
  List<UpdateSource>? get sourceIs => when?.sourceIs;
  List<UpdatePlatform>? get platformIs => when?.platformIs;
  UpdateDate? get date => rollout?.date;
  Duration? get delay => rollout?.delay;
  Duration? get rolloutDuration => rollout?.rollout;
  double? get segmentationPercent => rollout?.segmentationPercent;

  /// Объединенные customParams из when и rollout секций.
  /// В новой архитектуре customParams разделены по секциям, но некоторые
  /// части legacy кода могут ожидать unified доступ.
  Map<String, dynamic>? get customParams => Mergeable.mergeCustomParams(
        when?.customParams,
        rollout?.customParams,
      );

  UpdateRuleConfig<T> copyWith({
    UpdateRuleWhen? when,
    UpdateRuleRollout? rollout,
    T? data,
    // Legacy параметры для backward compatibility в tests:
    List<AppStatus>? appStatusIs,
    List<UpdateLocale>? localeIs,
    List<UpdateViewTarget>? viewTargetIs,
    List<UpdateVersionConstraint>? appVersionIs,
    List<UpdateSource>? sourceIs,
    List<UpdatePlatform>? platformIs,
    UpdateDate? date,
    Duration? delay,
    Duration? rolloutParam,
    double? segmentationPercent,
    Map<String, dynamic>? customParams,
  }) {
    // Handle legacy parameters by building new when/rollout objects
    UpdateRuleWhen? newWhen = when;
    UpdateRuleRollout? newRollout = rollout;

    if (appStatusIs != null ||
        localeIs != null ||
        viewTargetIs != null ||
        appVersionIs != null ||
        sourceIs != null ||
        platformIs != null ||
        customParams != null) {
      newWhen = (this.when ?? const UpdateRuleWhen()).copyWith(
        appStatusIs: appStatusIs,
        localeIs: localeIs,
        viewTargetIs: viewTargetIs,
        appVersionIs: appVersionIs,
        sourceIs: sourceIs,
        platformIs: platformIs,
        customParams: customParams,
      );
    }

    if (date != null ||
        delay != null ||
        rolloutParam != null ||
        segmentationPercent != null) {
      newRollout = (this.rollout ?? const UpdateRuleRollout()).copyWith(
        date: date,
        delay: delay,
        rollout: rolloutParam,
        segmentationPercent: segmentationPercent,
      );
    }

    return UpdateRuleConfig<T>(
      when: newWhen ?? this.when,
      rollout: newRollout ?? this.rollout,
      data: data ?? this.data,
    );
  }
}
