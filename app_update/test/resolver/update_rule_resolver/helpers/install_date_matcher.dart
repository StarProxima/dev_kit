import 'package:app_update/app_update.dart';

/// Матчер для проверки времени, прошедшего с момента установки приложения.
/// Использует поле 'min_delay_after_app_install_hours' в customData правила
/// и поле 'app_install_date' в customData поиска для определения времени.
/// Должен выполняться ПЕРЕД CustomDataMatcher, так как не использует суффикс '_is'.
class InstallDateMatcher extends RuleMatcher {
  const InstallDateMatcher();

  @override
  bool get canUseCustomData => true;

  @override
  bool isMatches<T extends Mergeable<T>>({
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

    final isMatched = elapsedTime >= minDelay;

    // Удаляем обработанное поле из customData для последующих матчеров
    if (isMatched) {
      ruleCustomData.remove('min_delay_after_app_install_hours');
    }

    return isMatched;
  }
}
