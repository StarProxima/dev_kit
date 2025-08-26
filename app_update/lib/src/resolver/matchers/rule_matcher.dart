import '../../shared/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';

/// Интерфейс матчера одного аспекта правила
abstract class RuleMatcher<T extends Mergeable> {
  bool matches({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData search,
  });
}
