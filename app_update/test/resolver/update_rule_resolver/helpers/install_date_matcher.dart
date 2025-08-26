import 'package:app_update/src/shared/models/mergeable.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
import 'package:app_update/src/resolver/rule_matcher.dart';

/// Матчер для проверки времени, прошедшего с момента установки приложения.
/// Использует поле 'min_delay_after_app_install_hours' в customData правила
/// и поле 'app_install_date' в customData поиска для определения времени.
/// Должен выполняться ПЕРЕД CustomDataMatcher, так как не использует суффикс '_is'.
class InstallDateMatcher implements RuleMatcher {
  const InstallDateMatcher();

  @override
  bool matches<T extends Mergeable>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData search,
  }) {
    final ruleCustomData = rule.customData;
    if (ruleCustomData == null) return true;

    final delayHours = ruleCustomData['min_delay_after_app_install_hours'];
    if (delayHours == null) return true;

    if (delayHours is! int) return true;

    final searchCustomData = search.customData;
    if (searchCustomData == null) return false;

    final appInstallDate = searchCustomData['app_install_date'];
    if (appInstallDate is! DateTime) return false;

    final minDelay = Duration(hours: delayHours);
    final elapsedTime = search.currentDate.difference(appInstallDate);

    return elapsedTime >= minDelay;
  }
}
