// ignore_for_file: comment_references

import '../parser/common.dart';
import '../shared/mergeable.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/models/update_search/update_search_data.dart';
import 'matchers/app_status_matcher.dart';
import 'matchers/custom_data_matcher.dart';
import 'matchers/locale_matcher.dart';
import 'matchers/source_matcher.dart';
import 'matchers/temporal_matcher.dart';
import 'matchers/version_matcher.dart';
import 'matchers/view_target_matcher.dart';

class UpdateRuleResolver {
  const UpdateRuleResolver();

  /// Резолвит список правил в одно значение типа [T], применяя:
  /// - фильтрацию по контексту (таргет, локаль, источники, версии, статусы)
  /// - временные условия: [date] + [delay] + [rollout]
  /// - сегментацию пользователей: [segmentationPercent]
  ///
  /// Правила применяются по порядку. Последующие правила переопределяют поля предыдущих
  /// через реализацию [Mergeable.merge]. Если ни одно правило не подошло — кидает
  /// [UpdateConfigException].
  ///
  /// Временные условия:
  /// - date: базовая дата срабатывания (или ссылка $localReleaseDate / $updateReleaseDate)
  /// - delay_hours: правило начинает действовать только после (date + delay)
  /// - rollout_hours: прогресс выката = (now - date) / rollout_hours
  ///   - правило доступно, если rolloutPointer <= прогрессу выката (в диапазоне 0..1)
  /// - segmentation_percent: доля пользователей 0..100; правило доступно, если
  ///   segmentationPointer (0..1) <= segmentation_percent / 100
  T resolve<T extends Mergeable?>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    T? result;

    for (final rule in rules) {
      if (!_isRuleMatched(rule: rule, searchData: searchData)) continue;

      final data = rule.data;
      if (data == null) continue;
      result = result == null ? data : (result.merge(data) as T);
    }

    if (result == null) throw const UpdateConfigException();
    return result;
  }

  bool _isRuleMatched<T extends Mergeable?>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData searchData,
  }) {
    final viewTargetMatcher = ViewTargetMatcher<T>();
    final localeMatcher = LocaleMatcher<T>();
    final sourceMatcher = SourceMatcher<T>();
    final versionMatcher = VersionMatcher<T>();
    final appStatusMatcher = AppStatusMatcher<T>();
    final temporalMatcher = TemporalMatcher<T>();
    final customDataMatcher = CustomDataMatcher<T>();

    if (!viewTargetMatcher.matches(rule: rule, search: searchData)) return false;
    if (!localeMatcher.matches(rule: rule, search: searchData)) return false;
    if (!sourceMatcher.matches(rule: rule, search: searchData)) return false;
    if (!versionMatcher.matches(rule: rule, search: searchData)) return false;
    if (!appStatusMatcher.matches(rule: rule, search: searchData)) return false;
    if (!temporalMatcher.matches(rule: rule, search: searchData)) return false;
    if (!customDataMatcher.matches(rule: rule, search: searchData)) return false;
    return true;
  }
}
