import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';

/// Интерфейс матчера одного аспекта правила.
/// Каждый матчер проверяет соответствие определенного аспекта правила поисковому контексту.
abstract class RuleMatcher {
  const RuleMatcher();

  /// Может ли матчер использовать и изменять customParams правила.
  /// Если да, то матчер должен удалять из customParams обработанные поля.
  bool get canUseCustomParams => false;

  /// Проверяет соответствие правила поисковому контексту.
  /// Generic параметр позволяет одному матчеру работать с разными типами правил.
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  });
}
