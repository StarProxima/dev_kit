import '../../shared/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../../shared/update_entities/update_locale.dart';
import 'rule_matcher.dart';

class LocaleMatcher<T extends Mergeable?> implements RuleMatcher<T> {
  const LocaleMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final locales = rule.locales ?? [UpdateLocale.any];
    final locale = search.locale;
    return locales.contains(UpdateLocale.any) || locales.contains(locale);
  }
}
