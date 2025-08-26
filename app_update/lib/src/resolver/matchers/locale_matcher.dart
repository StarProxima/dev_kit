import '../../shared/entities/update_locale.dart';
import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../rule_matcher.dart';

/// Матчер для проверки соответствия локали пользователя (ru, en, any)
class LocaleMatcher extends RuleMatcher {
  const LocaleMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    final locales = rule.localeIs ?? [UpdateLocale.any];
    final locale = search.locale;
    return locales.contains(UpdateLocale.any) || locales.contains(locale);
  }
}
