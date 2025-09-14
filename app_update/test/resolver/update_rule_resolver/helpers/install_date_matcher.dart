import 'package:app_update/app_update.dart';

/// Матчер для проверки времени, прошедшего с момента установки приложения.
/// Использует поле 'min_delay_after_app_install_hours' в rollout.customParams
/// и поле 'app_install_date' в search.customParams для определения времени.
class InstallDateMatcher extends RuleMatcher {
  const InstallDateMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    final rolloutCustomParams = rule.rollout?.customParams;
    if (rolloutCustomParams == null) return true;

    final delayHours = rolloutCustomParams['min_delay_after_app_install_hours'];
    if (delayHours == null) return true;

    if (delayHours is! int) return true;

    final searchCustomParams = search.customParams;
    if (searchCustomParams == null) return false;

    final appInstallDate = searchCustomParams['app_install_date'];
    if (appInstallDate is! DateTime) return false;

    final minDelay = Duration(hours: delayHours);
    final elapsedTime = search.currentDate.difference(appInstallDate);

    final isMatched = elapsedTime >= minDelay;

    return isMatched;
  }
}
