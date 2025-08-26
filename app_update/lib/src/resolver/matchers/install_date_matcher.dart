import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import 'rule_matcher.dart';

/// Матчер для проверки времени, прошедшего с момента установки приложения.
/// Использует поле 'min_delay_after_app_install_hours' в customData правила
/// для определения минимального количества часов после установки.
/// Должен выполняться ПЕРЕД CustomDataMatcher, так как не использует суффикс '_is'.
class InstallDateMatcher implements RuleMatcher {
  const InstallDateMatcher();

  @override
  bool matches<T extends Mergeable>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData search,
  }) {
    final customData = rule.customData;
    if (customData == null) return true;

    final delayHours = customData['min_delay_after_app_install_hours'];
    if (delayHours == null) return true;

    if (delayHours is! int) return true;
    if (search.appInstallDate == null) return false;

    final minDelay = Duration(hours: delayHours);
    final elapsedTime = search.currentDate.difference(search.appInstallDate!);

    return elapsedTime >= minDelay;
  }
}
