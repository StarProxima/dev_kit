import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';

/// Интерфейс матчера одного аспекта правила.
/// Каждый матчер проверяет соответствие определенного аспекта правила поисковому контексту.
abstract class RuleMatcher {
  const RuleMatcher();

  /// Может ли матчер использовать и изменять customData правила.
  /// Если да, то матчер должен удалять из customData обработанные поля.
  bool get canUseCustomData => false;

  /// Проверяет соответствие правила поисковому контексту.
  /// Generic параметр позволяет одному матчеру работать с разными типами правил.
  bool matches<T extends Mergeable>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData search,
  });
}
