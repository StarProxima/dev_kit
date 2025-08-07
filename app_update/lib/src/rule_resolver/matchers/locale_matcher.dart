import '../../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../../shared/update_locale.dart';
import '../models/mergeable.dart';
import '../models/update_search_data.dart';
import 'rule_matcher.dart';

class LocaleMatcher<T extends Mergeable> implements RuleMatcher<T> {
  const LocaleMatcher();

  @override
  bool matches({required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final locales = rule.locales;
    final locale = search.locale;
    return locales.contains(UpdateLocale.any) || locales.contains(locale);
  }
}
