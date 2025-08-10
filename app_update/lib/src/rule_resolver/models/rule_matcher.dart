import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import 'mergeable.dart';
import 'update_search_data.dart';

/// Интерфейс матчера одного аспекта правила
abstract class RuleMatcher<T extends Mergeable> {
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search});
}
