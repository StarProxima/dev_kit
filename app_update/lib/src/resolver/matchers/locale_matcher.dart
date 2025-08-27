import '../../entities/update_locale.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../../utils/mergeable.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия локали пользователя (ru, en, any).
class LocaleMatcher extends RuleMatcher {
  const LocaleMatcher();

  @override
  bool isMatches<T extends Mergeable<T>>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData search,
  }) {
    final locales = rule.localeIs ?? [UpdateLocale.any];
    final locale = search.locale;

    return locales.contains(UpdateLocale.any) || locales.contains(locale);
  }
}
