// ignore_for_file: comment_references

import '../models/update_rule/update_rule_config.dart';
import '../models/update_search/update_search_data.dart';
import '../parser/parse_config_exeption.dart';
import '../utils/mergeable.dart';
import 'base/rule_matcher.dart';
import 'matchers/app_status_matcher.dart';
import 'matchers/custom_data_matcher.dart';
import 'matchers/locale_matcher.dart';
import 'matchers/source_matcher.dart';
import 'matchers/temporal_matcher.dart';
import 'matchers/version_matcher.dart';
import 'matchers/view_target_matcher.dart';

/// Резолвер правил обновлений с настраиваемыми матчерами.
/// Применяет список матчеров для фильтрации и объединения правил.
class UpdateRuleResolver {
  /// Стандартный набор матчеров для всех типов правил
  static const defaultMatchers = <RuleMatcher>[
    ViewTargetMatcher(),
    LocaleMatcher(),
    SourceMatcher(),
    VersionMatcher(),
    AppStatusMatcher(),
    TemporalMatcher(),
    CustomDataMatcher(),
  ];

  final List<RuleMatcher> matchers;

  const UpdateRuleResolver({this.matchers = defaultMatchers});

  /// Резолвит список правил в одно значение типа [T], применяя:
  /// - фильтрацию по контексту (таргет, локаль, источники, версии, статусы)
  /// - временные условия: [date] + [delay] + [rollout]
  /// - сегментацию пользователей: [segmentationPercent]
  ///
  /// Правила применяются по порядку. Последующие правила переопределяют поля предыдущих
  /// через реализацию [Mergeable.merge]. Если ни одно правило не подошло — кидает
  /// [ParseConfigException].
  ///
  /// Временные условия:
  /// - date: базовая дата срабатывания (или ссылка $localReleaseDate / $updateReleaseDate)
  /// - delay_hours: правило начинает действовать только после (date + delay)
  /// - rollout_hours: прогресс выката = (now - date) / rollout_hours
  ///   - правило доступно, если rolloutPointer <= прогрессу выката (в диапазоне 0..1)
  /// - segmentation_percent: доля пользователей 0..100; правило доступно, если
  ///   segmentationPointer (0..1) <= segmentation_percent / 100
  T resolve<T extends Mergeable<T>>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    T? result;

    for (final rule in rules) {
      if (!_isRuleMatched(rule: rule, searchData: searchData)) continue;

      final data = rule.data;
      result = result == null ? data : result.merge(data);
    }

    if (result == null) throw const ParseConfigException();

    return result;
  }

  bool _isRuleMatched<T extends Mergeable<T>>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData searchData,
  }) {
    // Делаем копию правила (и customData в частности)
    // чтобы не модифицировать оригинальное правило
    final finalRule = matchers.any((matcher) => matcher.canUseCustomData)
        ? rule.copyWith()
        : rule;

    for (final matcher in matchers) {
      if (!matcher.isMatches<T>(rule: finalRule, search: searchData)) {
        return false;
      }
    }

    return true;
  }
}
