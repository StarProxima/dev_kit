import '../../entities/update_locale.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки соответствия локали пользователя (ru, en, any).
class LocaleMatcher extends RuleMatcher {
  const LocaleMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final ruleLocales = rule.when?.localeIs ?? [UpdateLocale.any];
    final searchLocale = search.locale;

    final isMatch = ruleLocales.contains(UpdateLocale.any) ||
        ruleLocales.contains(searchLocale);

    return isMatch;
  }
}
