import '../models/update_rule/update_rule_config.dart';
import '../models/update_search/update_search_data.dart';
import '../utils/mergeable.dart';
import 'base/rule_matcher.dart';
import 'matchers/app_status_matcher.dart';
import 'matchers/custom_params_matcher.dart';
import 'matchers/locale_matcher.dart';
import 'matchers/platform_matcher.dart';
import 'matchers/source_matcher.dart';
import 'matchers/temporal_matcher.dart';
import 'matchers/version_matcher.dart';
import 'matchers/view_target_matcher.dart';

/// Резолвер правил обновлений с настраиваемыми матчерами.
/// Применяет список матчеров для фильтрации и объединения правил.
class UpdateRuleResolver {
  /// Стандартный набор матчеров для всех типов правил.
  static const defaultMatchers = <RuleMatcher>[
    ViewTargetMatcher(),
    LocaleMatcher(),
    SourceMatcher(),
    PlatformMatcher(),
    VersionMatcher(),
    AppStatusMatcher(),
    TemporalMatcher(),
    CustomParamsMatcher(),
  ];

  final List<RuleMatcher> matchers;

  const UpdateRuleResolver({this.matchers = defaultMatchers});

  /// Резолвит список правил в одно значение типа [T], применяя:
  /// - фильтрацию по контексту (таргет, локаль, источники, версии, статусы)
  /// - временные условия из rollout секции (date, delay, rollout, segmentation)
  /// - кастомные условия из when секции
  ///
  /// Правила применяются по порядку. Последующие правила переопределяют поля предыдущих
  /// через реализацию [Mergeable.merge]. Если ни одно правило не подошло — кидает
  /// [UpdateRuleResolverException].
  T resolve<T extends Mergeable<T>>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    T? result;

    final matchedRules = <UpdateRuleConfig<T>>[];

    for (final rule in rules) {
      final isMatched = isRuleMatched(rule: rule, searchData: searchData);
      if (isMatched) {
        matchedRules.add(rule);
      }
    }

    for (final rule in matchedRules) {
      final data = rule.data;
      result = result?.merge(data) ?? data;
    }

    if (result == null) {
      throw UpdateRuleResolverException(
        // ignore: avoid-default-tostring
        'No rules matched for search data: $searchData',
      );
    }

    return result;
  }

  bool isRuleMatched<T extends Mergeable<T>>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData searchData,
  }) {
    // Проверяем все matchers - все должны пройти
    for (final matcher in matchers) {
      if (!matcher.isMatches(rule: rule, search: searchData)) {
        return false;
      }
    }

    return true;
  }
}

class UpdateRuleResolverException implements Exception {
  final String message;

  const UpdateRuleResolverException(this.message);

  @override
  String toString() => 'UpdateRuleResolverException: $message';
}
